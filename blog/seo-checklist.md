# arq.clinic SEO Deployment Checklist

## 1. Search Engine Setup

### Google Search Console
- [ ] Verify domain ownership (add HTML file to root or DNS record)
- [ ] Submit `sitemap.xml` at https://arq.clinic/sitemap.xml
- [ ] Monitor for indexing errors and warnings
- [ ] Set preferred domain (www vs non-www)
- [ ] Request crawl for new pages and updates
- [ ] Monitor Core Web Vitals in GSC Mobile Usability report
- [ ] Check Search Performance for impressions, clicks, and CTR
- [ ] Set up email notifications for critical issues
- [ ] Review Security Issues tab monthly

### Bing Webmaster Tools
- [ ] Verify domain ownership
- [ ] Submit `sitemap.xml`
- [ ] Monitor crawl stats and indexing
- [ ] Check for mobile usability issues

## 2. Analytics Setup

### Google Analytics 4 (GA4)
- [ ] Create GA4 property for arq.clinic
- [ ] Install GA4 tag via Google Tag Manager or directly
- [ ] Configure conversion events:
  - [ ] Form submissions (consultation requests)
  - [ ] Newsletter signups
  - [ ] Product purchases
  - [ ] PDF downloads (medical guides)
- [ ] Set up audience segments:
  - [ ] New vs. returning visitors
  - [ ] High-intent users (product page visitors)
  - [ ] Blog readers
- [ ] Enable Enhanced ecommerce tracking (if applicable)
- [ ] Configure internal site search tracking
- [ ] Set up goals for key pages
- [ ] Enable Google Ads integration
- [ ] Create custom dimensions for user type, medical condition keywords

### Enhanced Measurement (in GA4)
- [ ] Enable page views
- [ ] Enable scroll events
- [ ] Enable outbound clicks
- [ ] Enable file downloads
- [ ] Enable video engagement
- [ ] Enable form interactions

## 3. SEO App Installation (Shopify)

### Smart SEO or SEOnt App
- [ ] Install Smart SEO or SEOnt app from Shopify App Store
- [ ] Configure automatic meta titles and descriptions
- [ ] Set canonical URLs for all pages
- [ ] Generate and manage Open Graph tags
- [ ] Enable structured data markup (JSON-LD)
- [ ] Set up redirects for old blog URLs if migrating
- [ ] Configure hreflang tags if multilingual
- [ ] Run SEO audit to identify issues
- [ ] Monitor Keyword Rankings (if available in app)

### Alternative: Yoast SEO or All in One SEO (if using WordPress)
- [ ] Install and activate plugin
- [ ] Configure site-wide SEO settings
- [ ] Enable XML sitemaps
- [ ] Set reading focus keyword for each page
- [ ] Implement internal linking suggestions

## 4. Page Title and Meta Description Standards

### Format Standards
**Blog Articles:**
```
[Article Title] — prescribed online | arq.clinic
```
Example: `BPC-157 in India: Legality, Benefits, and How to Get It — prescribed online | arq.clinic`

**Product Pages:**
```
[Product Name] — [Key Benefit] online | arq.clinic
```
Example: `Modafinil 200mg — Cognitive Enhancement online | arq.clinic`

**Category Pages:**
```
[Category] — [Primary Keyword] | arq.clinic
```
Example: `Biohacking Supplements — Longevity & Performance | arq.clinic`

**Homepage:**
```
arq.clinic — Prescribed Longevity & Biohacking in India
```

### Meta Description Standards
- Length: 150-160 characters
- Include primary keyword
- Clear call-to-action
- Unique for each page
- No keyword stuffing

**Format:**
```
[Brief description of page content]. [Call-to-action]. Available for telemedicine consultation in India.
```

Example: `Comprehensive guide to BPC-157 availability in India. Learn about legal status, benefits, and how to get prescribed. Telemedicine consultation available.`

## 5. Canonical URL Rules

- [ ] Homepage: `<link rel="canonical" href="https://arq.clinic/" />`
- [ ] Blog index: `<link rel="canonical" href="https://arq.clinic/blog/" />`
- [ ] All blog articles: Self-referential canonical (e.g., on `/blog/modafinil-legal-india`, set to `https://arq.clinic/blog/modafinil-legal-india`)
- [ ] No trailing slash redirects (pick one standard)
- [ ] Remove utm parameters from canonicals
- [ ] Avoid infinite self-referential chains

## 6. Structured Data Validation

### JSON-LD Implementation Checklist
- [ ] Add Organization schema to site header or footer (on every page)
- [ ] Add WebSite schema with SearchAction to homepage
- [ ] Add LocalBusiness schema to homepage (pharmaceutical services, India)
- [ ] Add BreadcrumbList to every article page
- [ ] Add Article + MedicalWebPage schema to every blog post
- [ ] Validate all schemas with Google Rich Results Test: https://search.google.com/test/rich-results

### Per-Page Schema Requirements
**Homepage:**
- [ ] Organization
- [ ] WebSite
- [ ] LocalBusiness
- [ ] BreadcrumbList (root level)

**Blog Index Page:**
- [ ] BreadcrumbList
- [ ] CollectionPage or ItemList (listing all articles)

**Blog Articles:**
- [ ] Article
- [ ] MedicalWebPage
- [ ] BreadcrumbList (Article > Blog > Home)
- [ ] Author organization

**Product Pages (if applicable):**
- [ ] Product
- [ ] AggregateOffer or Offer (pricing)
- [ ] BreadcrumbList

## 7. Page Speed & Core Web Vitals

### Targets (Mobile)
- [ ] Largest Contentful Paint (LCP): < 2.5 seconds (good)
- [ ] First Input Delay (FID): < 100 milliseconds (good)
- [ ] Cumulative Layout Shift (CLS): < 0.1 (good)
- [ ] Overall Lighthouse score: > 80

### Performance Optimization Checklist
- [ ] Compress images (use WebP format where possible)
- [ ] Enable GZIP compression on server
- [ ] Minimize CSS and JavaScript
- [ ] Defer non-critical JavaScript
- [ ] Implement lazy loading for images
- [ ] Use Content Delivery Network (CDN) for static assets
- [ ] Reduce server response time (TTFB < 600ms)
- [ ] Remove render-blocking resources
- [ ] Cache assets for repeat visitors
- [ ] Monitor performance with PageSpeed Insights
- [ ] Set up Core Web Vitals monitoring in GA4

### Tools for Testing
- [ ] Google PageSpeed Insights: https://pagespeed.web.dev/
- [ ] WebPageTest: https://www.webpagetest.org/
- [ ] GTmetrix: https://gtmetrix.com/
- [ ] Lighthouse CI for continuous monitoring

## 8. Internal Linking Strategy

### Linking Best Practices
- [ ] Link from blog articles to related product pages
- [ ] Link from product pages back to relevant blog articles
- [ ] Use descriptive anchor text (avoid "click here")
- [ ] Create topic clusters around core topics:
  - Modafinil cluster: legal status → side effects → vs armodafinil
  - Longevity cluster: biohacking → Peter Attia stack → TRT → supplements
  - Telemedicine cluster: legal framework → process → consultation
- [ ] Ensure 2-3 internal links per blog article minimum
- [ ] Create hub pages linking to related content
- [ ] Link high-authority pages to new/low-authority pages
- [ ] Avoid excessive internal linking (max 3-5 per section)

### Internal Linking Targets
- [ ] Homepage gets links from every article
- [ ] Blog index gets links from article headers
- [ ] Related products linked from relevant blog articles
- [ ] Consultation/contact page linked from 2-3 key pages

## 9. Image Optimization

### Alt Text Convention
```
[Keyword] [descriptive text] for [condition/use]
```

Examples:
- `BPC-157 peptide vial and syringe for muscle recovery`
- `Modafinil 200mg tablet for cognitive enhancement`
- `Peter Attia longevity protocol supplement stack`

### Image Best Practices
- [ ] All images have descriptive alt text
- [ ] Images compressed (< 200KB for web, < 50KB for thumbnails)
- [ ] Use WebP format where supported with JPG fallback
- [ ] Include primary keyword in alt text for 1-2 key images per page
- [ ] Use descriptive filenames: `bpc-157-peptide-vial.jpg` not `image123.jpg`
- [ ] Implement lazy loading for below-the-fold images
- [ ] Add structured image data if appropriate:
  ```json
  {
    "@context": "https://schema.org",
    "@type": "ImageObject",
    "url": "https://arq.clinic/blog/images/bpc-157.jpg",
    "name": "BPC-157 peptide vial"
  }
  ```

## 10. Social Sharing Meta Tags

### Open Graph Tags (Facebook, LinkedIn)
Add to every page `<head>`:
```html
<meta property="og:type" content="website" />
<meta property="og:url" content="[Current page URL]" />
<meta property="og:title" content="[Page title]" />
<meta property="og:description" content="[Meta description]" />
<meta property="og:image" content="[Image URL - 1200x630px]" />
<meta property="og:site_name" content="arq.clinic" />
<meta property="og:locale" content="en_IN" />
```

### Twitter Card Tags
```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@arqclinic" />
<meta name="twitter:title" content="[Page title]" />
<meta name="twitter:description" content="[Meta description]" />
<meta name="twitter:image" content="[Image URL]" />
```

### Implementation Checklist
- [ ] Add og:type appropriate to page (article for blog, website for pages)
- [ ] Set og:url to canonical URL
- [ ] Create unique og:image (1200x630px) for each article
- [ ] Add og:locale as en_IN for India focus
- [ ] Test with Facebook Sharing Debugger: https://developers.facebook.com/tools/debug/
- [ ] Test with Twitter Card Validator: https://card-validator.twitter.com/
- [ ] Verify images display correctly in social shares

## 11. Monthly SEO Audit Checklist

### Week 1: Index & Crawl Health
- [ ] Check Google Search Console for crawl errors
- [ ] Verify all pages indexed (compare GSC vs sitemap)
- [ ] Review Core Web Vitals in GSC
- [ ] Check for security issues or manual actions
- [ ] Monitor 404 errors and fix redirects

### Week 2: Keyword Rankings & Traffic
- [ ] Check keyword rankings for target terms:
  - [ ] "modafinil legal india"
  - [ ] "BPC-157 India"
  - [ ] "semaglutide india"
  - [ ] "TRT India"
  - [ ] "telemedicine legal india"
  - [ ] "biohacking supplements"
  - [ ] "longevity stack peter attia"
- [ ] Review GA4 organic search traffic trends
- [ ] Identify top-performing pages (by traffic & engagement)
- [ ] Identify underperforming pages (low CTR or traffic)
- [ ] Check for ranking drops on key pages

### Week 3: Content & Technical
- [ ] Audit 2-3 pages for on-page SEO:
  - [ ] Title and meta description present and unique
  - [ ] H1 tag present and matches intent
  - [ ] Primary keyword in first 100 words
  - [ ] 2-3 internal links to relevant pages
  - [ ] Images optimized with alt text
  - [ ] Content length appropriate (800+ words for blog)
- [ ] Validate structured data markup
- [ ] Check page load speed (aim for LCP < 2.5s)
- [ ] Review mobile usability via GSC

### Week 4: Competitive & Opportunity Analysis
- [ ] Identify 5 competitor domains in top 10 for target keywords
- [ ] Analyze competitor backlinks (use Ahrefs, SEMrush, or Moz)
- [ ] Identify content gaps (topics we're not ranking for)
- [ ] Find keyword opportunities with search volume
- [ ] Review blog topics for updated content needs
- [ ] Plan next month's content topics based on data

### Quarterly (Every 3 Months)
- [ ] Full technical SEO audit
- [ ] Backlink profile analysis
- [ ] Competitor strategy review
- [ ] Keyword strategy adjustment
- [ ] Content calendar review for relevance
- [ ] Set new traffic and ranking targets

## 12. Link Building & Authority

### Internal Authority Flow
- [ ] Link high-authority pages (homepage, popular articles) to new content
- [ ] Create corner stone content (comprehensive guides) to build authority
- [ ] Link from footer to key pages for consistent authority distribution

### External Link Opportunities
- [ ] Guest post on health/longevity blogs linking to relevant articles
- [ ] Partner with medical influencers for mentions
- [ ] Get listed in health/pharmaceutical directories
- [ ] Reach out to complementary services for backlinks
- [ ] Create linkable assets (surveys, research, tools)

### Backlink Monitoring
- [ ] Monitor new backlinks via Google Search Console
- [ ] Use Ahrefs or SEMrush to track referring domains
- [ ] Remove or disavow spammy backlinks
- [ ] Aim for 2-3 quality backlinks per month initially

## 13. Mobile Optimization

- [ ] Responsive design tested on all devices
- [ ] Touch targets at least 48x48px
- [ ] Readable text (16px minimum)
- [ ] No horizontal scroll
- [ ] Click-to-call links on contact info
- [ ] Mobile menu accessible and clear
- [ ] Images scale properly
- [ ] Forms optimized for touch input
- [ ] Test with Google Mobile-Friendly Test: https://search.google.com/test/mobile-friendly

## 14. International & Local SEO (India Focus)

### Local SEO Setup
- [ ] Add hreflang tags: `<link rel="alternate" hreflang="en-IN" href="https://arq.clinic/" />`
- [ ] Create Google Business Profile for arq.clinic (if applicable)
- [ ] Target location-specific keywords: "modafinil legal india", "[product] india"
- [ ] Include India-related content and case studies
- [ ] List on Indian healthcare directories

### Language & Locale
- [ ] Content targeting Indian audience (mention INR pricing, Indian regulations)
- [ ] Use English (Indian) spelling where applicable
- [ ] Reference Indian pharmaceutical regulations and laws
- [ ] Mention Indian cities/states in local content

## 15. SEO Monitoring Tools & Dashboards

### Essential Tools
- [ ] Google Search Console (free): https://search.google.com/search-console/
- [ ] Google Analytics 4 (free): https://analytics.google.com/
- [ ] Google PageSpeed Insights (free): https://pagespeed.web.dev/
- [ ] Google Rich Results Test (free): https://search.google.com/test/rich-results
- [ ] Lighthouse (free, built into Chrome): Chrome DevTools > Lighthouse

### Recommended Paid Tools (Optional)
- [ ] Ahrefs: Backlink analysis, keyword research, rank tracking
- [ ] SEMrush: Keyword research, competitor analysis, audit
- [ ] Moz: Domain authority, link analysis, local SEO
- [ ] Screaming Frog: Technical SEO audit, crawl analysis

### Dashboard Setup
- [ ] Create Google Analytics dashboard showing:
  - [ ] Organic traffic by device
  - [ ] Top landing pages
  - [ ] Conversion rate by source
  - [ ] User engagement metrics
- [ ] GSC dashboard showing:
  - [ ] Clicks and impressions by query
  - [ ] Average position for target keywords
  - [ ] Core Web Vitals status

## Notes & Important Reminders

- **Keyword Research**: Start with tools like Google Trends, Ahrefs, or SEMrush to identify high-volume, low-competition keywords in the medical/wellness space
- **Medical Content**: Follow E-E-A-T guidelines (Experience, Expertise, Authority, Trustworthiness) for all health content
- **Legal Compliance**: Ensure all medical claims are backed by research; include disclaimers where appropriate
- **Content Freshness**: Update blog articles quarterly with new information, studies, and regulations
- **Avoid Black Hat**: Never use keyword stuffing, cloaking, private link networks, or other manipulative tactics
- **India-Specific**: Remember the Indian market—reference Indian law, regulations, pricing in INR, and telemedicine guidelines

---

**Last Updated:** 2026-04-04
**Next Review:** 2026-05-04
