/**
 * Doctor Assignment Module
 * Manages doctor network, round-robin assignment by specialty, SLA tracking,
 * availability management, and quality scoring for arq.clinic
 */

const pool = require('./db-pool'); // PostgreSQL connection pool

/**
 * Doctor specialties supported
 */
const SPECIALTIES = {
  MBBS: 'MBBS',
  ENDOCRINOLOGIST: 'endocrinologist',
  DERMATOLOGIST: 'dermatologist',
  PSYCHIATRIST: 'psychiatrist'
};

/**
 * SLA Configuration (in milliseconds)
 */
const SLA_DURATION = 2 * 60 * 60 * 1000; // 2 hours
const ESCALATION_THRESHOLD = 1.5 * 60 * 60 * 1000; // 1.5 hours

/**
 * Quality score thresholds
 */
const QUALITY_THRESHOLDS = {
  EXCELLENT: 4.5,
  GOOD: 4.0,
  FAIR: 3.5,
  POOR: 0
};

class DoctorAssignment {
  /**
   * Assign doctor to an order using round-robin strategy
   * Prioritizes: specialty match → availability → load balancing → quality score
   */
  async assignDoctor(orderId, specialty = 'MBBS', customerData = {}) {
    try {
      // Validate specialty
      if (!SPECIALTIES[specialty] && !Object.values(SPECIALTIES).includes(specialty)) {
        throw new Error(`Invalid specialty: ${specialty}`);
      }

      // Get available doctors with lowest load (round-robin)
      const doctor = await this.getNextAvailableDoctor(specialty);

      if (!doctor) {
        throw new Error(`No available doctors for specialty: ${specialty}`);
      }

      // Calculate SLA deadline
      const now = new Date();
      const slaDeadline = new Date(now.getTime() + SLA_DURATION);

      // Store assignment in database
      const assignmentQuery = `
        INSERT INTO order_assignments (
          order_id,
          doctor_id,
          specialty,
          assigned_at,
          sla_deadline,
          status
        ) VALUES ($1, $2, $3, NOW(), $4, 'pending')
        RETURNING *;
      `;

      const assignment = await pool.query(assignmentQuery, [
        orderId,
        doctor.id,
        specialty,
        slaDeadline
      ]);

      // Update doctor's assigned orders count
      await this.incrementDoctorLoadCount(doctor.id);

      // Log assignment
      console.log(
        `Doctor assigned: ${doctor.id} (${doctor.name}) to order ${orderId}, SLA: ${slaDeadline}`
      );

      return {
        success: true,
        assignment: assignment.rows[0],
        doctor: doctor,
        slaDeadline: slaDeadline
      };
    } catch (error) {
      console.error('Doctor assignment error:', error.message);
      throw error;
    }
  }

  /**
   * Get next available doctor using round-robin load balancing
   * Returns doctor with:
   * 1. Matching specialty
   * 2. Available status
   * 3. Lowest assigned orders count (round-robin)
   * 4. Quality score > 3.5 (minimum acceptable)
   */
  async getNextAvailableDoctor(specialty) {
    try {
      const query = `
        SELECT
          d.id,
          d.name,
          d.phone_number,
          d.email,
          d.specialty,
          d.availability_status,
          d.assigned_orders_count,
          d.quality_score,
          d.current_load_capacity,
          d.max_load_capacity,
          COUNT(oa.id) as pending_orders
        FROM doctors d
        LEFT JOIN order_assignments oa ON d.id = oa.doctor_id
          AND oa.status IN ('pending', 'in_progress')
          AND oa.assigned_at > NOW() - INTERVAL '1 day'
        WHERE
          d.specialty = $1
          AND d.availability_status = 'available'
          AND d.quality_score >= $2
          AND d.current_load_capacity < d.max_load_capacity
        GROUP BY d.id
        ORDER BY
          d.assigned_orders_count ASC,
          d.quality_score DESC
        LIMIT 1;
      `;

      const result = await pool.query(query, [specialty, QUALITY_THRESHOLDS.FAIR]);

      if (result.rows.length === 0) {
        return null;
      }

      return result.rows[0];
    } catch (error) {
      console.error('Error fetching available doctor:', error.message);
      throw error;
    }
  }

  /**
   * Increment doctor's assigned orders count (for round-robin tracking)
   */
  async incrementDoctorLoadCount(doctorId) {
    try {
      const query = `
        UPDATE doctors
        SET
          assigned_orders_count = assigned_orders_count + 1,
          current_load_capacity = current_load_capacity + 1
        WHERE id = $1
        RETURNING *;
      `;

      const result = await pool.query(query, [doctorId]);
      return result.rows[0];
    } catch (error) {
      console.error('Error updating doctor load count:', error.message);
      throw error;
    }
  }

  /**
   * Decrement doctor's load count when order is completed
   */
  async decrementDoctorLoadCount(doctorId) {
    try {
      const query = `
        UPDATE doctors
        SET
          assigned_orders_count = GREATEST(0, assigned_orders_count - 1),
          current_load_capacity = GREATEST(0, current_load_capacity - 1)
        WHERE id = $1
        RETURNING *;
      `;

      const result = await pool.query(query, [doctorId]);
      return result.rows[0];
    } catch (error) {
      console.error('Error decrementing doctor load count:', error.message);
      throw error;
    }
  }

  /**
   * Check and escalate SLA violations
   * Should be run as a scheduled job every 15 minutes
   */
  async checkAndEscalateSLAViolations() {
    try {
      const escalationQuery = `
        SELECT
          oa.id as assignment_id,
          oa.order_id,
          oa.doctor_id,
          oa.assigned_at,
          oa.sla_deadline,
          d.id,
          d.name,
          d.email,
          d.phone_number
        FROM order_assignments oa
        JOIN doctors d ON oa.doctor_id = d.id
        WHERE
          oa.status = 'pending'
          AND oa.sla_deadline <= NOW() + INTERVAL '30 minutes'
          AND oa.escalation_status IS NULL;
      `;

      const violations = await pool.query(escalationQuery);

      if (violations.rows.length === 0) {
        console.log('No SLA violations to escalate');
        return;
      }

      console.log(`Found ${violations.rows.length} SLA violations to escalate`);

      for (const violation of violations.rows) {
        const timeSinceAssignment = Date.now() - new Date(violation.assigned_at).getTime();
        const isNearing = timeSinceAssignment >= ESCALATION_THRESHOLD;

        if (isNearing) {
          // Send reminder to doctor
          await this.sendSLAEscalationNotification(violation);

          // Update escalation status
          const updateQuery = `
            UPDATE order_assignments
            SET escalation_status = 'escalated', escalated_at = NOW()
            WHERE id = $1;
          `;

          await pool.query(updateQuery, [violation.assignment_id]);

          console.log(`SLA escalation triggered for assignment ${violation.assignment_id}`);
        }
      }
    } catch (error) {
      console.error('Error checking SLA violations:', error.message);
    }
  }

  /**
   * Send SLA escalation notification to doctor
   */
  async sendSLAEscalationNotification(violation) {
    try {
      // Send WhatsApp or SMS reminder
      const notification = {
        doctorId: violation.doctor_id,
        doctorName: violation.name,
        doctorPhone: violation.phone_number,
        doctorEmail: violation.email,
        orderId: violation.order_id,
        message: `Urgent: Please complete callback for Order #${violation.order_id}. SLA deadline: ${violation.sla_deadline}`,
        type: 'sla_escalation'
      };

      // Queue notification to message service
      console.log(`Sending SLA escalation to doctor ${violation.doctor_id}:`, notification);

      // TODO: Call WhatsApp/SMS service
    } catch (error) {
      console.error('Error sending escalation notification:', error.message);
    }
  }

  /**
   * Handle SLA timeout (reassign to another doctor)
   */
  async handleSLATimeout(assignmentId) {
    try {
      // Get original assignment
      const assignmentQuery = `
        SELECT * FROM order_assignments WHERE id = $1;
      `;

      const assignment = await pool.query(assignmentQuery, [assignmentId]);

      if (assignment.rows.length === 0) {
        throw new Error('Assignment not found');
      }

      const originalAssignment = assignment.rows[0];

      // Mark original as failed
      const updateAssignmentQuery = `
        UPDATE order_assignments
        SET status = 'failed', failure_reason = 'sla_timeout'
        WHERE id = $1;
      `;

      await pool.query(updateAssignmentQuery, [assignmentId]);

      // Decrement original doctor's load
      await this.decrementDoctorLoadCount(originalAssignment.doctor_id);

      // Reassign to another doctor
      const newAssignment = await this.assignDoctor(
        originalAssignment.order_id,
        originalAssignment.specialty
      );

      console.log(
        `SLA timeout: Reassigned order ${originalAssignment.order_id} from doctor ${originalAssignment.doctor_id} to ${newAssignment.doctor.id}`
      );

      return newAssignment;
    } catch (error) {
      console.error('Error handling SLA timeout:', error.message);
      throw error;
    }
  }

  /**
   * Get doctor availability calendar
   * Returns available time slots for booking
   */
  async getDoctorAvailability(doctorId, date) {
    try {
      const query = `
        SELECT
          d.id,
          d.name,
          d.specialty,
          da.date,
          da.morning_slots,
          da.afternoon_slots,
          da.evening_slots,
          da.booked_morning,
          da.booked_afternoon,
          da.booked_evening,
          d.consultation_duration
        FROM doctors d
        LEFT JOIN doctor_availability da ON d.id = da.doctor_id
        WHERE d.id = $1 AND da.date = $2;
      `;

      const result = await pool.query(query, [doctorId, date]);

      if (result.rows.length === 0) {
        return null;
      }

      const doctor = result.rows[0];
      const consultation_duration = doctor.consultation_duration || 30; // minutes

      return {
        doctorId: doctor.id,
        doctorName: doctor.name,
        specialty: doctor.specialty,
        date: doctor.date,
        availableSlots: {
          morning: doctor.morning_slots - doctor.booked_morning,
          afternoon: doctor.afternoon_slots - doctor.booked_afternoon,
          evening: doctor.evening_slots - doctor.booked_evening
        },
        consultationDuration: consultation_duration
      };
    } catch (error) {
      console.error('Error fetching doctor availability:', error.message);
      throw error;
    }
  }

  /**
   * Update doctor availability
   */
  async updateDoctorAvailability(doctorId, date, slots) {
    try {
      const {
        morningSlots = 10,
        afternoonSlots = 10,
        eveningSlots = 8,
        isAvailable = true
      } = slots;

      const query = `
        INSERT INTO doctor_availability (
          doctor_id,
          date,
          morning_slots,
          afternoon_slots,
          evening_slots,
          is_available,
          updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, NOW())
        ON CONFLICT (doctor_id, date) DO UPDATE SET
          morning_slots = $3,
          afternoon_slots = $4,
          evening_slots = $5,
          is_available = $6,
          updated_at = NOW()
        RETURNING *;
      `;

      const result = await pool.query(query, [
        doctorId,
        date,
        morningSlots,
        afternoonSlots,
        eveningSlots,
        isAvailable
      ]);

      return result.rows[0];
    } catch (error) {
      console.error('Error updating doctor availability:', error.message);
      throw error;
    }
  }

  /**
   * Update doctor quality score based on completed consultations
   * Score = (positive_feedbacks / total_consultations) * 5
   */
  async updateDoctorQualityScore(doctorId) {
    try {
      const query = `
        WITH consultation_stats AS (
          SELECT
            d.id,
            COUNT(oa.id) as total_consultations,
            COUNT(CASE WHEN cr.rating >= 4 THEN 1 END) as positive_ratings
          FROM doctors d
          LEFT JOIN order_assignments oa ON d.id = oa.doctor_id
          LEFT JOIN consultation_reviews cr ON oa.id = cr.assignment_id
          WHERE d.id = $1
          GROUP BY d.id
        )
        UPDATE doctors SET
          quality_score = ROUND(
            CASE
              WHEN cs.total_consultations = 0 THEN 4.0
              ELSE (COALESCE(cs.positive_ratings, 0)::float / cs.total_consultations) * 5
            END,
            2
          )
        FROM consultation_stats cs
        WHERE doctors.id = cs.id
        RETURNING quality_score;
      `;

      const result = await pool.query(query, [doctorId]);
      const newScore = result.rows[0]?.quality_score || 4.0;

      console.log(`Doctor ${doctorId} quality score updated to ${newScore}`);
      return newScore;
    } catch (error) {
      console.error('Error updating quality score:', error.message);
      throw error;
    }
  }

  /**
   * Get doctor assignment history
   */
  async getDoctorAssignmentHistory(doctorId, days = 30) {
    try {
      const query = `
        SELECT
          oa.id as assignment_id,
          oa.order_id,
          oa.assigned_at,
          oa.sla_deadline,
          oa.status,
          oa.completed_at,
          cr.rating,
          cr.feedback,
          o.customer_id,
          o.order_number,
          EXTRACT(EPOCH FROM (oa.completed_at - oa.assigned_at))/3600 as hours_to_complete
        FROM order_assignments oa
        LEFT JOIN orders o ON oa.order_id = o.id
        LEFT JOIN consultation_reviews cr ON oa.id = cr.assignment_id
        WHERE
          oa.doctor_id = $1
          AND oa.assigned_at >= NOW() - INTERVAL '1 day' * $2
          AND oa.status IN ('completed', 'failed')
        ORDER BY oa.assigned_at DESC;
      `;

      const result = await pool.query(query, [doctorId, days]);
      return result.rows;
    } catch (error) {
      console.error('Error fetching assignment history:', error.message);
      throw error;
    }
  }

  /**
   * Get doctor performance metrics
   */
  async getDoctorPerformanceMetrics(doctorId) {
    try {
      const query = `
        SELECT
          d.id,
          d.name,
          d.specialty,
          d.quality_score,
          COUNT(DISTINCT oa.id) as total_assignments,
          COUNT(DISTINCT CASE WHEN oa.status = 'completed' THEN oa.id END) as completed,
          COUNT(DISTINCT CASE WHEN oa.status = 'failed' THEN oa.id END) as failed,
          ROUND(AVG(EXTRACT(EPOCH FROM (oa.completed_at - oa.assigned_at))/3600)::numeric, 2) as avg_completion_hours,
          COUNT(DISTINCT CASE WHEN cr.rating = 5 THEN cr.id END) as five_star_reviews,
          ROUND(AVG(cr.rating)::numeric, 2) as avg_rating,
          ROUND(
            (COUNT(DISTINCT CASE WHEN oa.status = 'completed' THEN oa.id END)::float /
             NULLIF(COUNT(DISTINCT oa.id), 0)) * 100,
            2
          ) as completion_rate
        FROM doctors d
        LEFT JOIN order_assignments oa ON d.id = oa.doctor_id
        LEFT JOIN consultation_reviews cr ON oa.id = cr.assignment_id
        WHERE d.id = $1
        GROUP BY d.id, d.name, d.specialty, d.quality_score;
      `;

      const result = await pool.query(query, [doctorId]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error fetching performance metrics:', error.message);
      throw error;
    }
  }

  /**
   * Get all doctors with performance summary
   */
  async getAllDoctorsWithMetrics() {
    try {
      const query = `
        SELECT
          d.id,
          d.name,
          d.specialty,
          d.availability_status,
          d.quality_score,
          d.current_load_capacity,
          d.max_load_capacity,
          COUNT(DISTINCT oa.id) as total_assignments,
          COUNT(DISTINCT CASE WHEN oa.status = 'completed' THEN oa.id END) as completed,
          ROUND(
            (COUNT(DISTINCT CASE WHEN oa.status = 'completed' THEN oa.id END)::float /
             NULLIF(COUNT(DISTINCT oa.id), 0)) * 100,
            2
          ) as completion_rate
        FROM doctors d
        LEFT JOIN order_assignments oa ON d.id = oa.doctor_id
        GROUP BY d.id, d.name, d.specialty, d.availability_status, d.quality_score, d.current_load_capacity, d.max_load_capacity
        ORDER BY d.quality_score DESC, d.specialty;
      `;

      const result = await pool.query(query);
      return result.rows;
    } catch (error) {
      console.error('Error fetching all doctors metrics:', error.message);
      throw error;
    }
  }

  /**
   * Mark assignment as completed
   */
  async completeAssignment(assignmentId, completionData = {}) {
    try {
      const { rating, feedback, notes } = completionData;

      // Update assignment
      const updateQuery = `
        UPDATE order_assignments
        SET
          status = 'completed',
          completed_at = NOW()
        WHERE id = $1
        RETURNING *;
      `;

      const assignment = await pool.query(updateQuery, [assignmentId]);

      if (assignment.rows.length === 0) {
        throw new Error('Assignment not found');
      }

      const completedAssignment = assignment.rows[0];

      // Decrement doctor's load
      await this.decrementDoctorLoadCount(completedAssignment.doctor_id);

      // Store review if provided
      if (rating) {
        const reviewQuery = `
          INSERT INTO consultation_reviews (
            assignment_id,
            order_id,
            doctor_id,
            rating,
            feedback,
            notes,
            created_at
          ) VALUES ($1, $2, $3, $4, $5, $6, NOW())
          RETURNING *;
        `;

        await pool.query(reviewQuery, [
          assignmentId,
          completedAssignment.order_id,
          completedAssignment.doctor_id,
          rating,
          feedback,
          notes
        ]);
      }

      // Update doctor quality score
      await this.updateDoctorQualityScore(completedAssignment.doctor_id);

      console.log(`Assignment ${assignmentId} completed, doctor load updated`);

      return completedAssignment;
    } catch (error) {
      console.error('Error completing assignment:', error.message);
      throw error;
    }
  }
}

module.exports = new DoctorAssignment();
