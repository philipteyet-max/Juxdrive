-- ═══════════════════════════════════════════════════
-- JUXDRIVE — SUPABASE DATABASE SCHEMA
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════

-- ─── BOOKINGS TABLE ───────────────────────────────
create table if not exists bookings (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default now(),

  -- Personal Details
  full_name text not null,
  phone text not null,
  emergency_number text,
  email text,

  -- Ride Details
  pickup_date date not null,
  pickup_time time,
  pickup_location text not null,
  dropoff_location text not null,
  purpose text not null,

  -- Vehicle Details
  vehicle_option text default 'personal_car', -- 'personal_car' or 'rent_vehicle'
  vehicle_model text,
  vehicle_make text,
  vehicle_year text,
  transmission text,
  drivetrain text,

  -- Driver preference (optional)
  preferred_driver text,

  -- Booking Status
  status text default 'pending', -- pending, confirmed, in_progress, completed, cancelled
  notes text,

  -- Pricing
  estimated_fare numeric(10,2),
  final_fare numeric(10,2)
);

-- ─── CONTACT MESSAGES TABLE ───────────────────────
create table if not exists contact_messages (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default now(),

  full_name text not null,
  phone text,
  email text not null,
  subject text,
  message text not null,

  status text default 'unread' -- unread, read, replied
);

-- ─── ENABLE ROW LEVEL SECURITY ────────────────────
alter table bookings enable row level security;
alter table contact_messages enable row level security;

-- ─── POLICIES: Allow anyone to INSERT (public form submissions) ───
create policy "Allow public to insert bookings"
  on bookings for insert
  to anon
  with check (true);

create policy "Allow public to insert contact messages"
  on contact_messages for insert
  to anon
  with check (true);

-- ─── POLICIES: Only authenticated admins can SELECT/UPDATE/DELETE ───
create policy "Allow authenticated users to read bookings"
  on bookings for select
  to authenticated
  using (true);

create policy "Allow authenticated users to update bookings"
  on bookings for update
  to authenticated
  using (true);

create policy "Allow authenticated users to read messages"
  on contact_messages for select
  to authenticated
  using (true);

create policy "Allow authenticated users to update messages"
  on contact_messages for update
  to authenticated
  using (true);

-- ─── USEFUL VIEWS FOR ADMIN DASHBOARD ─────────────
create or replace view pending_bookings as
  select
    id,
    created_at,
    full_name,
    phone,
    email,
    pickup_date,
    pickup_time,
    pickup_location,
    dropoff_location,
    purpose,
    vehicle_option,
    preferred_driver,
    status,
    estimated_fare
  from bookings
  where status = 'pending'
  order by created_at desc;

create or replace view todays_bookings as
  select
    id,
    full_name,
    phone,
    pickup_time,
    pickup_location,
    dropoff_location,
    purpose,
    preferred_driver,
    status
  from bookings
  where pickup_date = current_date
  order by pickup_time asc;
