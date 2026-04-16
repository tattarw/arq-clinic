# arq.clinic — Shopify Implementation Guide
Dear One Technologies Pvt Ltd | Version 1.0

---

## Theme File Structure

```
arq-shopify/
├── layout/
│   └── theme.liquid              ← Master layout, loads all CSS/JS
├── templates/
│   ├── index.liquid              ← Homepage — search-first hero
│   ├── product.liquid            ← Product page — full protocol view
│   ├── collection.liquid         ← Browse/collection pages
│   └── customers/
│       ├── account.liquid        ← Account dashboard
│       ├── login.liquid          ← Login page
│       ├── register.liquid       ← Register page
│       └── order.liquid          ← Order detail page
├── sections/
│   └── (section files)
├── snippets/
│   ├── nav.liquid                ← Navigation + search overlay
│   ├── footer-and-modal.liquid   ← Footer + WhatsApp modal
│   ├── cart-drawer.liquid        ← Slide-in cart + Razorpay checkout
│   └── product-card.liquid       ← Product card component
├── assets/
│   └── arq.css                   ← Full design system
└── config/
    └── settings_schema.json      ← Theme settings
```

---

## Shopify Setup Checklist

### 1. Shopify Store Setup
- [ ] Create Shopify store at arq.clinic (or custom domain)
- [ ] Connect arq.clinic domain in Shopify admin → Domains
- [ ] Set currency to INR
- [ ] Disable default Shopify checkout branding
- [ ] Enable customer accounts (required)
- [ ] Install theme files

### 2. Product Metafields (critical)
Create these metafields in Shopify Admin → Settings → Custom data → Products:

| Namespace | Key | Type | Description |
|---|---|---|---|
| arq | doctor_type | Single line text | "MBBS physician" / "Endocrinologist" / "Psychiatrist" |
| arq | blood_required | True/false | Whether blood test is needed |
| arq | kit_name | Single line text | "arq / focus" etc. |
| arq | dose | Single line text | "200mg" / "30 tabs" etc. |
| arq | legal_status | Multi-line text | Legal classification description |
| arq | short_desc | Multi-line text | 80-char description for cards |
| arq | consult_time | Single line text | "2 hours" |
| arq | delivery_time | Single line text | "48 hours" |
| arq | subscription | True/false | Whether subscription is available |
| arq | related_products | Single line text | Comma-separated product handles |

### 3. Product Collections
Create these collections (smart collections by tag):

- **all** — all products
- **cognition** — tag: cognition
- **performance** — tag: performance
- **longevity** — tag: longevity
- **peptides** — tag: peptide
- **body** — tag: body
- **feel-protect** — tag: feel-protect

### 4. Product Tags (apply to each product)
Each product needs:
- Category tag: `cognition` / `performance` / `longevity` / `peptide` / `body` / `feel-protect`
- Doctor type: `mbbs` / `endocrinologist` / `psychiatrist` / `bams`
- If blood required: `blood-required`
- If peptide: `peptide`
- If grey zone: `physician-supervised`
- Type field: set to category name (Cognition / Performance / etc.)

---

## Razorpay Integration

### Architecture
```
Customer buys → Shopify cart
→ Cart drawer opens → "Checkout securely"
→ Your custom app creates Razorpay order via API
→ Razorpay checkout opens (branded gold #c8973a)
→ Payment success → verify on your server
→ Create Shopify order via Admin API
→ Trigger n8n webhook for doctor assignment
→ Redirect to order confirmation
```

### Custom App Endpoints Required
Build a simple Node.js/Python app (can deploy on Railway/Render):

```
POST /apps/arq-checkout/create-order
  Body: { cart_token, amount, currency, customer_id }
  Returns: { id, amount, currency, key }

POST /apps/arq-checkout/verify
  Body: { razorpay_order_id, razorpay_payment_id, razorpay_signature, shopify_cart_token }
  Returns: { success, order_status_url, shopify_order_id }

GET /apps/arq-subscriptions/list
  Returns: { subscriptions: [...] }

POST /apps/arq-subscriptions/skip/:id
POST /apps/arq-subscriptions/cancel/:id

GET /apps/arq-rx/download/:order_number
  Returns: PDF prescription

POST /apps/arq-rx/reorder/:order_id
  Returns: { success, cart_count }
```

### Razorpay Order Creation (Node.js)
```javascript
const Razorpay = require('razorpay');
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET
});

app.post('/create-order', async (req, res) => {
  const { amount, currency, cart_token, customer_id } = req.body;

  const order = await razorpay.orders.create({
    amount: amount, // already in paise
    currency: 'INR',
    receipt: `arq_${cart_token}`,
    notes: {
      shopify_cart_token: cart_token,
      customer_id: customer_id,
      source: 'arq.clinic'
    }
  });

  res.json(order);
});
```

### Payment Verification
```javascript
const crypto = require('crypto');

app.post('/verify', async (req, res) => {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

  // Verify signature
  const generated = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(`${razorpay_order_id}|${razorpay_payment_id}`)
    .digest('hex');

  if (generated !== razorpay_signature) {
    return res.json({ success: false, error: 'Signature mismatch' });
  }

  // Create Shopify order via Admin API
  const shopifyOrder = await createShopifyOrder(req.body);

  // Trigger n8n webhook → doctor assignment
  await fetch(process.env.N8N_DOCTOR_WEBHOOK, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      order_id: shopifyOrder.id,
      order_number: shopifyOrder.order_number,
      customer_name: shopifyOrder.customer.first_name,
      customer_phone: shopifyOrder.customer.phone,
      products: shopifyOrder.line_items.map(i => i.title),
      blood_required: shopifyOrder.line_items.some(i =>
        i.properties?.some(p => p.name === '_blood_required')
      )
    })
  });

  res.json({
    success: true,
    order_status_url: shopifyOrder.order_status_url,
    shopify_order_id: shopifyOrder.id
  });
});
```

---

## n8n Order Automation Flow

```
Webhook trigger (POST from Razorpay verify)
  │
  ├─ IF blood_required == true
  │    → Tag Shopify order: "blood-hold"
  │    → Send SMS to Suburban Diagnostics B2B API
  │    → WhatsApp customer: "Blood test booked for tomorrow morning"
  │    → Wait for lab result upload
  │    → Doctor reviews → approves
  │    → Remove "blood-hold" tag, add "rx-issued"
  │    → Trigger fulfillment
  │
  └─ IF blood_required == false
       → Assign doctor from available pool (round-robin)
       → WhatsApp doctor: order details + customer phone
       → Doctor calls customer (within 2hr SLA)
       → Doctor marks call complete in doctor portal
       → n8n receives webhook → tags order "rx-issued"
       → Trigger Shopify fulfillment
       → WhatsApp customer: "Prescription issued, packing now"
```

---

## Subscription Architecture

### Option A: Recharge Subscriptions (recommended)
- Install Recharge app from Shopify App Store
- Products with `subscription: true` metafield get subscribe & save pricing
- Recharge handles billing, dunning, customer portal
- Connect via Recharge webhooks to n8n for prescription renewal automation

### Option B: Custom WhatsApp Subscriptions
- On day 25 of each month, n8n sends WhatsApp to subscriber:
  "Your monthly [Product] is due. Reply YES to ship today."
- YES → trigger Razorpay recurring charge → fulfill → ship
- Simpler but more manual; good for MVP

**Recommendation:** Start with Option B for MVP (zero app cost), migrate to Recharge at 500+ subscribers.

---

## Clinical Hold Order Status

Shopify doesn't have native "hold for prescription" status. Solution:

1. Orders tagged `rx-pending` are NOT sent to fulfillment
2. Custom order status page shows: "Doctor calling within 2 hours"
3. n8n updates tag to `rx-issued` after doctor call
4. Fulfillment triggered only on `rx-issued` tag
5. Blood test orders get additional tag `blood-hold`

Implement via Shopify Flow app (free) or n8n webhook → Shopify Admin API.

---

## Privacy & Discretion Implementation

### Billing name
Set company name in Razorpay dashboard: "Dear One Technologies"
This is what appears on customer's bank statement.

### Packaging
Plain matte box — no branding visible externally.
Courier label shows only customer address.
Billing name on waybill: "Dear One Technologies"

### Shopify order notifications
Customize all Shopify email templates to:
- Remove product names from subject lines
- Use "Dear One Technologies" as sender
- Remove product images from emails

---

## Launch Product Setup

### Day 1 launch products (3):
1. **Modafinil 200mg** — simplest Rx, MBBS only, no blood test
2. **Sildenafil 50mg** — highest demand, MBBS only
3. **Finasteride 1mg** — high repeat, MBBS only

### Add in Month 2:
- Armodafinil, Tadalafil, Tretinoin, Semaglutide, THC:CBD

### Add in Month 3:
- Peptide protocols (once compounding pharmacy partnerships confirmed)

---

## SEO Setup

### Meta titles (format: {Product} — prescribed online | arq.clinic)
- Modafinil 200mg — prescribed online | arq.clinic
- Sildenafil 50mg — legal prescription | arq.clinic
- Semaglutide — generic Ozempic India | arq.clinic

### Key pages to create:
- /pages/how-it-works
- /pages/peptide-protocols
- /pages/legal-status
- /blogs/protocol — content hub for SEO

### Target keywords:
- "buy modafinil india prescription"
- "sildenafil online prescription india"
- "semaglutide india price"
- "BPC-157 india legal"
- "online prescription india"

---

## Go-Live Checklist

- [ ] Theme installed and tested on mobile
- [ ] All 3 launch products created with metafields
- [ ] Razorpay integration live (test mode first)
- [ ] n8n webhook tested end-to-end
- [ ] Doctor assigned and briefed on 2hr SLA
- [ ] WhatsApp Business number set up
- [ ] OpenClaw flow configured for post-purchase intake
- [ ] Test order placed and fulfilled
- [ ] Prescription PDF generation working
- [ ] SSL certificate on arq.clinic
- [ ] Google Analytics / Plausible installed
- [ ] Shopify Payments disabled (use Razorpay only)
- [ ] Terms, Privacy, Refund pages published
- [ ] Legal disclaimer on every product page

---

*arq.clinic — Dear One Technologies Pvt Ltd — CIN U86900MH2026PTC467148*
