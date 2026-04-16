/**
 * Razorpay Integration Module
 * Handles payment processing, order creation, verification, and subscription management
 * for arq.clinic's prescription biohacking platform
 */

const express = require('express');
const crypto = require('crypto');
const axios = require('axios');
const router = express.Router();

// Environment configuration
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET;
const RAZORPAY_API_URL = 'https://api.razorpay.com/v1';
const WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET;

// Base64 encode credentials for API calls
const auth = Buffer.from(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`).toString('base64');

/**
 * Create an order in Razorpay
 * POST /api/payments/create-order
 */
router.post('/create-order', async (req, res) => {
  try {
    const {
      customerId,
      amount,
      currency = 'INR',
      description,
      notes = {},
      receipt,
      customer_email,
      customer_notify = 1
    } = req.body;

    // Validate required fields
    if (!amount || !customerId) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: amount, customerId'
      });
    }

    // Amount in paise (INR smallest unit)
    const amountInPaise = Math.round(amount * 100);

    const orderPayload = {
      amount: amountInPaise,
      currency,
      receipt: receipt || `order_${customerId}_${Date.now()}`,
      description,
      notes: {
        ...notes,
        customerId,
        createdAt: new Date().toISOString()
      },
      customer_notify
    };

    if (customer_email) {
      orderPayload.customer_notify = customer_notify;
    }

    const response = await axios.post(`${RAZORPAY_API_URL}/orders`, orderPayload, {
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/json'
      }
    });

    // Log order creation
    console.log(`Order created: ${response.data.id} for customer ${customerId}`);

    res.json({
      success: true,
      orderId: response.data.id,
      amount: response.data.amount,
      currency: response.data.currency,
      status: response.data.status
    });
  } catch (error) {
    console.error('Order creation error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to create order',
      details: error.response?.data?.description || error.message
    });
  }
});

/**
 * Verify payment signature after payment completion
 * POST /api/payments/verify-payment
 */
router.post('/verify-payment', async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        success: false,
        error: 'Missing payment verification fields'
      });
    }

    // Verify signature
    const generatedSignature = crypto
      .createHmac('sha256', RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature !== razorpay_signature) {
      return res.status(400).json({
        success: false,
        error: 'Invalid payment signature'
      });
    }

    // Fetch payment details for validation
    const paymentDetails = await axios.get(
      `${RAZORPAY_API_URL}/payments/${razorpay_payment_id}`,
      {
        headers: { Authorization: `Basic ${auth}` }
      }
    );

    if (paymentDetails.data.status !== 'captured') {
      return res.status(400).json({
        success: false,
        error: 'Payment not captured',
        status: paymentDetails.data.status
      });
    }

    console.log(`Payment verified: ${razorpay_payment_id} for order ${razorpay_order_id}`);

    res.json({
      success: true,
      paymentId: razorpay_payment_id,
      orderId: razorpay_order_id,
      amount: paymentDetails.data.amount / 100, // Convert paise to rupees
      status: paymentDetails.data.status,
      method: paymentDetails.data.method
    });
  } catch (error) {
    console.error('Payment verification error:', error.message);
    res.status(500).json({
      success: false,
      error: 'Payment verification failed',
      details: error.message
    });
  }
});

/**
 * Create a subscription plan
 * POST /api/subscriptions/create-plan
 */
router.post('/create-plan', async (req, res) => {
  try {
    const {
      period = 'monthly',
      interval = 1,
      period_count = 12,
      amount,
      currency = 'INR',
      notes = {}
    } = req.body;

    if (!amount) {
      return res.status(400).json({
        success: false,
        error: 'Missing required field: amount'
      });
    }

    const amountInPaise = Math.round(amount * 100);

    const planPayload = {
      period,
      interval,
      period_count,
      amount: amountInPaise,
      currency_code: currency,
      notes: {
        ...notes,
        createdAt: new Date().toISOString()
      }
    };

    const response = await axios.post(`${RAZORPAY_API_URL}/plans`, planPayload, {
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/json'
      }
    });

    console.log(`Subscription plan created: ${response.data.id}`);

    res.json({
      success: true,
      planId: response.data.id,
      amount: response.data.amount / 100,
      period: response.data.period,
      interval: response.data.interval
    });
  } catch (error) {
    console.error('Plan creation error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to create subscription plan',
      details: error.response?.data?.description || error.message
    });
  }
});

/**
 * Create a subscription
 * POST /api/subscriptions/create
 */
router.post('/create', async (req, res) => {
  try {
    const {
      planId,
      customerId,
      customer_email,
      customer_phone,
      quantity = 1,
      total_count = 12,
      start_at,
      notes = {},
      max_retries = 3
    } = req.body;

    if (!planId || !customerId) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: planId, customerId'
      });
    }

    const subscriptionPayload = {
      plan_id: planId,
      customer_notify: 1,
      quantity,
      total_count,
      notes: {
        ...notes,
        customerId,
        createdAt: new Date().toISOString()
      }
    };

    if (start_at) {
      subscriptionPayload.start_at = Math.floor(new Date(start_at).getTime() / 1000);
    }

    const response = await axios.post(
      `${RAZORPAY_API_URL}/subscriptions`,
      subscriptionPayload,
      {
        headers: {
          Authorization: `Basic ${auth}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log(`Subscription created: ${response.data.id} for customer ${customerId}`);

    res.json({
      success: true,
      subscriptionId: response.data.id,
      customerId: response.data.customer_id,
      status: response.data.status,
      nextPaymentAt: new Date(response.data.paid_count * 1000)
    });
  } catch (error) {
    console.error('Subscription creation error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to create subscription',
      details: error.response?.data?.description || error.message
    });
  }
});

/**
 * Cancel a subscription
 * POST /api/subscriptions/:subscriptionId/cancel
 */
router.post('/:subscriptionId/cancel', async (req, res) => {
  try {
    const { subscriptionId } = req.params;
    const { reason, notes = {} } = req.body;

    if (!subscriptionId) {
      return res.status(400).json({
        success: false,
        error: 'Subscription ID required'
      });
    }

    const payload = {
      notes: {
        ...notes,
        cancelledAt: new Date().toISOString(),
        reason
      }
    };

    const response = await axios.post(
      `${RAZORPAY_API_URL}/subscriptions/${subscriptionId}/cancel`,
      payload,
      {
        headers: {
          Authorization: `Basic ${auth}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log(`Subscription cancelled: ${subscriptionId}`);

    res.json({
      success: true,
      subscriptionId: response.data.id,
      status: response.data.status
    });
  } catch (error) {
    console.error('Subscription cancellation error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to cancel subscription',
      details: error.response?.data?.description || error.message
    });
  }
});

/**
 * Pause a subscription
 * POST /api/subscriptions/:subscriptionId/pause
 */
router.post('/:subscriptionId/pause', async (req, res) => {
  try {
    const { subscriptionId } = req.params;
    const { pause_at = 0, notes = {} } = req.body; // pause_at = 0 pauses immediately

    const payload = {
      pause_at,
      notes: {
        ...notes,
        pausedAt: new Date().toISOString()
      }
    };

    const response = await axios.post(
      `${RAZORPAY_API_URL}/subscriptions/${subscriptionId}/pause`,
      payload,
      {
        headers: {
          Authorization: `Basic ${auth}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log(`Subscription paused: ${subscriptionId}`);

    res.json({
      success: true,
      subscriptionId: response.data.id,
      status: response.data.status,
      pausedAt: response.data.paused_at
    });
  } catch (error) {
    console.error('Subscription pause error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to pause subscription',
      details: error.response?.data?.description || error.message
    });
  }
});

/**
 * Resume a paused subscription
 * POST /api/subscriptions/:subscriptionId/resume
 */
router.post('/:subscriptionId/resume', async (req, res) => {
  try {
    const { subscriptionId } = req.params;
    const { notes = {} } = req.body;

    const payload = {
      notes: {
        ...notes,
        resumedAt: new Date().toISOString()
      }
    };

    const response = await axios.post(
      `${RAZORPAY_API_URL}/subscriptions/${subscriptionId}/resume`,
      payload,
      {
        headers: {
          Authorization: `Basic ${auth}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log(`Subscription resumed: ${subscriptionId}`);

    res.json({
      success: true,
      subscriptionId: response.data.id,
      status: response.data.status
    });
  } catch (error) {
    console.error('Subscription resume error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to resume subscription',
      details: error.response?.data?.description || error.message
    });
  }
});

/**
 * Webhook handler for Razorpay events
 * POST /api/payments/webhook
 */
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const body = req.body.toString();
    const signature = req.headers['x-razorpay-signature'];

    // Verify webhook signature
    const generatedSignature = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(body)
      .digest('hex');

    if (generatedSignature !== signature) {
      console.warn('Invalid webhook signature');
      return res.status(400).json({ success: false, error: 'Invalid signature' });
    }

    const event = JSON.parse(body);
    console.log(`Webhook received: ${event.event}`);

    // Handle different webhook events
    switch (event.event) {
      case 'payment.authorized':
        await handlePaymentAuthorized(event.payload);
        break;

      case 'payment.failed':
        await handlePaymentFailed(event.payload);
        break;

      case 'payment.captured':
        await handlePaymentCaptured(event.payload);
        break;

      case 'subscription.charged':
        await handleSubscriptionCharged(event.payload);
        break;

      case 'subscription.completed':
        await handleSubscriptionCompleted(event.payload);
        break;

      case 'subscription.halted':
        await handleSubscriptionHalted(event.payload);
        break;

      case 'refund.created':
        await handleRefundCreated(event.payload);
        break;

      case 'refund.failed':
        await handleRefundFailed(event.payload);
        break;

      default:
        console.log(`Unhandled event: ${event.event}`);
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Webhook processing error:', error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Handle payment.authorized event
 * Triggered when payment is authorized (before capture)
 */
async function handlePaymentAuthorized(payload) {
  const { payment } = payload;
  console.log(`Payment authorized: ${payment.id}, Amount: ${payment.amount / 100}`);
  // Update order status in database
  // Trigger notification to customer
}

/**
 * Handle payment.failed event
 * Triggered when payment fails
 */
async function handlePaymentFailed(payload) {
  const { payment } = payload;
  console.error(
    `Payment failed: ${payment.id}, Reason: ${payment.description}, Error: ${payment.error_code}`
  );
  // Update order status to failed
  // Trigger retry logic
  // Notify customer with failure reason
}

/**
 * Handle payment.captured event
 * Triggered when payment is successfully captured
 */
async function handlePaymentCaptured(payload) {
  const { payment } = payload;
  console.log(`Payment captured: ${payment.id}, Amount: ${payment.amount / 100}`);
  // Update order status to confirmed
  // Trigger order processing (doctor assignment, etc.)
  // Send confirmation notification
}

/**
 * Handle subscription.charged event
 * Triggered when subscription payment is charged
 */
async function handleSubscriptionCharged(payload) {
  const { subscription, payment } = payload;
  console.log(`Subscription charged: ${subscription.id}, Payment: ${payment.id}`);
  // Update subscription status
  // Create order for refill
  // Trigger refill workflow
}

/**
 * Handle subscription.completed event
 * Triggered when subscription reaches its end
 */
async function handleSubscriptionCompleted(payload) {
  const { subscription } = payload;
  console.log(`Subscription completed: ${subscription.id}`);
  // Update subscription status to completed
  // Trigger win-back flow
}

/**
 * Handle subscription.halted event
 * Triggered when subscription is halted due to payment failure
 */
async function handleSubscriptionHalted(payload) {
  const { subscription } = payload;
  console.error(`Subscription halted: ${subscription.id}`);
  // Update subscription status to halted
  // Trigger retry logic with exponential backoff
  // Send notification to customer
}

/**
 * Handle refund.created event
 * Triggered when refund is initiated
 */
async function handleRefundCreated(payload) {
  const { refund } = payload;
  console.log(`Refund created: ${refund.id}, Amount: ${refund.amount / 100}`);
  // Update payment status to refunded
  // Send refund confirmation to customer
}

/**
 * Handle refund.failed event
 * Triggered when refund fails
 */
async function handleRefundFailed(payload) {
  const { refund } = payload;
  console.error(`Refund failed: ${refund.id}`);
  // Log refund failure
  // Notify admin/support team
  // Create support ticket
}

/**
 * Auto-retry failed subscription payments
 * Should be called by a scheduled job (e.g., every 6 hours)
 */
async function retryFailedSubscriptions() {
  try {
    console.log('Starting subscription retry job...');

    // Fetch all halted subscriptions from database
    // For each subscription with failed payments:
    // 1. Check last payment failure time
    // 2. Calculate retry count
    // 3. If retries < MAX_RETRIES, trigger payment retry
    // 4. Use exponential backoff: retry after 1h, 6h, 24h, 72h

    // Example structure:
    const failedSubscriptions = await getFailedSubscriptionsFromDB();

    for (const subscription of failedSubscriptions) {
      const lastFailureTime = new Date(subscription.lastFailureAt);
      const timeSinceFailure = Date.now() - lastFailureTime.getTime();
      const retryInterval = calculateRetryInterval(subscription.retryCount);

      if (timeSinceFailure >= retryInterval) {
        try {
          // Retry payment
          console.log(`Retrying payment for subscription ${subscription.id}`);
          // Call Razorpay API to retry payment
        } catch (error) {
          console.error(`Retry failed for subscription ${subscription.id}:`, error.message);
        }
      }
    }
  } catch (error) {
    console.error('Subscription retry job error:', error.message);
  }
}

/**
 * Calculate exponential backoff interval
 */
function calculateRetryInterval(retryCount) {
  const intervals = {
    0: 60 * 60 * 1000, // 1 hour
    1: 6 * 60 * 60 * 1000, // 6 hours
    2: 24 * 60 * 60 * 1000, // 24 hours
    3: 72 * 60 * 60 * 1000 // 72 hours
  };
  return intervals[retryCount] || intervals[3];
}

/**
 * Placeholder function - implement with your database
 */
async function getFailedSubscriptionsFromDB() {
  // Query database for halted subscriptions
  return [];
}

module.exports = router;
