-- NOORE production backend starter (Supabase PostgreSQL)
-- Run in Supabase Dashboard > SQL Editor. Review policies before launch.
create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  category text not null,
  description text,
  price_inr integer not null check (price_inr >= 0),
  compare_at_price_inr integer check (compare_at_price_inr >= 0),
  image_url text,
  sizes text[] default '{}',
  stock integer not null default 0 check (stock >= 0),
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text unique not null,
  customer_name text not null,
  email text,
  phone text not null,
  shipping_address jsonb not null,
  items jsonb not null,
  subtotal_inr integer not null check (subtotal_inr >= 0),
  shipping_inr integer not null default 0 check (shipping_inr >= 0),
  total_inr integer not null check (total_inr >= 0),
  payment_status text not null default 'pending' check (payment_status in ('pending','paid','failed','refunded')),
  order_status text not null default 'placed' check (order_status in ('placed','confirmed','packed','shipped','delivered','cancelled')),
  created_at timestamptz not null default now()
);


create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin' check (role in ('admin','staff')),
  created_at timestamptz not null default now()
);


alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.admin_profiles enable row level security;


-- Published product read access. Admin writes require authenticated admin/staff membership.
create policy "Public can view published products" on public.products
for select using (is_published = true);
create policy "Admins manage products" on public.products
for all to authenticated using (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()));
-- Orders are private. Admin/staff can view and update them.
create policy "Admins manage orders" on public.orders
for all to authenticated using (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()));
create policy "Admins view profiles" on public.admin_profiles
for select to authenticated using (user_id = auth.uid());
-- For customer order submission, implement a server-side Edge Function with validation,
-- stock checks, rate limiting and payment verification. Do NOT enable anonymous insert
-- on orders or expose service-role keys in the browser.
