# arq.clinic Operations SOP
## Complete Operations Playbook

---

## 1. ORDER FULFILLMENT SOP

### Overview
From order placement to delivery, every order must meet arq standards: speed (24-48hr fulfillment), accuracy (correct product/dose), safety (cold chain maintained), and transparency (tracking always available).

### Step 1: Order Received (Triggering Event)
**When:** Customer clicks "Place Order" after doctor approval
**Who:** Fulfillment Team (receives automated order notification)
**What:** System creates order ticket with:
- Customer ID & name
- Products ordered (drug names, quantities, lot numbers)
- Dosing protocol (doctor-prescribed)
- Shipping address
- Order timestamp
- Payment status (pre-verified)

**KPI:** All orders logged within 15 minutes of placement

### Step 2: Prescription Verification (Quality Gate 1)
**Timeline:** Within 1 hour of order receipt
**Who:** Pharmacy Manager (licensed pharmacist)
**Process:**
1. Pull doctor's prescription from system
2. Verify:
   - Doctor is verified & licensed (cross-check with registration database)
   - Prescription is current (not >12 months old)
   - Drug dosage matches customer's request
   - No drug interactions / contraindications
   - Quantity ordered is within safe limits
3. Flag any anomalies (e.g., unusually high dose)
4. If flagged: Escalate to Senior Pharmacist + notify doctor + customer (hold order)
5. If approved: Mark order "Prescription Verified" in system

**Documentation:** Screenshot of prescription approval in order file
**KPI:** 95% orders verified without escalation; 100% within 2 hours

### Step 3: Inventory Check (Availability Gate)
**Timeline:** Within 1 hour of prescription verification
**Who:** Inventory Manager
**Process:**
1. Check stock levels for each product in order:
   - Modalert (Sun Pharma) - various strengths
   - Modvigil (HAB Pharma)
   - BPC-157 vials (in-house compounded)
   - Semaglutide (Natco)
   - Finasteride tablets (Dr. Reddy's)
   - Other products as ordered
2. Verify lot numbers match order request
3. Check expiration dates (never ship within 6 months of expiry)
4. If in stock: Reserve items in inventory system, mark "Reserved"
5. If out of stock:
   - Notify customer immediately (email + SMS)
   - Offer alternatives (similar compound, different brand)
   - Wait for customer response (max 4 hours)
   - If no response: Refund order + cancel

**Reorder Triggers:**
- Stock reaches 20% of safety stock level
- Initiate procurement with approved suppliers (see Supplier Directory)
- Lead time varies: tablets 5-7 days, peptides 10-14 days

**KPI:** <2% of orders delayed due to stock issues

### Step 4: Physical Quality Check (QC Gate 1)
**Timeline:** Within 2 hours of inventory clearance
**Who:** QA Specialist (dedicated quality control)
**Process:**
1. Retrieve reserved items from pharmacy inventory
2. For each product:
   - **Verify packaging:** Seal intact, label correct, lot number matches
   - **Visual inspection:** Look for discoloration, crystals (peptides), leakage
   - **Verify quantity:** Count tablets/vials physically
   - **Check temperature:** If refrigerated items, verify storage temp was maintained
3. For peptides specifically:
   - Ensure vial seals are intact (indicates no exposure)
   - Check for frost/crystallization inside vial (may indicate thaw)
4. Log all checks in QC system with photo evidence
5. Sign off approval (digital signature required)

**Failure Protocol:** If any QC failure, escalate to Pharmacy Manager + order replacement from next batch

**KPI:** 100% zero-defect shipments (0% products damaged/mislabeled at ship)

### Step 5: Dosing Protocol Compilation
**Timeline:** Within 2 hours of QC approval
**Who:** Pharmacy Technician + Copy Writer
**Process:**
1. Retrieve doctor's prescribed protocol from order file
2. Generate customer-specific dosing document:
   - Drug name, strength, form (tablet/injection)
   - Exact dose (e.g., "200mg")
   - Frequency & timing (e.g., "Once daily, 8-10am with breakfast")
   - Duration (e.g., "8 weeks, then re-assess")
   - What to avoid (e.g., alcohol, caffeine after 10am)
   - Side effects to monitor (e.g., headache within 2 hours; nausea)
   - Emergency escalation (e.g., "If rash appears, stop immediately and contact doctor")
   - Storage instructions (temperature, light, humidity)
   - Expiration date of this protocol (usually 12 months)
3. Format as 1-page PDF with arq branding
4. Quality check: pharmacist reviews for accuracy
5. Attach to order + prepare for email

**KPI:** 100% of orders ship with accurate, personalized protocol

### Step 6: Cold Chain Packaging (For Peptides)
**Timeline:** Within 3-4 hours of QC approval
**Who:** Fulfillment Specialist (trained in cold chain)
**Process:**
1. Gather shipping materials:
   - Insulated foam box (6x6x4 inches)
   - Ice packs (frozen to -18°C minimum)
   - Bubble wrap / packing peanuts
   - Absorbent padding
   - Temperature monitoring card (tracks min/max temp)
   - Dry ice (if 48+ hour lead time)
2. For peptide orders:
   - Place ice packs on bottom of box
   - Wrap peptide vials individually in bubble wrap
   - Place vials in center of box
   - Surround with absorbent padding to prevent vial movement
   - Place second ice pack layer on top
   - Insert temperature monitoring card
   - Close box securely with tape
3. For tablet-only orders:
   - Place products in protective wrapper
   - Use standard cardboard box
   - Include desiccant packet
   - Seal with tape
4. Affix shipping label with barcode
5. Photo of sealed package (logged in system)

**Cold Chain Verification:**
- Temperature card should show 2-8°C average upon receipt
- If received at >10°C, customer contacted + replacement offered
- Data logged in quality system

**KPI:** 98% of peptide orders received within 2-8°C range

### Step 7: Shipping & Tracking
**Timeline:** Same day or within 24 hours of packaging
**Who:** Fulfillment Specialist + Logistics Partner
**Process:**
1. Choose carrier based on location & urgency:
   - **Local Metros (same city):** Shadowfax or ITC (4-6 hour delivery)
   - **Pan-India:** DTDC, Blue Dart, or Shiprocket aggregator
   - **Cold Chain Priority:** Use partners with temperature-monitored options
2. Hand off package to carrier with manifest
3. Capture tracking number in order system
4. Generate tracking link (sharable URL)
5. Send customer email with:
   - Order ID
   - Tracking number
   - Expected delivery date/time window
   - What to do upon receipt (cold chain check, storage)
   - Support contact

**Handling Delays:**
- If package delayed >24 hours beyond estimate, proactively contact customer
- Offer replacement or refund options
- For peptides: assess if cold chain compromised during delay

**KPI:** 95% on-time deliveries; 2-day average delivery time (metros); 4-day for pan-India

### Step 8: Delivery Confirmation & Post-Delivery Check
**Timeline:** Within 24 hours of delivery
**Who:** Customer (self-reported) + Support Team (verification)
**Process:**
1. Customer receives package
2. Arq sends automated SMS/email: "Your order arrived. Please inspect and confirm."
3. Customer checks:
   - Package seal intact
   - Ice packs still cold (if peptides)
   - Contents match order
   - Lot numbers correct
4. Customer responds via dashboard: "Confirmed & OK" or "Issue found"
5. If OK: Order marked "Delivered" in system
6. If issue:
   - Support team calls customer within 2 hours
   - Document issue (photo, description)
   - Assess if cold chain compromised or product damaged
   - If damage confirmed: Ship replacement at no cost (within 48 hours)
   - If cold chain failed: Full refund offered
7. Update inventory & fulfillment metrics

**Follow-up:**
- Day 1 post-delivery: Automated check-in email ("Ready to start dosing?")
- Day 7: Follow-up email requesting efficacy feedback
- Day 30: Full assessment call with doctor

**KPI:** 98% deliveries confirmed intact; <1% damage rate

---

## 2. DOCTOR ONBOARDING SOP

### Objective
Recruit, vet, and integrate licensed physicians who understand biohacking, can prescribe responsibly, and represent arq's transparent, science-backed values.

### Ideal Doctor Profile
- **Credentials:** MBBS + postgraduate (MD, DNB, or fellowship)
- **Specialties:** Functional medicine, sports medicine, longevity, or internal medicine
- **Experience:** 5+ years clinical practice
- **Biohacking Alignment:** Familiarity with performance enhancement, personalized medicine, or quantified self
- **Values:** Evidence-based; transparent with patients; willing to document decisions
- **Tech Savvy:** Comfortable with digital consultation platforms, EHR systems

### Step 1: Source & Identify Candidates
**Timeline:** Ongoing recruiting
**Who:** HR / Founder
**Methods:**
1. **LinkedIn Search:**
   - Search: "Functional Medicine" + "Delhi/Bangalore/Mumbai" + "India"
   - Filter: 5+ years experience, MD/DNB credentials
   - Target: Doctors with wellness/biohacking language in profiles
2. **Medical Association Outreach:**
   - Contact Indian Association of Functional Medicine (IAFM)
   - Attend medical conferences on longevity, preventive medicine
   - Network with speakers
3. **Referrals from Early Doctors:**
   - Ask doctors already partnering with arq to recommend peers
   - Offer referral bonus (₹5,000 per doctor hired)
4. **Direct Outreach:**
   - Cold email to functional medicine clinics
   - Message template: "We're building India's first prescription biohacking platform. We're looking for doctors who understand performance optimization. Interested?"

### Step 2: Initial Screening Call (15-30 min)
**Who:** Founder or Operations Lead
**Gate Criteria:** Must pass 2+ of 3:
1. Familiar with modafinil, semaglutide, or peptide therapy
2. Interested in personalized/performance medicine
3. Active clinical practice (currently seeing patients)

**Questions:**
- "Tell us about your clinical practice. What conditions do you focus on?"
- "Have you prescribed modafinil or other compounds off-label? What's your thought process?"
- "What appeals to you about arq?"
- "How many patients could you reasonably see per month?"
- "Any concerns about our business model or approach?"

**Outcomes:**
- Pass → Advance to formal interview
- Fail → Thank them, add to list for future

### Step 3: Formal Credential Verification
**Timeline:** Before any patient interaction
**Who:** Compliance Officer
**Process:**
1. Verify medical license (online via state medical council)
2. Check for any disciplinary records (state medical council website)
3. Verify postgraduate credentials (if claimed)
4. Review liability insurance status (ask for proof of active malpractice insurance)
5. Search for any published research or clinical reviews
6. Background check (optional but recommended)

**Documentation:** Credential file for each doctor (stored securely, HIPAA-compliant)

### Step 4: Biohacking & Prescription Protocol Training (4 hours)
**Timeline:** Within 2 weeks of credential verification
**Who:** Medical Director or Senior Pharmacist leads
**Modules:**
1. **Pharmacology 101** (1 hour)
   - Modafinil mechanism, dosing, side effects, contraindications
   - Semaglutide mechanism, timeline, monitoring
   - Finasteride mechanism, DHT pathways, monitoring
   - BPC-157 and other peptides: mechanism, evidence, safety profile
   - Stacking rationale & interactions

2. **arq Prescribing Framework** (1 hour)
   - Baseline assessment: What labs to check (lipid panel, glucose, testosterone, TSH)
   - Contraindication screening (hypertension, cardiac arrhythmias, pregnancy, etc.)
   - Dosing protocols (fixed dose vs. titration)
   - When to escalate (adverse events, non-response)
   - Documentation requirements (why this patient, why this dose)

3. **arq Systems & Processes** (1 hour)
   - How to submit prescriptions in arq dashboard
   - Patient messaging & support workflows
   - Follow-up protocols (Day 7, Day 30, Month 3)
   - Adverse event reporting (mandatory reporting to regulator + arq)
   - Patient education & consent

4. **Ethics, Compliance & Liability** (1 hour)
   - Medical and legal liability (they are responsible for their prescriptions)
   - Informed consent: patient understanding of off-label use
   - Documentation for legal protection
   - Confidentiality & data security
   - When NOT to prescribe (hard contraindications)

**Certification:** Doctor signs training completion document. Marked as "Verified & Trained" in system.

### Step 5: Soft Launch with Pilot Patients (2-4 weeks)
**Timeline:** Weeks 1-2 after training
**Who:** Operations Lead + Doctor
**Process:**
1. Doctor gets login to arq dashboard (sandbox environment initially)
2. Assign 5-10 pilot patients (arq staff / friends of staff)
3. Doctor completes consultations as usual:
   - Review health history
   - Perform assessment
   - Prescribe based on arq framework
   - Document reasoning (50+ words per prescription)
4. Operations Lead reviews each prescription for:
   - Clinical appropriateness
   - Documentation quality
   - Alignment with arq values
5. Feedback call with doctor (what went well, what to adjust)
6. Iterate for 2-4 weeks

**Success Criteria:** 8+ of 10 prescriptions meet arq standards on first attempt

### Step 6: Full Launch & Patient Assignments
**Timeline:** Ongoing
**Who:** Operations Lead
**Process:**
1. Doctor moved from sandbox to live patient queue
2. New patient consultations routed to doctor based on:
   - Availability
   - Patient location (prefer local doctors, but telemedicine OK)
   - Doctor specialty match (e.g., longevity-focused doctor for 50+ patients)
3. Capacity: Typically 20-40 consultations/month per doctor (2-4 per week)
4. Workload balancing across doctor team

### Step 7: Ongoing Management & Quality Assurance
**Frequency:** Quarterly review + ongoing spot checks
**Who:** Medical Director
**Reviews:**
1. **Prescription Quality Audit (Quarterly)**
   - Sample 10 random prescriptions per doctor
   - Check: Documentation, appropriateness, contraindication screening, follow-up completed
   - Score 0-100. Doctors <80 get coaching.

2. **Patient Feedback (Quarterly)**
   - Pull satisfaction scores & NPS from patient surveys
   - Identify doctors with low satisfaction
   - Root cause: poor communication, slow response, weak protocols?

3. **Adverse Event Review (Monthly)**
   - Check if doctor reported any adverse events
   - Assess if appropriate action taken
   - Medical Director evaluates causation (drug vs. unrelated)

4. **Professional Development (Quarterly)**
   - Share new research on drugs they prescribe
   - Host group training on new compounds (e.g., new peptide formulations)
   - Discuss challenging cases (anonymized)

### Step 8: Compensation & Retention
**Payment Model:** Per-prescription fee + patient retention bonus
- **Base:** ₹500-1,000 per consultation/prescription completed
- **Retention Bonus:** If patient continues for 3+ months, doctor earns additional ₹200 per patient
- **Maximum Cap:** ₹50,000/month per doctor (to avoid overutilization)
- **Specialty Bonus:** Doctors specializing in rare compounds (peptides) earn +20%

**Retention Initiatives:**
- Quarterly feedback sessions
- Priority support (dedicated ops contact)
- Invites to arq advisory meetings
- Annual appreciation event
- Referral bonuses for recruiting other doctors

**Termination Clause:**
- Underperformance: <80 prescription quality score for 2 consecutive quarters
- Misconduct: Prescribing outside arq protocols, inadequate documentation, patient complaints
- Legal/licensing issues: Loss of medical license, malpractice claims

---

## 3. CUSTOMER SUPPORT PLAYBOOK

### Support Philosophy
"Science-backed, human, fast." Every support interaction reinforces arq's values: transparency, education, safety.

### Support Channels
1. **Email** (primary): support@arq.clinic | Response: 4 hours max
2. **WhatsApp** (urgent): +91-XXXX-XXXX-XX | Response: 2 hours max
3. **Dashboard Chat** (post-order): Real-time, in-app messaging
4. **Phone Call** (escalation only): By appointment only

### Common Issues & Scripts

#### Issue 1: "How long does modafinil take to work?"

**Customer Question (Variant):**
- "When will I feel it?"
- "Is it working?"
- "Nothing happened yet"

**Root Cause:** Unrealistic expectations, misunderstanding of timeline

**Script Response:**
"Modafinil onset is 45-60 minutes. You should notice it by 1-2pm if you take it at 9am.

What to expect: Subtle at first—easier focus, slightly sharper thoughts, less urge to nap. It's not like caffeine jitter. If you feel nothing by 2 hours, a few things:
- Did you take it with food? (Recommended for absorption)
- Did you take it before 10am? (Timing matters for sleep)
- Your baseline: Some people notice it more, some less. Genetic variance in CYP3A4 affects metabolism.

Give it 3-5 days before deciding if it's working. Your body has to adjust. Day 1-2 is often subtler than Day 5."

**Escalation:** If still no effect after 1 week, escalate to doctor for dose adjustment or alternative.

---

#### Issue 2: "I'm experiencing headaches"

**Customer Question (Variant):**
- "Headache + modafinil—is this normal?"
- "Should I stop taking it?"
- "Is it dangerous?"

**Root Cause:** Unknown side effects, fear response

**Script Response:**
"Modafinil headaches happen in ~30% of users, usually in first 2-3 days. Almost always resolves by Day 4-5.

Why it happens: Modafinil increases dopamine, which can trigger tension headaches in sensitive people. It's not dangerous, but uncomfortable.

What to do:
- Stay hydrated (drink 2-3L water daily). This is #1 fix.
- Take it with breakfast (food helps absorption and reduces GI stress, which can contribute to headaches).
- Ibuprofen is fine (400-600mg) if headache is severe. Take it 2-3 hours after your dose.
- Don't stop abruptly—taper over 3 days if you decide to discontinue.

If headache persists past Day 5, message Dr. Sharma. She may lower your dose (150mg instead of 200mg) or switch you to a different compound."

**Escalation:** Headache + fever, stiff neck, vision changes = immediate escalation to doctor (potential rare side effect).

---

#### Issue 3: "My package didn't arrive or is damaged"

**Customer Question (Variant):**
- "It's been 5 days, no tracking update"
- "Package arrived but ice packs were warm"
- "Vial looks cloudy"

**Root Cause:** Logistics delays, temperature breakdown, product damage

**Script Response:**
"I'm sorry. Let's fix this immediately. Can you tell me:
1. Order ID?
2. What exactly is the issue? (Not arrived / late / damaged / temperature concern)
3. When did you place the order? When was the expected delivery?

Depending on your answer:
- **Not arrived by Day 3:** We'll investigate with courier + ship replacement immediately at no cost.
- **Arrived but ice packs warm (peptides):** If product is warm (>10°C), don't use it. We'll replace it at no cost. Cold chain failure is our responsibility.
- **Vial looks cloudy:** If peptide vial looks discolored or cloudy, it may have been compromised. Don't use it. Reply with photo + we'll replace immediately.

You won't be charged extra. Shipping + product replacement is on us."

**Escalation:** If customer doesn't respond within 4 hours with details, proactively call them.

---

#### Issue 4: "I want to pause my subscription"

**Customer Question (Variant):**
- "I want to pause for 2 months"
- "Can I cancel instead?"
- "Will I lose my credits?"

**Root Cause:** Natural lifecycle (end of cycle, want to assess results, temporary pause)

**Script Response:**
"Totally fine. We built pause into our system because most biohackers cycle.

Pause means:
- No charge until you resume
- Your subscription stays active (you don't lose anything)
- You can resume anytime by logging into your dashboard + hitting 'Resume'
- Your doctor's prescription stays valid for 12 months from approval date

Common reasons to pause:
- You just finished an 8-week BPC-157 cycle and want to assess results before reordering
- Tolerance reset (take a 4-week break, then start fresh)
- Financial or life reasons

If you want to cancel entirely (not just pause), we'll process that too—no questions asked. But 95% of people who pause come back, because results take time to assess.

Want to pause? Just log into your dashboard + click 'Pause Subscription'. It's instant."

**Escalation:** If customer wants to cancel permanently, ask for brief feedback (why? what could we improve?) but don't push back.

---

#### Issue 5: "Are these products legal? Is this legal?"

**Customer Question (Variant):**
- "Will I get in trouble for ordering modafinil?"
- "Is this prescription legal?"
- "Are you operating legally?"

**Root Cause:** Legitimate legal concern, fear of regulation

**Script Response:**
"Good question. Yes, this is legal. Here's why:

Modafinil in India is a scheduled pharmaceutical (requires prescription). We handle that: licensed doctor prescribes, we dispense with that prescription. Same as ordering from a pharmacy.

What makes this legal:
- We're not importing—sourcing from Indian manufacturers (Sun Pharma, HAB, etc.)
- We require valid prescription from licensed doctor
- Our doctors are registered with their state medical councils
- We maintain patient records for regulatory compliance
- If questioned by authorities, we have prescription documentation

What's NOT legal:
- Buying modafinil without prescription (we don't do this)
- Importing from abroad (we don't do this)
- Operating without licensed doctors (we require this)

**Bottom line:** You're not breaking any law. You're getting a prescribed pharmaceutical through a licensed platform. Same legal framework as a clinic dispensary.

That said: We're operating in a gray zone because biohacking is new in India. Regulators are still figuring it out. If regulations change, we'll adapt first and inform all customers. But right now, we're compliant."

**Escalation:** If customer remains concerned, escalate to founder/legal for deeper reassurance.

---

#### Issue 6: "Can I use this while taking [other drug]?"

**Customer Question (Variant):**
- "I'm on SSRIs. Can I take modafinil?"
- "I'm pregnant. Is finasteride safe?"
- "I have diabetes. Can I take semaglutide?"

**Root Cause:** Legitimate drug interaction / safety concern

**Script Response:**
"This is exactly why we require doctor consultation. I can't give personalized medical advice, but here's the general info:

**General rule:** Never start any new drug without telling your doctor about current medications.

**Specific examples:**
- SSRIs + Modafinil: Generally safe together, but risk of serotonin syndrome is low but real. Your doctor assessed this.
- Pregnancy + Finasteride: Not recommended—finasteride can affect fetus. Your doctor would have declined.
- Diabetes + Semaglutide: Semaglutide is actually used FOR diabetes management. Dose adjustment may be needed.

**What to do now:**
If you have a drug your doctor doesn't know about, or if you were on that other drug when you consulted but didn't mention it: Message Dr. Sharma immediately from your dashboard. She'll reassess.

Don't just start the new drug. Message first."

**Escalation:** Any interaction concern → escalate to doctor immediately.

---

#### Issue 7: "I had a side effect. What do I do?"

**Customer Question (Variant):**
- "I have nausea / rash / dizziness"
- "Should I stop taking it?"
- "Is this normal?"

**Root Cause:** Adverse event, customer doesn't know if it's serious

**Script Response:**
"I'm concerned. Let's assess urgency. Answer these:
1. What symptom exactly? (nausea, rash, dizziness, etc.)
2. When did it start? (same day as first dose? Day 3?)
3. How severe? (mild discomfort / moderate / severe?)
4. Any fever? Any trouble breathing? Any rash that's spreading?

**If severe, fever, breathing difficulty, or spreading rash:**
Stop the drug immediately and go to nearest hospital ER. This could be serious. Call Dr. Sharma + arq support immediately.

**If mild (nausea, mild headache):**
These often resolve in 2-3 days. Stay hydrated. Take with food. But message Dr. Sharma for confirmation.

**If moderate:**
Stop for today. Message Dr. Sharma immediately. She'll advise: continue with dose reduction, or switch to alternative.

I'm sending you the adverse event report form. Fill it out + submit. We track every side effect to improve safety."

**Protocol:** Every adverse event reported → medical director reviews + determines if causality is drug-related → reported to regulatory authority if required → patient updated.

---

### Support Escalation Path
1. **Level 1 (Support Team):** Responds to all initial inquiries. Can address common issues (delays, pause requests, general questions)
2. **Level 2 (Senior Support + Pharmacist):** Drug interactions, minor side effects, medication questions
3. **Level 3 (Doctor):** Prescription changes, serious adverse events, medical decisions
4. **Level 4 (Medical Director):** Rare side effects, legal/compliance questions, escalations from doctors

**KPI:**
- Level 1 resolves 70% of tickets
- Average response time: 4 hours for email, 2 hours for WhatsApp
- Customer satisfaction score (CSAT): >85%
- First-contact resolution rate: >60%

---

## 4. RETURNS & REFUND HANDLING

### Refund Policy
arq offers refunds in the following scenarios:

#### Scenario 1: Product Not Received
- **Timeline:** If package doesn't arrive within 5 business days of shipment
- **Action:** Replace or refund (customer choice)
- **Timeline to Process:** Within 2 business days
- **Cost:** Free replacement shipping

#### Scenario 2: Product Damaged or Wrong
- **Timeline:** If customer reports within 24 hours of delivery
- **Verification:** Customer must provide photo evidence
- **Action:** Replace or refund (customer choice)
- **Timeline to Process:** Replacement ships within 24 hours
- **Cost:** Free replacement shipping; original package returned at arq's cost

#### Scenario 3: Cold Chain Failure
- **Indicator:** Temperature monitoring card shows >10°C or >15°C
- **Action:** Automatic refund or replacement (no customer request needed)
- **Verification:** Customer reports temp card reading
- **Timeline to Process:** Refund issued within 2 business days

#### Scenario 4: Product Refusal / Return After Receipt (Within 48 hours)
- **Condition:** Product unopened, in original packaging
- **Reason:** Customer changed mind, adverse event, product concern
- **Action:** Full refund
- **Return Process:**
  - Customer ships back at arq's cost (we email prepaid label)
  - Receives refund within 5 business days of return receipt
- **Timeline:** Refund within 5 days of arq receiving package back

#### Scenario 5: Subscription Refund (Auto-Refill Cancelled)
- **If:** Customer cancels before next charge
  - Cancels >5 days before next auto-shipment: Full refund of pending charge
  - Cancels <5 days before: Order already in queue; refund offered on next cycle or full return
- **Timeline:** Refund processed within 2 business days

### Non-Refundable Scenarios
- Customer consumed/opened product (patient safety: cannot resell)
- Refund requested >30 days after delivery (unless defect discovered later)
- Customer requests refund due to "not happy with results" (product worked correctly; this is normal variation in response)
- Refund requested without supporting evidence

### Refund Processing
**Method:** Original payment method (credit card, net banking, etc.)
**Processing Time:** 5-10 business days (bank-dependent)
**Confirmation:** Email receipt with refund amount, transaction ID, timeline

### Return Logistics
**Process:**
1. arq emails prepaid return shipping label
2. Customer places label on original package
3. Customer drops at nearest courier pickup point (Shadowfax, DTDC, Blue Dart, etc.)
4. arq receives package, inspects for condition
5. Refund initiated within 2 business days of receipt

**Where to Return:** arq Pharmacy, Bangalore (address on label)

### Refund Disputes
- Customer disputes a refund decision
- Process: Customer emails support@arq.clinic with explanation
- Investigation: Ops team reviews order, damage photos, cold chain data
- Resolution: Phone call with customer within 24 hours
- Decision: Escalate to Founder if unresolved

---

## 5. ADVERSE EVENT REPORTING PROTOCOL

### Definition
Any unexpected medical event, side effect, injury, or concern experienced by a patient after taking an arq product.

### Mandatory Reporting Triggers
Per Indian pharmaceutical regulations, arq must report to regulator if:
- Serious adverse event (hospitalization, death, permanent disability)
- Rare/unknown adverse event (not listed in product documentation)
- Unexpected pattern (e.g., 5 customers report same symptom within 1 week)

### Step 1: Event Detection
**Who Reports:**
- Customer (via support chat, email, call)
- Doctor (via consultation or dashboard)
- Support team (if customer hints at side effect)

**What to Ask:**
1. Product name, dose, date started
2. Symptom name, onset time, severity
3. Medical history (any pre-existing conditions?)
4. Other drugs being taken
5. Any prior episodes of this symptom
6. Current status (ongoing, resolved, worsening?)

### Step 2: Initial Assessment (within 2 hours)
**Who:** Support Team + Senior Pharmacist
**Urgency Classification:**
- **CRITICAL (Immediate action):** Chest pain, trouble breathing, severe rash, seizure, loss of consciousness
- **SERIOUS (Within 4 hours):** Severe nausea/vomiting, high fever, severe headache, vision changes
- **MODERATE (Within 24 hours):** Mild rash, mild headache, dizziness, nausea
- **MILD (Monitor, no immediate action):** Mild discomfort, expected side effect (e.g., slight headache from modafinil)

**Critical Action:** If CRITICAL: Direct patient to ER immediately + notify doctor + notify medical director

### Step 3: Event Logging
**Documentation** (Medical Director or Pharmacist):
1. Create adverse event report:
   - Date/time of event
   - Customer ID & doctor ID
   - Product name, lot number, dose
   - Symptom description & timeline
   - Severity rating (critical/serious/moderate/mild)
   - Action taken (advised patient to stop, reduce dose, continue)
   - Outcome (resolved, ongoing, unknown)
2. Causality assessment:
   - Definite (clearly caused by drug)
   - Probable (likely caused by drug)
   - Possible (could be drug or other cause)
   - Unlikely (probably not caused by drug)
3. Expected vs. unexpected (is this a known side effect?)
4. Store in secure database (HIPAA-compliant, encrypted)

### Step 4: Doctor Consultation (within 24 hours)
**Who:** Medical Director reaches out to prescribing doctor
**Process:**
1. Share adverse event details (anonymized if not their patient)
2. Get doctor's assessment: Causality? Recommendation?
3. Doctor may advise:
   - Continue (if expected, manageable side effect)
   - Reduce dose
   - Pause/discontinue
   - Switch to alternative compound
4. Doctor notifies patient with recommendation
5. Log doctor's decision

### Step 5: Regulatory Reporting (if required)
**Timeline:** Within 15 days of serious/unexpected event
**Who:** Medical Director + Compliance Officer
**Regulatory Bodies:**
- **Serious adverse events:** Report to Central Drugs Standard Control Organization (CDSCO)
- **Deaths:** Report to state medical board
- **Rare/unexpected events:** Report to CDSCO Pharmacovigilance

**Report Contents:**
- Patient demographics (anonymized)
- Drug details (name, batch, dose)
- Event description & timeline
- Assessment & action taken
- Doctor's recommendation

### Step 6: Follow-up & Outcome
**Timeline:**
- Day 1: Initial check-in with patient
- Day 3: Reassessment (is symptom resolved?)
- Day 7: Final status update

**Outcome Tracking:**
- Resolved: Document resolution date
- Ongoing: Continue monitoring
- Escalated: If hospitalized, coordinate with hospital

### Step 7: Learning & System Improvement
**Monthly Review (Medical Director):**
1. Compile all adverse events from past month
2. Look for patterns (e.g., >5 reports of same symptom)
3. If pattern found: Root cause analysis
   - Is this a batch quality issue? (alert supplier)
   - Is this a dosing recommendation issue? (adjust protocols)
   - Is this a patient selection issue? (tighten contraindication screening)
4. Update protocols if needed
5. Communicate findings to doctor network

**KPI:**
- 100% adverse events logged
- 100% serious events reported to regulator within 15 days
- <5% serious adverse events monthly (quality threshold)

---

## 6. COLD CHAIN LOGISTICS FOR PEPTIDES

### Why Cold Chain Matters
Peptides (BPC-157, TB-500, etc.) are proteins. Heat denatures them. Frozen peptides lose efficacy.
- **Safe temperature:** 2-8°C (refrigerated)
- **Unsafe:** >15°C for >4 hours
- **Critical:** >25°C for >2 hours (likely degraded)

### Cold Chain Protocol

#### Sourcing & Storage (arq Warehouse)
- **Storage:** Dedicated pharmaceutical refrigerator (2-8°C) with temperature logging
- **Backup:** Generator power (in case of power outages)
- **Monitoring:** Daily temperature log + weekly trend check
- **Max time at room temp:** <2 hours during QC or packaging

#### Packaging (Before Shipment)
1. **Materials:**
   - Insulated foam box (R-value >15)
   - Ice packs (frozen to -18°C minimum, ideally -22°C)
   - Absorbent padding or thermal packs
   - Temperature data logger (tracks min/max during transit)
2. **Assembly:**
   - Ice packs on bottom (15mm thickness)
   - Peptide vials wrapped individually in bubble wrap
   - Vials placed in center of box (away from direct ice contact)
   - Padding around all sides
   - Second ice pack layer on top
   - Data logger placed where temperature best represents vial environment
   - Seal securely with fiber tape (not duct tape)
3. **Weight & Size Check:**
   - Max weight: 2kg (to avoid crushing vials)
   - Standard box: 20x15x10cm

#### Transit (Shipping Partner Responsibility)
- **Carrier:** Must have cold chain capability
  - Preferred: Shadowfax, Blue Dart cold logistics, specialized biotech couriers
  - Backup: DTDC with insulated boxes
- **Duration:** Max 48 hours for pan-India (otherwise use dry ice)
- **Monitoring:** Data logger records temperature continuously
- **Contingency:** If delay predicted >48 hours, use dry ice or overnight flight

#### Delivery Handoff
- **Temperature Check:** Customer receives cold package (ice packs should be cold or semi-frozen)
- **Data Logger:** Included in package for customer verification
- **Expected Range:** Temperature card should show 2-8°C average (up to 12°C acceptable, >15°C is failure)
- **Customer Action:** Must refrigerate immediately upon receipt

#### Post-Delivery Data Analysis
- Retrieve data logger from customer (they email/photo) or retrieve from package return
- Analyze temperature profile:
  - Consistent 2-8°C: PASS
  - Spike to 12-15°C (briefly): PASS (recovers)
  - Sustained >15°C: FAIL (cold chain broken)
  - >25°C: FAIL (peptide degraded, not usable)
- If FAIL: Notify customer, offer replacement + refund shipping

### Supplier Cold Chain Requirements
When sourcing peptides from compounding pharmacies:
- Verify they use -22°C freezers for storage
- Require cold chain documentation (data logger with each shipment to arq)
- Upon receipt, verify temperature log before accepting batch
- If batch arrived warm: Reject, don't pay

### Backup Plan (If Cold Chain Fails in Transit)
1. **Option A:** Offer full refund (no questions)
2. **Option B:** Offer replacement (we ship again, maintain cold chain)
3. **Option C:** Customer uses product at own risk (we disclose potential loss of efficacy, customer signs waiver)
   - Most customers choose A or B

### KPI
- 95%+ of peptide shipments arrive within 2-8°C
- <5% require replacement due to cold chain failure
- Zero customer complaints of degraded peptides (no visible discoloration, crystallization, etc.)

---

## 7. QUALITY ASSURANCE CHECKLIST

### Pre-Shipment QA (Before Every Order)

- **Prescription verification:** Doctor verified, prescription current, no interactions flagged ✓
- **Inventory check:** Products in stock, lot numbers confirmed, expiration date >6 months out ✓
- **Physical QC:**
  - Package seal intact ✓
  - Label correct (product name, strength, lot number) ✓
  - Quantity matches order (count tablets, vials) ✓
  - No visible defects (discoloration, leakage, crystallization for peptides) ✓
- **Cold chain (if peptides):**
  - Ice packs frozen solid ✓
  - Vials wrapped securely ✓
  - Temperature data logger included ✓
  - Packaging box sealed with fiber tape ✓
- **Dosing protocol:**
  - Personalized protocol printed ✓
  - Doctor's prescription details match ✓
  - Storage instructions included ✓
  - Emergency contact info included ✓
- **Shipping label:**
  - Barcode scans correctly ✓
  - Address matches customer record ✓
  - Correct carrier selected (cold chain if needed) ✓

### Post-Delivery QA

- **Delivery confirmation:** Package received, no damage reported ✓
- **Cold chain validation (if peptides):** Temperature logger read, data within 2-8°C ✓
- **Customer feedback:** Customer confirms contents match order ✓
- **Day 7 follow-up:** Customer reports no defects or issues ✓

### Monthly QA Audits

- **Sample size:** 10% of all orders shipped (min 20 orders)
- **Categories checked:**
  - Prescription accuracy (prescription verified? All checks passed?)
  - Inventory accuracy (correct product? Correct lot?)
  - Packaging quality (damage? Labeling?)
  - Cold chain compliance (peptides at correct temp?)
  - Documentation completeness (dosing protocol included? Signed off?)
- **Defect threshold:** 0% for critical (wrong drug, damaged goods), <2% for minor (labeling typo)
- **Corrective action:** If defect found, retrain responsible staff + audit that staff for next 10 orders

### Supplier QA

- **Incoming inspection:** Every supplier batch inspected for:
  - Packaging integrity
  - Label accuracy (no misprints)
  - Temperature verification (for peptides)
  - Expiration date >12 months out
  - Visual inspection (color, crystals, leakage)
- **Purity testing (Optional, for high-value/high-risk products):**
  - BPC-157 peptides: HPLC testing at 3rd party lab annually
  - Modafinil: Visual inspection + tamper check (Sun Pharma blister packs)
- **Quarantine:** If batch fails QA, quarantine immediately + contact supplier

---

## 8. INVENTORY MANAGEMENT

### Reorder Point Model (By Product)

| Product | Safety Stock | Reorder Point | Lead Time | Min Order Qty |
|---------|--------------|---------------|-----------|--------------|
| Modalert 200mg (tablets) | 300 | 200 | 5 days | 500 |
| Modvigil 200mg (tablets) | 200 | 150 | 7 days | 500 |
| Semaglutide (Natco) | 20 vials | 10 | 14 days | 50 |
| Finasteride 1mg (tablets) | 500 | 300 | 7 days | 1000 |
| BPC-157 2mg (compounded) | 30 vials | 15 | 10 days | 25 |

**Logic:**
- **Safety Stock:** Minimum to avoid stockouts during lead time + buffer for surge
- **Reorder Point:** When to trigger procurement order
- **Lead Time:** Days between order placed and delivery to arq

**Trigger:** When inventory drops to reorder point, automatically initiate procurement order with supplier

### Inventory System (Tracking)
- **Tool:** Simple spreadsheet or low-cost inventory software (e.g., TradeGecko free tier)
- **Tracking per product:**
  - Total stock (units)
  - Reserved (for pending orders)
  - Available (total - reserved)
  - Lot number + expiration date
- **Daily update:** Fulfillment team updates after shipment
- **Weekly review:** Inventory manager checks for anomalies (unusual depletion, obsolescence)

### Stock Rotation (FIFO)
- **First In, First Out:** Older stock shipped first
- **Lot tracking:** Track lot numbers in system
- **Expiration monitoring:** Never ship if expiration date within 6 months
- **Disposal:** Expired stock destroyed per pharmaceutical regulations (can't resell or donate)

### Seasonal Adjustments
- **Q4 surge:** Holiday gifting, New Year resolution season (increase safety stock by 25%)
- **Q1 dip:** Post-holiday, lower demand (reduce reorder frequency)
- **Summer monsoon:** Logistics delays (increase lead time assumption by 3-5 days)

### Monthly Inventory Variance Report
- **What:** Physical count vs. system count
- **Frequency:** Monthly on last Friday
- **Process:**
  1. Count all inventory physically
  2. Cross-check against system
  3. Variance >2%: Investigate (human error? Theft? Shrinkage?)
  4. Adjust system to reflect actual count
- **KPI:** <1% variance month-over-month

---

## 9. SUPPLIER MANAGEMENT PROCEDURES

### Supplier Evaluation & Selection

#### Criteria for Approval
1. **Credentials:**
   - Licensed pharmaceutical manufacturer (CDSCO approved, GMP certified)
   - Legitimate business registration
   - Positive business history (no recalls, no legal issues)

2. **Product Quality:**
   - ISO/GMP certified facilities
   - Can provide CoA (Certificate of Analysis) with each batch
   - Willing to undergo quality testing (HPLC for critical products)
   - Stable product: consistent quality batch-to-batch

3. **Reliability:**
   - Consistent delivery timelines
   - Responsive to inquiries
   - Flexible on order quantities (not too high MOQ)
   - Payment terms acceptable (net 30 standard)

4. **Pricing:**
   - Competitive but not suspiciously cheap (red flag for counterfeit)
   - Transparent pricing (no hidden fees)
   - Volume discounts offered

### Supplier Onboarding Process

**Step 1: Identification** (See Supplier Directory for list)
- Research company: Website, business registration, market reputation
- Initial contact: Email introducing arq, product requirements

**Step 2: Qualification** (1-2 week process)
- Request: Business license, GMP certificate, CoA samples
- Review credentials
- Check with other pharmaceutical distributors (reputation check)
- Site visit (optional but recommended for first orders >₹50k)

**Step 3: First Order (Pilot)**
- Order: Small quantity (10-25% of typical order)
- Terms: 50% prepay, 50% on delivery (reduces risk)
- QC: Full inspection upon receipt
- If pass: Proceed to regular orders

**Step 4: Contract Signing**
- Terms: Price, MOQ, lead time, payment terms, QA requirements
- SLA: What if delivery late? What if product defective?
- Confidentiality: arq customer list, pricing confidential
- Termination: 30-day notice for discontinuation

**Step 5: Ongoing Relationship**
- Regular orders placed 2-3 weeks before reorder point
- Monthly review: On-time rate, quality issues, communication
- Quarterly business review: Pricing, volume discounts, new products

### Supplier Performance Scorecard (Quarterly)

| Metric | Weight | Target | Score |
|--------|--------|--------|-------|
| On-time delivery % | 30% | 95%+ | |
| Quality (defect rate) | 30% | <1% | |
| Responsiveness (reply within 24h) | 20% | 95%+ | |
| Price competitiveness | 20% | Market rate ±5% | |
| **Total Score** | 100% | 90%+ | |

- **Score 90-100:** Excellent, increase volume
- **Score 80-89:** Good, monitor closely
- **Score <80:** At risk, plan replacement, give 60-day notice

### Supplier Directory (See Separate Document)
Full list of approved suppliers, contact info, product categories, pricing, MOQ

### Contract Termination
- **Cause:** Consistent quality issues, repeated late deliveries, price disputes, loss of certification
- **Notice:** 30 days advance (except for critical failures)
- **Transition:** Overlap with new supplier, stagger switchover, avoid gaps

---

## 10. KEY PERFORMANCE INDICATORS (KPIs)

### Order Fulfillment
- **On-time delivery:** 95%+ orders delivered within SLA
- **Zero-defect shipments:** 98%+ orders received without damage/error
- **Average fulfillment time:** 24-48 hours (order to shipment)
- **Cold chain compliance:** 95%+ peptide orders received within 2-8°C

### Customer Support
- **Response time:** 4 hours email, 2 hours WhatsApp
- **First-contact resolution:** 60%+ issues resolved without escalation
- **Customer satisfaction (CSAT):** 85%+
- **Repeat order rate:** 70%+ customers reorder within 90 days

### Doctor Network
- **Doctor quality:** 80%+ prescription scores (QA audit)
- **Doctor capacity:** 20-40 consultations/month per doctor
- **Patient satisfaction with doctor:** 85%+ NPS
- **Doctor retention:** 90%+ doctors retained annually

### Adverse Events
- **Reporting rate:** 100% serious events reported to regulator within 15 days
- **Serious event rate:** <5% of orders result in serious adverse events
- **Escalation resolution:** 100% escalations resolved within 7 days

### Financial
- **Revenue per order:** ₹5,000-10,000 average (Modafinil + Peptide combo)
- **Cost per order:** ₹2,500-3,500 (COGS + logistics + overhead)
- **Gross margin:** 55-65%
- **Customer acquisition cost:** <₹2,000 per customer
- **Customer lifetime value:** ₹15,000-30,000 (3-6 orders avg)

### Growth
- **Monthly customer growth:** 20%+ YoY (early stage)
- **Repeat order rate:** 70%+
- **Net Promoter Score (NPS):** 50%+ (excellent for healthcare)

---

**End of Operations SOP**