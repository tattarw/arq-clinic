/**
 * arq.clinic - Database Schema
 * PostgreSQL Schema for prescription biohacking platform
 * Created: 2024
 */

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing types and tables (for fresh deployment)
-- Uncomment only for dev/staging environments
-- DROP TABLE IF EXISTS cascade ...

-- ============================================================================
-- ENUMS
-- ============================================================================

CREATE TYPE user_role AS ENUM ('customer', 'doctor', 'admin', 'support');
CREATE TYPE specialty_type AS ENUM ('MBBS', 'endocrinologist', 'dermatologist', 'psychiatrist');
CREATE TYPE order_status AS ENUM (
  'pending',
  'assigned',
  'in_progress',
  'approved',
  'denied',
  'shipped',
  'delivered',
  'completed',
  'cancelled',
  'refunded'
);
CREATE TYPE prescription_status AS ENUM (
  'pending_doctor_review',
  'approved',
  'rejected',
  'pending_approval',
  'expired'
);
CREATE TYPE subscription_status AS ENUM (
  'active',
  'paused',
  'cancelled',
  'completed',
  'halted',
  'expired'
);
CREATE TYPE payment_status AS ENUM (
  'pending',
  'authorized',
  'captured',
  'failed',
  'refunded',
  'partially_refunded'
);
CREATE TYPE assignment_status AS ENUM (
  'pending',
  'in_progress',
  'completed',
  'failed',
  'escalated'
);
CREATE TYPE availability_status AS ENUM ('available', 'unavailable', 'on_leave');
CREATE TYPE message_status AS ENUM ('queued', 'sent', 'delivered', 'failed', 'read');

-- ============================================================================
-- USERS TABLE
-- ============================================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role user_role NOT NULL DEFAULT 'customer',
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone_number VARCHAR(20) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  profile_picture_url TEXT,
  date_of_birth DATE,
  gender VARCHAR(20),
  blood_group VARCHAR(10),
  medical_history TEXT,
  allergies TEXT,
  current_medications TEXT,
  address_line_1 VARCHAR(255),
  address_line_2 VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) DEFAULT 'India',

  -- Account Status
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  email_verified_at TIMESTAMP,
  phone_verified_at TIMESTAMP,
  last_login_at TIMESTAMP,

  -- Preferences
  preferred_language VARCHAR(10) DEFAULT 'en',
  timezone VARCHAR(50),
  notification_preferences JSONB,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,

  CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
  CONSTRAINT valid_phone CHECK (phone_number ~* '^[0-9]{10,15}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================================================
-- DOCTORS TABLE
-- ============================================================================

CREATE TABLE doctors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,

  -- Professional Info
  license_number VARCHAR(100) UNIQUE NOT NULL,
  specialty specialty_type NOT NULL,
  registration_number VARCHAR(100),
  years_of_experience INT,
  qualifications TEXT,
  hospital_affiliations TEXT,

  -- Performance Metrics
  quality_score DECIMAL(3,2) DEFAULT 4.0,
  total_consultations INT DEFAULT 0,
  completed_consultations INT DEFAULT 0,
  average_rating DECIMAL(2,1) DEFAULT 0.0,

  -- Load Management
  availability_status availability_status DEFAULT 'available',
  max_load_capacity INT DEFAULT 20,
  current_load_capacity INT DEFAULT 0,
  assigned_orders_count INT DEFAULT 0,

  -- Timing
  consultation_duration INT DEFAULT 30, -- minutes
  avg_consultation_time INT,

  -- Availability Window
  working_hours_start TIME DEFAULT '09:00',
  working_hours_end TIME DEFAULT '18:00',
  break_start TIME,
  break_end TIME,

  -- Verification
  is_verified BOOLEAN DEFAULT false,
  verification_document_url TEXT,
  verified_at TIMESTAMP,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,

  CONSTRAINT quality_score_range CHECK (quality_score >= 0 AND quality_score <= 5),
  CONSTRAINT positive_experience CHECK (years_of_experience >= 0)
);

CREATE INDEX idx_doctors_specialty ON doctors(specialty);
CREATE INDEX idx_doctors_quality_score ON doctors(quality_score DESC);
CREATE INDEX idx_doctors_availability ON doctors(availability_status);
CREATE INDEX idx_doctors_verified ON doctors(is_verified);

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Basic Info
  sku VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  generic_name VARCHAR(255),
  manufacturer VARCHAR(255),

  -- Classification
  is_prescription_required BOOLEAN DEFAULT false,
  category VARCHAR(100),
  subcategory VARCHAR(100),

  -- Dosage & Strength
  strength VARCHAR(100),
  unit_of_measurement VARCHAR(50), -- mg, ml, tablet, etc.
  quantity_per_pack INT,

  -- Pricing
  cost_price DECIMAL(10,2),
  selling_price DECIMAL(10,2) NOT NULL,
  discount_percentage DECIMAL(5,2) DEFAULT 0,
  tax_percentage DECIMAL(5,2) DEFAULT 0,

  -- Inventory
  quantity_in_stock INT DEFAULT 0,
  reorder_level INT DEFAULT 10,
  warehouse_location VARCHAR(255),

  -- Metadata
  image_url TEXT,
  expiry_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP,

  CONSTRAINT valid_price CHECK (selling_price > 0),
  CONSTRAINT valid_quantity CHECK (quantity_in_stock >= 0)
);

CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_prescription_required ON products(is_prescription_required);

-- ============================================================================
-- ORDERS TABLE
-- ============================================================================

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Order Info
  order_number VARCHAR(50) UNIQUE NOT NULL,
  customer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  subscription_id UUID REFERENCES subscriptions(id),

  -- Status & Tracking
  order_status order_status DEFAULT 'pending',
  refill_order BOOLEAN DEFAULT false,

  -- Pricing
  subtotal DECIMAL(12,2) NOT NULL,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  shipping_cost DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL,

  -- Payment
  payment_status payment_status DEFAULT 'pending',
  payment_method VARCHAR(50),
  razorpay_order_id VARCHAR(100),
  razorpay_payment_id VARCHAR(100),

  -- Shipping
  shipping_address_line_1 VARCHAR(255),
  shipping_address_line_2 VARCHAR(255),
  shipping_city VARCHAR(100),
  shipping_state VARCHAR(100),
  shipping_postal_code VARCHAR(20),
  shipping_country VARCHAR(100) DEFAULT 'India',
  shipping_phone VARCHAR(20),

  -- Dates
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  confirmed_at TIMESTAMP,
  approved_at TIMESTAMP,
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Notes
  notes TEXT,
  denial_reason TEXT,
  cancellation_reason TEXT,

  CONSTRAINT valid_amount CHECK (total_amount >= 0)
);

CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- ============================================================================
-- ORDER ITEMS TABLE
-- ============================================================================

CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,

  -- Item Details
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  line_total DECIMAL(12,2) NOT NULL,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT positive_quantity CHECK (quantity > 0),
  CONSTRAINT valid_price CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- ============================================================================
-- PRESCRIPTIONS TABLE
-- ============================================================================

CREATE TABLE prescriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT,
  subscription_id UUID REFERENCES subscriptions(id),

  -- Prescription Details
  prescription_number VARCHAR(100) UNIQUE NOT NULL,
  status prescription_status DEFAULT 'pending_doctor_review',
  prescription_url TEXT NOT NULL,

  -- Medical Info
  medicines TEXT[], -- Array of medicine names
  dosage JSONB, -- {medicine: dosage, frequency, duration}
  special_instructions TEXT,
  dietary_restrictions TEXT,

  -- Dates
  issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  valid_till TIMESTAMP,
  refill_count INT DEFAULT 0,
  last_refill_date TIMESTAMP,

  -- Approval
  approved_at TIMESTAMP,
  rejected_at TIMESTAMP,
  rejection_reason TEXT,

  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_prescriptions_order_id ON prescriptions(order_id);
CREATE INDEX idx_prescriptions_doctor_id ON prescriptions(doctor_id);
CREATE INDEX idx_prescriptions_status ON prescriptions(status);
CREATE INDEX idx_prescriptions_subscription_id ON prescriptions(subscription_id);

-- ============================================================================
-- SUBSCRIPTIONS TABLE
-- ============================================================================

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  customer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_id VARCHAR(100), -- Razorpay Plan ID
  razorpay_subscription_id VARCHAR(100) UNIQUE,

  -- Subscription Details
  status subscription_status DEFAULT 'active',
  billing_frequency VARCHAR(50) DEFAULT 'monthly', -- monthly, quarterly, yearly
  duration_months INT DEFAULT 12,

  -- Pricing
  subscription_amount DECIMAL(10,2) NOT NULL,
  billing_cycle_amount DECIMAL(10,2),
  next_billing_date DATE,

  -- Refill Schedule
  refill_frequency INT DEFAULT 30, -- days
  next_refill_date DATE,
  refill_count INT DEFAULT 0,
  last_refill_date TIMESTAMP,

  -- Status Tracking
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  paused_at TIMESTAMP,
  resumed_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  completed_at TIMESTAMP,

  -- Auto-Retry
  payment_retry_count INT DEFAULT 0,
  last_payment_retry_at TIMESTAMP,

  -- Notes
  cancellation_reason TEXT,
  cancellation_feedback TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT valid_duration CHECK (duration_months > 0),
  CONSTRAINT valid_amount CHECK (subscription_amount > 0)
);

CREATE INDEX idx_subscriptions_customer_id ON subscriptions(customer_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_next_refill_date ON subscriptions(next_refill_date);
CREATE INDEX idx_subscriptions_created_at ON subscriptions(created_at);

-- ============================================================================
-- DOCTOR AVAILABILITY TABLE
-- ============================================================================

CREATE TABLE doctor_availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,

  -- Date
  date DATE NOT NULL,

  -- Slots
  morning_slots INT DEFAULT 10,
  afternoon_slots INT DEFAULT 10,
  evening_slots INT DEFAULT 8,

  -- Booked Slots
  booked_morning INT DEFAULT 0,
  booked_afternoon INT DEFAULT 0,
  booked_evening INT DEFAULT 0,

  -- Status
  is_available BOOLEAN DEFAULT true,

  -- Metadata
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(doctor_id, date),
  CONSTRAINT non_negative_slots CHECK (
    morning_slots >= 0 AND afternoon_slots >= 0 AND evening_slots >= 0
  )
);

CREATE INDEX idx_doctor_availability_doctor_id ON doctor_availability(doctor_id);
CREATE INDEX idx_doctor_availability_date ON doctor_availability(date);

-- ============================================================================
-- ORDER ASSIGNMENTS TABLE
-- ============================================================================

CREATE TABLE order_assignments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT,

  -- Assignment Details
  specialty specialty_type NOT NULL,
  status assignment_status DEFAULT 'pending',

  -- SLA Tracking
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sla_deadline TIMESTAMP NOT NULL,
  escalation_status VARCHAR(50),
  escalated_at TIMESTAMP,

  -- Completion
  completed_at TIMESTAMP,
  failure_reason TEXT,

  -- Metadata
  notes TEXT,

  CONSTRAINT sla_in_future CHECK (sla_deadline > assigned_at)
);

CREATE INDEX idx_assignments_order_id ON order_assignments(order_id);
CREATE INDEX idx_assignments_doctor_id ON order_assignments(doctor_id);
CREATE INDEX idx_assignments_status ON order_assignments(status);
CREATE INDEX idx_assignments_sla_deadline ON order_assignments(sla_deadline);
CREATE INDEX idx_assignments_created_at ON order_assignments(assigned_at);

-- ============================================================================
-- CALLBACK SCHEDULES TABLE
-- ============================================================================

CREATE TABLE callback_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT,
  assignment_id UUID REFERENCES order_assignments(id) ON DELETE CASCADE,

  -- Scheduling
  scheduled_at TIMESTAMP NOT NULL,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,

  -- Status
  status VARCHAR(50) DEFAULT 'scheduled', -- scheduled, in_progress, completed, missed, rescheduled
  callback_notes TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT scheduled_in_future CHECK (scheduled_at > created_at)
);

CREATE INDEX idx_callbacks_order_id ON callback_schedules(order_id);
CREATE INDEX idx_callbacks_doctor_id ON callback_schedules(doctor_id);
CREATE INDEX idx_callbacks_scheduled_at ON callback_schedules(scheduled_at);

-- ============================================================================
-- SHIPMENTS TABLE
-- ============================================================================

CREATE TABLE shipments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  order_id UUID UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,

  -- Tracking
  tracking_number VARCHAR(100) UNIQUE NOT NULL,
  carrier VARCHAR(100) NOT NULL,
  shipping_provider VARCHAR(100),

  -- Status
  status VARCHAR(50) DEFAULT 'label_generated',

  -- Labels & Documents
  label_url TEXT,
  manifest_url TEXT,

  -- Dates
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  picked_up_at TIMESTAMP,
  in_transit_at TIMESTAMP,
  delivered_at TIMESTAMP,

  CONSTRAINT valid_tracking_number CHECK (tracking_number != '')
);

CREATE INDEX idx_shipments_order_id ON shipments(order_id);
CREATE INDEX idx_shipments_tracking_number ON shipments(tracking_number);
CREATE INDEX idx_shipments_status ON shipments(status);

-- ============================================================================
-- CONSULTATION REVIEWS TABLE
-- ============================================================================

CREATE TABLE consultation_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  assignment_id UUID NOT NULL REFERENCES order_assignments(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT,

  -- Review
  rating INT NOT NULL,
  feedback TEXT,
  notes TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5)
);

CREATE INDEX idx_reviews_doctor_id ON consultation_reviews(doctor_id);
CREATE INDEX idx_reviews_rating ON consultation_reviews(rating);
CREATE INDEX idx_reviews_created_at ON consultation_reviews(created_at);

-- ============================================================================
-- WHATSAPP MESSAGE LOG TABLE
-- ============================================================================

CREATE TABLE whatsapp_message_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Message Details
  template_name VARCHAR(100) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL,
  recipient_user_id UUID REFERENCES users(id) ON DELETE SET NULL,

  -- Context
  related_order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  related_subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  related_doctor_id UUID REFERENCES doctors(id) ON DELETE SET NULL,

  -- Status
  status message_status DEFAULT 'queued',
  whatsapp_message_id VARCHAR(100),

  -- Content
  parameters JSONB,
  error_reason TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sent_at TIMESTAMP,
  delivered_at TIMESTAMP,
  read_at TIMESTAMP
);

CREATE INDEX idx_whatsapp_log_recipient ON whatsapp_message_log(recipient_phone);
CREATE INDEX idx_whatsapp_log_status ON whatsapp_message_log(status);
CREATE INDEX idx_whatsapp_log_created_at ON whatsapp_message_log(created_at);
CREATE INDEX idx_whatsapp_log_template ON whatsapp_message_log(template_name);

-- ============================================================================
-- REFERRAL TRACKING TABLE
-- ============================================================================

CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referred_customer_id UUID REFERENCES users(id) ON DELETE SET NULL,

  -- Referral Code
  referral_code VARCHAR(50) UNIQUE NOT NULL,

  -- Status
  status VARCHAR(50) DEFAULT 'pending', -- pending, active, completed
  referral_completion_date TIMESTAMP,

  -- Rewards
  referrer_reward_amount DECIMAL(10,2),
  referrer_reward_type VARCHAR(50), -- credit, cashback, discount
  referred_customer_reward_amount DECIMAL(10,2),
  referred_customer_reward_type VARCHAR(50),

  -- Related Orders
  first_order_id UUID REFERENCES orders(id),

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX idx_referrals_code ON referrals(referral_code);
CREATE INDEX idx_referrals_status ON referrals(status);

-- ============================================================================
-- WINBACK CAMPAIGNS TABLE
-- ============================================================================

CREATE TABLE winback_campaigns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  customer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  cancelled_subscription_id UUID REFERENCES subscriptions(id),

  -- Campaign Status
  campaign_stage VARCHAR(50) DEFAULT 'stage_1', -- stage_1, stage_2, stage_3, completed

  -- Stage Dates
  stage_1_scheduled_at TIMESTAMP,
  stage_1_sent_at TIMESTAMP,
  stage_2_scheduled_at TIMESTAMP,
  stage_2_sent_at TIMESTAMP,
  stage_3_scheduled_at TIMESTAMP,
  stage_3_sent_at TIMESTAMP,

  -- Results
  conversion_date TIMESTAMP,
  reactivated_subscription_id UUID REFERENCES subscriptions(id),

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);

CREATE INDEX idx_winback_campaigns_customer_id ON winback_campaigns(customer_id);
CREATE INDEX idx_winback_campaigns_stage ON winback_campaigns(campaign_stage);
CREATE INDEX idx_winback_campaigns_created_at ON winback_campaigns(created_at);

-- ============================================================================
-- PAYMENTS TABLE
-- ============================================================================

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  customer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

  -- Payment Details
  razorpay_payment_id VARCHAR(100) UNIQUE,
  razorpay_order_id VARCHAR(100),
  amount DECIMAL(12,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'INR',

  -- Status
  status payment_status DEFAULT 'pending',
  payment_method VARCHAR(50),

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  failed_at TIMESTAMP,
  error_message TEXT
);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_customer_id ON payments(customer_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- ============================================================================
-- DOCTOR VERIFICATIONS TABLE
-- ============================================================================

CREATE TABLE doctor_verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Links
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT,

  -- Verification Details
  verification_type VARCHAR(50) DEFAULT 'refill_re_verification', -- refill_re_verification, prescription_renewal
  verification_status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected

  -- Notes
  verification_notes TEXT,
  rejection_reason TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  verified_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_doctor_verifications_order_id ON doctor_verifications(order_id);
CREATE INDEX idx_doctor_verifications_doctor_id ON doctor_verifications(doctor_id);
CREATE INDEX idx_doctor_verifications_status ON doctor_verifications(verification_status);

-- ============================================================================
-- AUDIT LOG TABLE
-- ============================================================================

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Entity Information
  entity_type VARCHAR(100) NOT NULL,
  entity_id UUID NOT NULL,
  action VARCHAR(50) NOT NULL, -- created, updated, deleted, viewed

  -- User Information
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  ip_address INET,

  -- Changes
  old_values JSONB,
  new_values JSONB,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Active subscriptions count by customer
CREATE VIEW v_customer_subscriptions AS
SELECT
  u.id as customer_id,
  u.first_name,
  u.last_name,
  u.email,
  COUNT(s.id) as active_subscriptions,
  MAX(s.next_refill_date) as next_refill_date,
  SUM(s.subscription_amount) as total_monthly_commitment
FROM users u
LEFT JOIN subscriptions s ON u.id = s.customer_id
  AND s.status IN ('active', 'paused')
GROUP BY u.id, u.first_name, u.last_name, u.email;

-- Doctor performance summary
CREATE VIEW v_doctor_performance AS
SELECT
  d.id,
  d.user_id,
  u.first_name,
  u.last_name,
  d.specialty,
  COUNT(DISTINCT oa.id) as total_assignments,
  COUNT(DISTINCT CASE WHEN oa.status = 'completed' THEN oa.id END) as completed,
  COUNT(DISTINCT CASE WHEN oa.status = 'failed' THEN oa.id END) as failed,
  ROUND(AVG(cr.rating)::numeric, 2) as avg_rating,
  d.quality_score,
  d.current_load_capacity,
  d.max_load_capacity
FROM doctors d
JOIN users u ON d.user_id = u.id
LEFT JOIN order_assignments oa ON d.id = oa.doctor_id
LEFT JOIN consultation_reviews cr ON oa.id = cr.assignment_id
GROUP BY d.id, d.user_id, u.first_name, u.last_name, d.specialty, d.quality_score, d.current_load_capacity, d.max_load_capacity;

-- Orders revenue tracking
CREATE VIEW v_revenue_summary AS
SELECT
  DATE(o.created_at) as order_date,
  COUNT(DISTINCT o.id) as total_orders,
  SUM(o.total_amount) as total_revenue,
  AVG(o.total_amount) as avg_order_value,
  COUNT(DISTINCT o.customer_id) as unique_customers
FROM orders o
WHERE o.order_status NOT IN ('cancelled', 'refunded')
GROUP BY DATE(o.created_at)
ORDER BY order_date DESC;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update user's updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_user_timestamp();

-- Update prescription's updated_at timestamp
CREATE OR REPLACE FUNCTION update_prescription_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prescriptions_updated_at
BEFORE UPDATE ON prescriptions
FOR EACH ROW
EXECUTE FUNCTION update_prescription_timestamp();

-- Update subscription's updated_at timestamp
CREATE OR REPLACE FUNCTION update_subscription_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_subscriptions_updated_at
BEFORE UPDATE ON subscriptions
FOR EACH ROW
EXECUTE FUNCTION update_subscription_timestamp();

-- ============================================================================
-- PERMISSIONS (For different roles)
-- ============================================================================

-- Create role for app service
CREATE ROLE arq_app_service WITH LOGIN PASSWORD 'change_this_strong_password';

-- Grant appropriate permissions
GRANT CONNECT ON DATABASE arq_clinic TO arq_app_service;

-- Schema permissions
GRANT USAGE ON SCHEMA public TO arq_app_service;

-- Table permissions
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO arq_app_service;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO arq_app_service;

-- ============================================================================
-- SAMPLE DATA (for development/testing)
-- ============================================================================

-- Note: Run only in development environment

/*
-- Sample doctor
INSERT INTO users (role, first_name, last_name, email, phone_number, is_verified)
VALUES ('doctor', 'Dr.', 'Sharma', 'dr.sharma@arq.clinic', '+919876543210', true);

-- Sample customer
INSERT INTO users (role, first_name, last_name, email, phone_number, is_verified)
VALUES ('customer', 'John', 'Doe', 'john@example.com', '+919876543211', true);
*/

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE users IS 'Core users table for customers, doctors, admin, and support staff';
COMMENT ON TABLE doctors IS 'Doctor information with specialty and performance metrics';
COMMENT ON TABLE orders IS 'Customer orders with payment and shipping details';
COMMENT ON TABLE prescriptions IS 'E-prescriptions issued by doctors with validity tracking';
COMMENT ON TABLE subscriptions IS 'Subscription details for recurring refills with auto-retry';
COMMENT ON TABLE order_assignments IS 'Doctor assignments to orders with SLA tracking';
COMMENT ON TABLE whatsapp_message_log IS 'WhatsApp message delivery tracking for notifications';
COMMENT ON TABLE referrals IS 'Referral program tracking with reward management';
COMMENT ON TABLE winback_campaigns IS 'Win-back campaigns for churned subscribers';

-- ============================================================================
-- EOF
-- ============================================================================
