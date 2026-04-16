# arq.clinic Backend Infrastructure

Production-ready backend infrastructure for India's first prescription biohacking platform. Complete with payment processing, doctor network management, automation workflows, and database schema.

## Files Overview

### 1. razorpay-integration.js (654 lines)
**Razorpay payment processing and subscription management**

**Features:**
- Order creation endpoint with validation
- Payment verification with HMAC-SHA256 signature validation
- Subscription plan creation and management
- Subscription lifecycle: create, cancel, pause, resume
- Webhook handlers for 8 payment events
- Auto-retry logic for failed subscriptions with exponential backoff
- Error handling and comprehensive logging

**Key Endpoints:**
- `POST /api/payments/create-order` - Create Razorpay order
- `POST /api/payments/verify-payment` - Verify payment signature
- `POST /api/subscriptions/create-plan` - Create subscription plan
- `POST /api/subscriptions/create` - Create new subscription
- `POST /api/subscriptions/:id/cancel` - Cancel subscription
- `POST /api/subscriptions/:id/pause` - Pause subscription
- `POST /api/subscriptions/:id/resume` - Resume paused subscription
- `POST /api/payments/webhook` - Razorpay webhook handler

**Webhook Events Handled:**
- `payment.authorized`, `payment.failed`, `payment.captured`
- `subscription.charged`, `subscription.completed`, `subscription.halted`
- `refund.created`, `refund.failed`

**Environment Variables Required:**
```
RAZORPAY_KEY_ID=<your_key_id>
RAZORPAY_KEY_SECRET=<your_key_secret>
RAZORPAY_WEBHOOK_SECRET=<webhook_secret>
```

---

### 2. n8n-flows.json (1,081 lines)
**Export-ready n8n automation workflows**

**5 Complete Workflows:**

#### A. New Order Flow
Shopify webhook → Doctor assignment (round-robin) → WhatsApp notification to doctor → Callback scheduling → Prescription status tracking
- **Nodes:** 8
- **Trigger:** Shopify order creation
- **Actions:** Store order, assign doctor (load-balanced), notify doctor via WhatsApp, schedule callback, notify customer

#### B. Doctor Callback Flow
Doctor completes consult → E-prescription generated → Order approved/denied → WhatsApp notification to customer
- **Nodes:** 9
- **Trigger:** Callback completion webhook
- **Actions:** Generate e-prescription, store prescription, approval status check, conditional notifications

#### C. Fulfillment Flow
Prescription approved → Shipping label generated → Tracking update → Delivery confirmation
- **Nodes:** 10
- **Trigger:** Order approved webhook
- **Actions:** Generate shipping label, poll tracking status, notify customer on delivery

#### D. Refill Flow
Day 25 reminder → Customer confirms/skips → Auto-reorder if confirmed → Doctor re-verification (every 3rd refill)
- **Nodes:** 11
- **Trigger:** Daily cron job
- **Actions:** Send refill reminder, handle confirmations/skips, auto-create refill order, trigger doctor verification

#### E. Win-Back Flow
Churned subscriber → Day 7 follow-up → Day 14 offer → Day 30 final reach-out
- **Nodes:** 11
- **Trigger:** Subscription cancellation
- **Actions:** Create win-back campaign, send staged messages with progressive offers

**Integration Points:**
- PostgreSQL for data persistence
- WhatsApp Business API for messaging
- Shopify for order triggers
- Prescription service for e-prescription generation
- Fulfillment service for shipping

---

### 3. doctor-assignment.js (639 lines)
**Doctor network management with round-robin load balancing**

**Features:**
- Round-robin assignment by specialty (MBBS, endocrinologist, dermatologist, psychiatrist)
- Quality score-based filtering (minimum 3.5 threshold)
- 2-hour SLA tracking with escalation at 90 minutes
- Doctor availability calendar management
- Quality scoring based on consultation ratings
- Assignment history and performance metrics
- Load capacity management (max/current capacity tracking)

**Key Methods:**
- `assignDoctor(orderId, specialty)` - Assign doctor using round-robin
- `getNextAvailableDoctor(specialty)` - Get doctor with lowest load
- `checkAndEscalateSLAViolations()` - Scheduled SLA monitoring
- `handleSLATimeout(assignmentId)` - Reassign on timeout
- `getDoctorAvailability(doctorId, date)` - Get availability slots
- `updateDoctorQualityScore(doctorId)` - Calculate score from reviews
- `getDoctorPerformanceMetrics(doctorId)` - Fetch performance dashboard
- `completeAssignment(assignmentId, completionData)` - Mark assignment done

**SLA Configuration:**
- Total SLA: 2 hours
- Escalation threshold: 1.5 hours
- Job frequency: Every 15 minutes

**Quality Score Thresholds:**
- Excellent: ≥ 4.5
- Good: ≥ 4.0
- Fair: ≥ 3.5
- Poor: < 3.5 (not assigned)

---

### 4. whatsapp-templates.json (445 lines)
**18 WhatsApp Business message templates**

**Template Categories:**

**Transactional Templates (12):**
- Order confirmation
- Doctor callback notification
- Prescription approved + shipping
- Prescription denied
- Shipment created
- Delivery confirmation
- Subscription paused/cancelled
- Doctor verification required
- Callback reminder
- SLA escalation
- Payment failed
- Consultation feedback

**Marketing Templates (6):**
- Day 25 refill reminder
- Referral code share
- Day 7 win-back message
- Day 14 win-back offer
- Day 30 final win-back
- Consultation feedback request

**Each Template Includes:**
- Category (TRANSACTIONAL/MARKETING)
- Dynamic parameters ({{variable}})
- Action buttons with URLs
- Localization support

**Implementation Notes:**
- Use Meta's WhatsApp Cloud API
- Pre-approval required from Meta
- Send via n8n HTTP nodes
- Track delivery status in database

---

### 5. database-schema.sql (924 lines)
**PostgreSQL schema for complete data model**

**14 Core Tables:**

1. **users** (634 records)
   - Customers, doctors, admins, support staff
   - Authentication, profiles, preferences
   - Verification status tracking

2. **doctors** (specialist network)
   - Specialty types and qualifications
   - Performance metrics (quality score, ratings)
   - Load capacity and availability
   - Consultation duration

3. **products** (pharmacy inventory)
   - Prescription vs OTC categorization
   - Strength, dosage, quantity tracking
   - Pricing, taxes, discounts
   - Stock management

4. **orders** (e-commerce transactions)
   - Order numbering and tracking
   - Payment integration (Razorpay)
   - Shipping addresses
   - Status workflow

5. **order_items** (line items)
   - Product quantities and pricing
   - Line total calculations

6. **prescriptions** (e-prescriptions)
   - Doctor issuance and approval
   - Medicine, dosage, duration
   - Validity and expiry tracking
   - Refill count

7. **subscriptions** (recurring refills)
   - Billing frequency and duration
   - Next refill date scheduling
   - Auto-retry payment tracking
   - Pause/resume functionality

8. **doctor_availability** (scheduling)
   - Time slots per doctor per day
   - Morning/afternoon/evening slots
   - Booked vs available count

9. **order_assignments** (doctor-to-order mapping)
   - Specialty and status tracking
   - SLA deadline and escalation
   - Completion timestamps

10. **callback_schedules** (consultation scheduling)
    - Scheduled callback times
    - Status (scheduled/in_progress/completed)
    - Callback notes

11. **shipments** (logistics tracking)
    - Tracking number and carrier
    - Status and label URL
    - Pickup/delivery timestamps

12. **consultation_reviews** (quality feedback)
    - 1-5 star ratings
    - Text feedback
    - Doctor performance tracking

13. **whatsapp_message_log** (communication history)
    - Template usage tracking
    - Delivery status (queued/sent/delivered/failed)
    - Context links to orders/subscriptions

14. **referrals** (growth mechanics)
    - Referrer and referred customer
    - Reward tracking and completion
    - Related order linking

**Additional Tables:**
- **winback_campaigns** - 3-stage win-back sequences
- **payments** - Payment history with Razorpay IDs
- **doctor_verifications** - 3rd refill verification
- **audit_logs** - Compliance and audit trail

**Enums:**
- user_role, specialty_type, order_status, prescription_status
- subscription_status, payment_status, assignment_status
- availability_status, message_status

**Indexes (25+):**
- Performance optimization on critical queries
- Fast lookups by status, date, customer, doctor

**Views (3):**
- v_customer_subscriptions - Active subscriptions per customer
- v_doctor_performance - Doctor metrics dashboard
- v_revenue_summary - Revenue analytics

**Triggers:**
- Auto-update timestamps on record changes

---

## Architecture Overview

```
┌─────────────────┐
│   Shopify       │
│   (e-commerce)  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│         n8n Automation Engine                    │
│  ├─ New Order Flow                              │
│  ├─ Doctor Callback Flow                        │
│  ├─ Fulfillment Flow                            │
│  ├─ Refill Flow                                 │
│  └─ Win-Back Flow                               │
└────────────┬────────────────────────────────────┘
             │
     ┌───────┼───────┐
     ▼       ▼       ▼
  ┌─────────────────────────────────┐
  │   Node.js/Express Backend       │
  │  ├─ Razorpay Integration        │
  │  ├─ Doctor Assignment Engine    │
  │  ├─ API Endpoints               │
  │  └─ Webhook Handlers            │
  └────────────┬────────────────────┘
               │
  ┌────────────┴────────────┐
  ▼                         ▼
┌──────────────────┐  ┌──────────────────┐
│  PostgreSQL DB   │  │  WhatsApp API    │
│  (2,500+ rows)   │  │  (messaging)     │
└──────────────────┘  └──────────────────┘
```

---

## Deployment Checklist

### Prerequisites
- Node.js 16+
- PostgreSQL 12+
- n8n instance
- Razorpay account (test/live keys)
- WhatsApp Business account
- Shopify store (optional)

### Environment Setup
```bash
# 1. Database
createdb arq_clinic
psql arq_clinic < database-schema.sql

# 2. Node dependencies
npm install express axios pg-pool crypto

# 3. Environment variables
RAZORPAY_KEY_ID=<key>
RAZORPAY_KEY_SECRET=<secret>
RAZORPAY_WEBHOOK_SECRET=<webhook_secret>
WHATSAPP_API_URL=https://graph.instagram.com/v18.0/
WHATSAPP_API_TOKEN=<token>
DATABASE_URL=postgresql://user:pass@localhost/arq_clinic
```

### n8n Workflow Import
1. Export workflows: `n8n-flows.json`
2. In n8n UI: Settings → Import Workflow
3. Configure credentials for each integration
4. Enable and activate workflows

### API Integration
```javascript
const razorpayRouter = require('./razorpay-integration');
const doctorAssignment = require('./doctor-assignment');

app.use('/api/payments', razorpayRouter);
app.use('/api/doctors', doctorAssignmentRoutes);
```

### Testing
```bash
# Test Razorpay integration
curl -X POST http://localhost:3000/api/payments/create-order \
  -H "Content-Type: application/json" \
  -d '{"customerId":"cust123","amount":500,"description":"Test order"}'

# Test doctor assignment
node test/doctor-assignment.test.js

# Test database schema
psql arq_clinic < test/schema-validation.sql
```

---

## Key Features Implemented

✓ Round-robin doctor assignment with load balancing
✓ 2-hour SLA tracking with 1.5-hour escalation alerts
✓ Quality scoring based on 5-star reviews (min 3.5 threshold)
✓ Payment processing with Razorpay custom checkout
✓ Signature verification (HMAC-SHA256)
✓ Subscription management (create, pause, resume, cancel)
✓ Auto-retry failed payments (exponential backoff)
✓ 5 complete n8n workflows (order, callback, fulfillment, refill, win-back)
✓ 18 WhatsApp message templates (transactional + marketing)
✓ Doctor availability calendar with slot management
✓ Prescription tracking and approval workflow
✓ Shipment tracking integration
✓ Referral program with reward tracking
✓ 3-stage win-back campaign automation
✓ Comprehensive audit logging

---

## Scalability Considerations

- **Database:** Connection pooling, read replicas for analytics
- **Doctor Assignment:** In-memory cache for availability updates
- **Webhooks:** Queue-based processing with exponential backoff
- **n8n:** Distributed execution, horizontal scaling
- **Payments:** Idempotent key handling for retry safety
- **WhatsApp:** Rate limiting and queue management

---

## Support & Documentation

For integration questions or issues:
- Check n8n node documentation for specific integrations
- Review Razorpay API docs: https://razorpay.com/docs/
- WhatsApp Cloud API: https://developers.facebook.com/docs/whatsapp/cloud-api/

---

**Status:** Production Ready
**Last Updated:** April 2024
**Version:** 1.0.0
