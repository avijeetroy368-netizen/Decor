# NOORÉ Technical Completion Roadmap (Domain deferred)


## Phase A — Static storefront (current prototype)
- [x] Single-page storefront HTML supplied
- [x] Product cards/collections and demo interactions (inspect in browser)
- [ ] Final brand logo and licensed product photography
- [ ] Final content, product copy, prices, size/stock data
- [ ] Test desktop, mobile, keyboard navigation, contrast, and broken image handling

## Phase B — Secure backend
- [ ] Create Supabase project
- [ ] Run and review `supabase_schema.sql`
- [ ] Enable Auth; create administrator; use MFA if supported
- [ ] Create admin/staff role mapping securely
- [ ] Review and test Row Level Security policies
- [ ] Private product image bucket; validate upload types/sizes and access
- [ ] Edge Function for order creation: calculate totals server-side, validate product IDs/variants, stock, shipping, coupon rules, and rate-limit
- [ ] Stock reservation/adjustment strategy and transaction-safe order handling
- [ ] Customer order lookup only via secure token/auth; do not expose all orders
- [ ] Email order notifications via server-side provider
- [ ] Environment variables and secret management; no service-role/payment secrets in frontend

## Phase C — Payment
- [ ] Select payment provider and complete merchant onboarding
- [ ] Create payment/order server-side
- [ ] Verify signatures server-side
- [ ] Webhook signature verification, idempotency, and replay protection
- [ ] Test success, failure, pending, cancellation, refund, duplicate webhook, and abandoned checkout
- [ ] Keep payment secrets server-side; avoid storing card data

## Phase D — Store operations
- [ ] Product catalog import/template
- [ ] SKU and variant/size inventory
- [ ] Order statuses and admin filters
- [ ] Packing/shipping/tracking process
- [ ] Returns/exchanges/refunds procedure
- [ ] Customer support email/WhatsApp
- [ ] Analytics with consent/privacy review
- [ ] Backup/restore test and incident plan

## Phase E — Launch readiness (domain still deferred until last)
- [ ] Policies and seller/contact information reviewed
- [ ] Pricing, taxes, shipping, cancellation, and refund wording verified
- [ ] Accessibility and performance checks
- [ ] Security checks; no test admin PINs or keys in code
- [ ] Production environment smoke test
- [ ] Hosting deployed on temporary provider URL and verified
- [ ] Only after all checks: purchase/connect domain, configure DNS, verify HTTPS
