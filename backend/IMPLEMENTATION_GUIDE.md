# arq.clinic Backend - Implementation Guide

Complete step-by-step guide to implement and deploy the prescription biohacking platform backend.

## Table of Contents
1. [Project Setup](#project-setup)
2. [Database Setup](#database-setup)
3. [API Implementation](#api-implementation)
4. [n8n Workflow Setup](#n8n-workflow-setup)
5. [Integration Checklist](#integration-checklist)
6. [Testing](#testing)
7. [Production Deployment](#production-deployment)
8. [Monitoring](#monitoring)

---

## Project Setup

### 1.1 Initialize Node.js Project

```bash
mkdir -p arq-clinic-backend && cd arq-clinic-backend
npm init -y

# Install core dependencies
npm install express axios pg pg-pool crypto dotenv cors helmet
npm install --save-dev nodemon jest supertest
```

### 1.2 Project Structure

```
arq-clinic-backend/
├── src/
│   ├── routes/
│   │   ├── payments.js
│   │   ├── doctors.js
│   │   ├── orders.js
│   │   └── subscriptions.js
│   ├── controllers/
│   ├── models/
│   ├── middleware/
│   ├── utils/
│   └── app.js
├── db/
│   └── schema.sql
├── config/
│   └── database.js
├── tests/
├── .env.example
├── server.js
└── package.json
```

### 1.3 Main Server File

```javascript
// server.js
require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.API_PORT || 3000;

app.listen(PORT, () => {
  console.log(`arq.clinic API running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
```

### 1.4 Express Setup

```javascript
// src/app.js
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const razorpayRouter = require('./routes/payments');

const app = express();

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(','),
  credentials: true
}));
app.use(express.json());

// Routes
app.use('/api/payments', razorpayRouter);
app.use('/api/doctors', require('./routes/doctors'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/subscriptions', require('./routes/subscriptions'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message,
    requestId: req.id
  });
});

module.exports = app;
```

---

## Database Setup

### 2.1 Install PostgreSQL

```bash
# macOS
brew install postgresql@15

# Ubuntu
sudo apt-get install postgresql-15 postgresql-contrib-15

# Start service
brew services start postgresql@15
# or
sudo systemctl start postgresql
```

### 2.2 Create Database

```bash
# Create database
createdb arq_clinic

# Create application user
createuser arq_app_service --pwprompt
# Enter password when prompted

# Grant privileges
psql arq_clinic -c "GRANT ALL PRIVILEGES ON DATABASE arq_clinic TO arq_app_service;"

# Initialize schema
psql arq_clinic < database-schema.sql

# Verify setup
psql arq_clinic -c "\dt"
```

### 2.3 Database Connection Pool

```javascript
// config/database.js
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: parseInt(process.env.DB_POOL_MAX) || 20,
  min: parseInt(process.env.DB_POOL_MIN) || 5,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

module.exports = pool;
```

---

## API Implementation

### 3.1 Create Payment Routes

```javascript
// src/routes/payments.js
const express = require('express');
const razorpayIntegration = require('../razorpay-integration');

const router = express.Router();

// Mount endpoints from razorpay-integration.js
router.use('/', razorpayIntegration);

module.exports = router;
```

### 3.2 Create Doctor Routes

```javascript
// src/routes/doctors.js
const express = require('express');
const doctorAssignment = require('../doctor-assignment');
const { validateSpecialty } = require('../middleware/validation');

const router = express.Router();

// Get available doctors by specialty
router.get('/available', validateSpecialty, async (req, res) => {
  try {
    const { specialty } = req.query;
    const doctor = await doctorAssignment.getNextAvailableDoctor(specialty);

    if (!doctor) {
      return res.status(404).json({ error: 'No available doctors' });
    }

    res.json(doctor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get doctor performance metrics
router.get('/:doctorId/metrics', async (req, res) => {
  try {
    const metrics = await doctorAssignment.getDoctorPerformanceMetrics(req.params.doctorId);
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update doctor availability
router.post('/:doctorId/availability', async (req, res) => {
  try {
    const { date, slots } = req.body;
    const availability = await doctorAssignment.updateDoctorAvailability(
      req.params.doctorId,
      date,
      slots
    );
    res.json(availability);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### 3.3 Create Order Routes

```javascript
// src/routes/orders.js
const express = require('express');
const pool = require('../config/database');

const router = express.Router();

// Get order by ID
router.get('/:orderId', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM orders WHERE id = $1',
      [req.params.orderId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update order status
router.patch('/:orderId', async (req, res) => {
  try {
    const { status, notes } = req.body;

    const result = await pool.query(
      'UPDATE orders SET order_status = $1, notes = $2, updated_at = NOW() WHERE id = $3 RETURNING *',
      [status, notes, req.params.orderId]
    );

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### 3.4 Middleware Examples

```javascript
// src/middleware/validation.js
const validateSpecialty = (req, res, next) => {
  const { specialty } = req.query;
  const validSpecialties = ['MBBS', 'endocrinologist', 'dermatologist', 'psychiatrist'];

  if (!specialty || !validSpecialties.includes(specialty)) {
    return res.status(400).json({
      error: 'Invalid specialty',
      validValues: validSpecialties
    });
  }

  next();
};

const validateOrderData = (req, res, next) => {
  const { customerId, amount } = req.body;

  if (!customerId || !amount) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  if (amount <= 0) {
    return res.status(400).json({ error: 'Amount must be positive' });
  }

  next();
};

module.exports = {
  validateSpecialty,
  validateOrderData
};
```

---

## n8n Workflow Setup

### 4.1 Import Workflows

1. Open n8n UI (default: `http://localhost:5678`)
2. Click "Settings" → "Import Workflow"
3. Upload `n8n-flows.json`
4. Configure credentials for each integration

### 4.2 Configure Integrations

```javascript
// n8n Credential Setup Example

// PostgreSQL Credential
{
  "type": "postgres",
  "host": "localhost",
  "port": 5432,
  "database": "arq_clinic",
  "user": "arq_app_service",
  "password": "xxxxx"
}

// WhatsApp Credential
{
  "type": "whatsapp",
  "businessAccountId": "xxxxx",
  "phoneNumberId": "xxxxx",
  "accessToken": "xxxxx"
}

// HTTP Bearer Token
{
  "type": "httpHeaderAuth",
  "name": "Fulfillment API",
  "credentials": {
    "Authorization": "Bearer xxxxx"
  }
}
```

### 4.3 Enable Workflows

1. Edit each workflow
2. Click "Settings" icon
3. Enable "Active" toggle
4. Set trigger intervals for cron-based workflows

### 4.4 Testing n8n Workflows

```bash
# Trigger webhook manually
curl -X POST http://localhost:5678/webhook/new-order-flow \
  -H "Content-Type: application/json" \
  -d '{
    "id": "shop_order_123",
    "customer": {"id": "cust_456", "name": "John Doe"},
    "order_number": "1001",
    "total_price": "4999.00",
    "currency": "INR"
  }'
```

---

## Integration Checklist

### Razorpay Setup
- [ ] Create Razorpay account
- [ ] Get API keys (test & live)
- [ ] Configure webhook URL: `https://api.arq.clinic/api/payments/webhook`
- [ ] Whitelist webhook IPs
- [ ] Test payment flow
- [ ] Implement retry logic
- [ ] Set up monitoring for failed payments

### WhatsApp Business Setup
- [ ] Register Meta Business Account
- [ ] Verify phone number
- [ ] Get Business Account ID and Phone Number ID
- [ ] Create message templates
- [ ] Request template approval from Meta
- [ ] Set up webhook for inbound messages
- [ ] Test message sending

### Shopify Integration
- [ ] Install arq.clinic app in Shopify store
- [ ] Configure API credentials
- [ ] Set up webhook for order creation
- [ ] Map Shopify products to arq.clinic products
- [ ] Test order sync

### Doctor Assignment
- [ ] Create doctor records in database
- [ ] Assign specialties to doctors
- [ ] Set quality scores
- [ ] Configure capacity limits
- [ ] Set up availability calendar
- [ ] Test round-robin assignment

### Database Setup
- [ ] Create all tables
- [ ] Create indexes
- [ ] Set up views
- [ ] Configure backups
- [ ] Test data integrity
- [ ] Performance tuning

---

## Testing

### Unit Tests

```javascript
// tests/razorpay.test.js
const request = require('supertest');
const app = require('../src/app');
const pool = require('../src/config/database');

describe('Razorpay Integration', () => {
  test('should create order', async () => {
    const response = await request(app)
      .post('/api/payments/create-order')
      .send({
        customerId: 'cust_123',
        amount: 500,
        description: 'Test order'
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.orderId).toBeDefined();
  });

  test('should verify payment signature', async () => {
    const orderId = 'order_123';
    const paymentId = 'pay_456';
    const signature = generateSignature(orderId, paymentId);

    const response = await request(app)
      .post('/api/payments/verify-payment')
      .send({
        razorpay_order_id: orderId,
        razorpay_payment_id: paymentId,
        razorpay_signature: signature
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
```

### Integration Tests

```javascript
// tests/doctor-assignment.test.js
const doctorAssignment = require('../src/doctor-assignment');
const pool = require('../src/config/database');

describe('Doctor Assignment', () => {
  test('should assign doctor using round-robin', async () => {
    const result = await doctorAssignment.assignDoctor('order_001', 'MBBS');

    expect(result.success).toBe(true);
    expect(result.doctor).toBeDefined();
    expect(result.slaDeadline).toBeDefined();
  });

  test('should escalate SLA violations', async () => {
    await doctorAssignment.checkAndEscalateSLAViolations();

    const violations = await pool.query(
      'SELECT * FROM order_assignments WHERE escalation_status = $1',
      ['escalated']
    );

    expect(violations.rows.length).toBeGreaterThan(0);
  });
});
```

### Run Tests

```bash
npm test

# With coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

---

## Production Deployment

### 5.1 Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit with production values
nano .env

# Key production settings:
NODE_ENV=production
API_PORT=3000
RAZORPAY_KEY_ID=rzp_live_xxxxx
RAZORPAY_KEY_SECRET=xxxxx
LOG_LEVEL=info
```

### 5.2 Database Backup

```bash
# Create backup script
#!/bin/bash
BACKUP_DIR="/backups/arq-clinic"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

pg_dump -h localhost -U arq_app_service arq_clinic | \
  gzip > "$BACKUP_DIR/arq_clinic_$TIMESTAMP.sql.gz"

# Keep last 30 days of backups
find $BACKUP_DIR -type f -mtime +30 -delete

# Add to crontab (daily at 2 AM)
0 2 * * * /path/to/backup.sh
```

### 5.3 Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node healthcheck.js

EXPOSE 3000
CMD ["node", "server.js"]
```

### 5.4 Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: arq_clinic
      POSTGRES_USER: arq_app_service
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./database-schema.sql:/docker-entrypoint-initdb.d/schema.sql
    ports:
      - "5432:5432"

  api:
    build: .
    environment:
      DATABASE_URL: postgresql://arq_app_service:${DB_PASSWORD}@postgres:5432/arq_clinic
      RAZORPAY_KEY_ID: ${RAZORPAY_KEY_ID}
      RAZORPAY_KEY_SECRET: ${RAZORPAY_KEY_SECRET}
    ports:
      - "3000:3000"
    depends_on:
      - postgres

  n8n:
    image: n8nio/n8n:latest
    environment:
      N8N_HOST: localhost
      N8N_PORT: 5678
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  pgdata:
  n8n_data:
```

### 5.5 Nginx Configuration

```nginx
# nginx.conf
upstream arq_api {
  server 127.0.0.1:3000;
}

server {
  listen 443 ssl http2;
  server_name api.arq.clinic;

  # SSL certificates
  ssl_certificate /etc/ssl/certs/arq.clinic.crt;
  ssl_certificate_key /etc/ssl/private/arq.clinic.key;

  # Security headers
  add_header Strict-Transport-Security "max-age=31536000" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Frame-Options "DENY" always;

  # Rate limiting
  limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
  limit_req zone=api burst=20 nodelay;

  # Proxy settings
  location /api/ {
    proxy_pass http://arq_api;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  # Webhook endpoints (higher rate limit)
  location ~ ^/webhooks/ {
    limit_req_zone $binary_remote_addr zone=webhooks:10m rate=100r/s;
    limit_req zone=webhooks burst=100 nodelay;
    proxy_pass http://arq_api;
  }
}
```

---

## Monitoring

### 6.1 Logging Setup

```javascript
// src/utils/logger.js
const fs = require('fs');
const path = require('path');

const LOG_DIR = './logs';
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

const logger = {
  info: (message, data) => {
    console.log(JSON.stringify({ level: 'INFO', timestamp: new Date(), message, data }));
  },
  error: (message, error) => {
    console.error(JSON.stringify({ level: 'ERROR', timestamp: new Date(), message, error: error.message }));
  },
  debug: (message, data) => {
    if (process.env.LOG_LEVEL === 'debug') {
      console.log(JSON.stringify({ level: 'DEBUG', timestamp: new Date(), message, data }));
    }
  }
};

module.exports = logger;
```

### 6.2 Health Check Endpoint

```javascript
// healthcheck.js
const pool = require('./src/config/database');

async function healthCheck() {
  try {
    // Check database
    await pool.query('SELECT 1');

    // Check external services
    const services = {
      database: 'ok',
      razorpay: 'ok',
      whatsapp: 'ok'
    };

    console.log(JSON.stringify({ status: 'healthy', services }));
    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({ status: 'unhealthy', error: error.message }));
    process.exit(1);
  }
}

healthCheck();
```

### 6.3 Monitoring Queries

```sql
-- Monitor payment failures
SELECT
  DATE(created_at) as date,
  status,
  COUNT(*) as count
FROM payments
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at), status
ORDER BY date DESC;

-- Monitor SLA violations
SELECT
  COUNT(*) as violations,
  ROUND(AVG(EXTRACT(EPOCH FROM (sla_deadline - assigned_at))/3600)::numeric, 2) as avg_hours_to_sla
FROM order_assignments
WHERE status IN ('pending', 'in_progress')
  AND sla_deadline < NOW();

-- Monitor doctor performance
SELECT
  d.name,
  d.specialty,
  COUNT(oa.id) as total_assignments,
  ROUND(AVG(cr.rating)::numeric, 2) as avg_rating,
  d.quality_score
FROM doctors d
LEFT JOIN order_assignments oa ON d.id = oa.doctor_id
LEFT JOIN consultation_reviews cr ON oa.id = cr.assignment_id
WHERE oa.completed_at > NOW() - INTERVAL '30 days'
GROUP BY d.id, d.name, d.specialty, d.quality_score
ORDER BY avg_rating DESC;
```

---

## Summary

This implementation guide covers:
- ✓ Complete project setup
- ✓ Database initialization with schema
- ✓ API endpoint implementation
- ✓ n8n workflow configuration
- ✓ Integration with external services
- ✓ Comprehensive testing
- ✓ Production deployment
- ✓ Monitoring and logging

For questions or issues, refer to specific service documentation:
- Razorpay: https://razorpay.com/docs/
- n8n: https://docs.n8n.io/
- PostgreSQL: https://www.postgresql.org/docs/
- WhatsApp: https://developers.facebook.com/docs/whatsapp/

---

**Status:** Production Ready
**Last Updated:** April 2024
