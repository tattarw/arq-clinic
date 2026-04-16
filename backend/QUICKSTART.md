# arq.clinic Backend - Quick Start Guide

Get the arq.clinic backend running in 15 minutes.

## Prerequisites
- Node.js 16+
- PostgreSQL 12+
- Git
- Postman or cURL (for testing)

## Step 1: Database Setup (5 minutes)

```bash
# Create database
createdb arq_clinic

# Create user
createuser arq_app_service --pwprompt
# Password: any_secure_password

# Grant permissions
psql arq_clinic -c "GRANT ALL PRIVILEGES ON DATABASE arq_clinic TO arq_app_service;"

# Initialize schema
psql arq_clinic < database-schema.sql

# Verify (should show 15+ tables)
psql arq_clinic -c "\dt"
```

## Step 2: Project Setup (3 minutes)

```bash
# Install dependencies
npm install express axios pg pg-pool crypto dotenv cors helmet

# Copy environment
cp .env.example .env

# Edit .env with your values
# At minimum, set:
# DATABASE_URL=postgresql://arq_app_service:password@localhost:5432/arq_clinic
# RAZORPAY_KEY_ID=rzp_test_xxxxx
# RAZORPAY_KEY_SECRET=xxxxx
```

## Step 3: Create Application File (2 minutes)

Create `src/app.js`:
```javascript
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Load razorpay integration
const razorpayRouter = require('./razorpay-integration');
app.use('/api/payments', razorpayRouter);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

module.exports = app;
```

Create `server.js`:
```javascript
const app = require('./src/app');
const PORT = process.env.API_PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

## Step 4: Run Application (2 minutes)

```bash
# Start server
npm start
# or
node server.js

# Test health endpoint
curl http://localhost:3000/health
# Expected: {"status":"ok"}
```

## Step 5: Test Razorpay Integration (3 minutes)

```bash
# Create order
curl -X POST http://localhost:3000/api/payments/create-order \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "cust_123",
    "amount": 500,
    "description": "Test order"
  }'

# Response should include:
# {
#   "success": true,
#   "orderId": "order_xxx",
#   "amount": 50000,
#   "status": "created"
# }
```

## Next Steps

1. **Configure Webhooks**
   - Set `RAZORPAY_WEBHOOK_SECRET` in .env
   - Configure webhook URL in Razorpay dashboard

2. **Set Up n8n Workflows**
   - Launch n8n: `docker run -it -p 5678:5678 n8nio/n8n`
   - Import `n8n-flows.json`
   - Configure credentials

3. **Configure WhatsApp**
   - Set `WHATSAPP_API_TOKEN` in .env
   - Create and approve message templates

4. **Implement Routes**
   - Create `/src/routes/doctors.js`
   - Create `/src/routes/orders.js`
   - Create `/src/routes/subscriptions.js`

5. **Run Tests**
   - Add jest: `npm install --save-dev jest`
   - Create tests in `/tests` directory
   - Run: `npm test`

## Key Files

| File | Purpose | Lines |
|------|---------|-------|
| `razorpay-integration.js` | Payment processing | 654 |
| `doctor-assignment.js` | Doctor network management | 639 |
| `database-schema.sql` | PostgreSQL schema | 924 |
| `n8n-flows.json` | Automation workflows | 1,081 |
| `whatsapp-templates.json` | Message templates | 445 |

## Environment Variables (Minimum)

```bash
# Database
DATABASE_URL=postgresql://arq_app_service:password@localhost:5432/arq_clinic

# Razorpay
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=xxxxx
RAZORPAY_WEBHOOK_SECRET=xxxxx

# API
API_PORT=3000
NODE_ENV=development
```

## Troubleshooting

**Database connection error:**
```bash
# Verify user exists
psql -l | grep arq_clinic

# Check credentials
psql -h localhost -U arq_app_service -d arq_clinic -c "SELECT 1"
```

**Port already in use:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

**Module not found:**
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

## API Endpoints (Quick Reference)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/payments/create-order` | Create Razorpay order |
| POST | `/api/payments/verify-payment` | Verify payment signature |
| POST | `/api/subscriptions/create` | Create subscription |
| POST | `/api/subscriptions/:id/cancel` | Cancel subscription |
| POST | `/webhooks/razorpay` | Razorpay webhook |

## Performance Checklist

- [ ] Database indexes created (25+ indexes)
- [ ] Connection pooling configured (min:5, max:20)
- [ ] Logging implemented
- [ ] Error handling in place
- [ ] CORS configured
- [ ] Rate limiting enabled
- [ ] Input validation added
- [ ] Environment variables secured

## Production Checklist

- [ ] Update RAZORPAY_KEY_ID to production key
- [ ] Set NODE_ENV=production
- [ ] Enable HTTPS (SSL certificates)
- [ ] Configure database backups
- [ ] Set up monitoring
- [ ] Configure security headers
- [ ] Implement rate limiting
- [ ] Enable CORS for production domain
- [ ] Set up error tracking (Sentry)
- [ ] Configure log aggregation

## Next Resources

- **Razorpay Docs:** https://razorpay.com/docs/
- **n8n Docs:** https://docs.n8n.io/
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **Express.js:** https://expressjs.com/
- **WhatsApp API:** https://developers.facebook.com/docs/whatsapp/

## Support

For issues:
1. Check logs: `tail -f logs/app.log`
2. Verify environment variables: `cat .env`
3. Test database connection: `psql $DATABASE_URL -c "SELECT 1"`
4. Review error messages in console

---

**Time to Production:** ~15 minutes
**Estimated Setup Complexity:** Low
**Maintenance Effort:** Medium

Good luck with your arq.clinic implementation!
