# NOORÉ Store — deployment starter

## Included
- `index.html`: current NOORÉ storefront prototype
- `supabase_schema.sql`: starter schema for products, orders, and admin roles


## Deploy the front-end (static)
1. Create a GitHub repository and upload `index.html`.
2. In GitHub: **Settings → Pages**.
3. Choose **Deploy from a branch**, select `main` and `/root`, then Save.
4. Wait for the Pages URL to appear. A custom domain can be added in Pages settings after DNS setup.


## Backend setup
1. Create a Supabase project.
2. Open **SQL Editor**, paste `supabase_schema.sql`, and run it.
3. Create admin user(s) using Supabase Auth; assign their UUIDs to `admin_profiles` from the SQL editor.
4. Create a private Storage bucket for product images and set storage policies.
5. Implement a server-side Edge Function for order creation. It must validate prices against the database, check stock, rate-limit requests, and avoid trusting cart prices from the browser.
6. Integrate a payment provider (e.g., Razorpay) through server-side order creation and signature verification. Keep secret keys server-side only.
7. Connect the storefront and admin dashboard to Supabase using the project URL and anon key. Never expose the service-role key in client code.


## Launch checklist
- [ ] Store name, logo, contact email, phone, and address are finalized.
- [ ] Product images are licensed/owned and uploaded to storage.
- [ ] Product prices, sizes, and stock are verified.
- [ ] Supabase Auth is enabled and admin access tested.
- [ ] RLS policies reviewed and tested as anonymous, customer, staff, and admin.
- [ ] Order-creation function has validation, rate limiting, and stock handling.
- [ ] Payment success/failure/cancel flows tested; webhook signature verified.
- [ ] Shipping, returns, privacy, terms, and contact pages added.
- [ ] Mobile checkout, accessibility, and performance tested.
- [ ] Domain HTTPS and analytics configured.

**Important:** The supplied HTML is a prototype storefront, not a fully integrated production store. This guide and SQL are starter infrastructure; backend/payment integration and live deployment require account credentials, decisions, and testing.

## Backend order starter (new)
1. Apply `supabase_schema.sql` in Supabase SQL Editor.
2. Apply `supabase/noore_create_order.sql` after the base schema.
3. Set Edge Function secrets for `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY`.
4. Deploy `supabase/functions/create-order/index.ts` as `create-order`.
5. Test only with non-real customer data until all validation, security, rate-limit, stock, email, and privacy checks are complete.

The starter calculates prices from the database and locks product rows while checking stock. It does not implement payment, shipping-rate calculation, email/SMS notifications, or persistent rate limiting. Review and test before production.
