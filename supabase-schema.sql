-- ============================================================
-- MALLARDS TRAINING APP — SUPABASE SCHEMA
-- Run this in your Supabase SQL Editor (Settings > SQL Editor)
-- ============================================================

-- ── TRACKS ──────────────────────────────────────────────────
create table if not exists tracks (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  position_key text not null unique, -- 'foh_server', 'foh_support', 'bar', 'kitchen', 'management'
  color text default '#1B3A6B',
  created_at timestamptz default now()
);

-- ── MODULES ─────────────────────────────────────────────────
create table if not exists modules (
  id uuid primary key default gen_random_uuid(),
  track_id uuid references tracks(id) on delete cascade not null,
  title text not null,
  description text,
  order_index integer not null,
  created_at timestamptz default now()
);

-- ── MODULE ITEMS (videos, text, checklist) ───────────────────
create table if not exists module_items (
  id uuid primary key default gen_random_uuid(),
  module_id uuid references modules(id) on delete cascade not null,
  type text not null check (type in ('video', 'checklist', 'info')),
  title text not null,
  content text,   -- video URL for 'video', body text for 'info', task description for 'checklist'
  order_index integer not null,
  created_at timestamptz default now()
);

-- ── PROFILES (extends auth.users) ───────────────────────────
create table if not exists profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text not null,
  role text not null default 'employee' check (role in ('employee', 'manager', 'admin')),
  track_id uuid references tracks(id),
  hire_date date default current_date,
  created_at timestamptz default now()
);

-- ── EMPLOYEE PROGRESS ────────────────────────────────────────
create table if not exists employee_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  module_item_id uuid references module_items(id) on delete cascade not null,
  completed_at timestamptz default now(),
  unique(user_id, module_item_id)
);

-- ── ROW LEVEL SECURITY ───────────────────────────────────────
alter table tracks enable row level security;
alter table modules enable row level security;
alter table module_items enable row level security;
alter table profiles enable row level security;
alter table employee_progress enable row level security;

-- Everyone can read tracks, modules, items (needed for training)
create policy "Public read tracks" on tracks for select using (true);
create policy "Public read modules" on modules for select using (true);
create policy "Public read module_items" on module_items for select using (true);

-- Profiles: users can read/update their own; managers/admins can read all
create policy "Users read own profile" on profiles for select using (auth.uid() = id);
create policy "Users update own profile" on profiles for update using (auth.uid() = id);
create policy "Managers read all profiles" on profiles for select using (
  exists (select 1 from profiles where id = auth.uid() and role in ('manager', 'admin'))
);
create policy "Admins insert profiles" on profiles for insert with check (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Progress: employees manage their own; managers/admins can read all
create policy "Users manage own progress" on employee_progress
  for all using (auth.uid() = user_id);
create policy "Managers read all progress" on employee_progress for select using (
  exists (select 1 from profiles where id = auth.uid() and role in ('manager', 'admin'))
);

-- Admins can manage all content
create policy "Admins manage tracks" on tracks for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Admins manage modules" on modules for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Admins manage module_items" on module_items for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Auto-create profile on signup
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'New Employee'),
    coalesce(new.raw_user_meta_data->>'role', 'employee')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();


-- ============================================================
-- SEED DATA — TRAINING TRACKS & MODULES
-- ============================================================

-- TRACKS
insert into tracks (id, name, description, position_key, color) values
  ('11111111-0000-0000-0000-000000000001', 'FOH Server', 'Training track for servers — table service, POS, menu knowledge, and Southern Hospitality.', 'foh_server', '#1B3A6B'),
  ('11111111-0000-0000-0000-000000000002', 'FOH Support Staff', 'Training track for Hosts, Takeout, and Food Runners — the backbone of the guest experience.', 'foh_support', '#2E6DA4'),
  ('11111111-0000-0000-0000-000000000003', 'Bar', 'Training track for bartenders — drink knowledge, service standards, and responsible alcohol service.', 'bar', '#1B3A6B'),
  ('11111111-0000-0000-0000-000000000004', 'Kitchen', 'Training track for kitchen staff — food safety, station setup, recipes, and execution standards.', 'kitchen', '#C0392B'),
  ('11111111-0000-0000-0000-000000000005', 'Management', 'Training track for managers — leadership, operations, financials, and team management.', 'management', '#27AE60')
on conflict do nothing;


-- ── FOH SERVER MODULES ──────────────────────────────────────
insert into modules (id, track_id, title, description, order_index) values
  ('aaaa0001-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'Welcome to Mallards', 'Learn who we are, where we came from, and what Southern Hospitality means to us.', 1),
  ('aaaa0001-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000001', 'Policies & Standards', 'Everything you need to know about uniforms, SOPs, and how we operate.', 2),
  ('aaaa0001-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000001', 'Food Safety & Sanitation', 'Keep our guests and team safe with proper food handling and hygiene.', 3),
  ('aaaa0001-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000001', 'Server Training', 'Table service steps, POS system, menu knowledge, and upselling.', 4),
  ('aaaa0001-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000001', 'Final Sign-Off', 'Complete your certification and get your manager sign-off.', 5)
on conflict do nothing;

-- FOH Server Module Items
insert into module_items (module_id, type, title, content, order_index) values
  -- Module 1: Welcome
  ('aaaa0001-0000-0000-0000-000000000001', 'video', 'Welcome to the Mallards Family', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0001-0000-0000-0000-000000000001', 'info', 'Our Story', 'Mallards started in 2013 at the Bayport Marina on the St. Croix River with one goal: serve incredible food that brings people together. We''ve been named Best Seafood Restaurant in the East Metro three years in a row, and our Lobster Rolls have been featured on Twin Cities Live!', 2),
  ('aaaa0001-0000-0000-0000-000000000001', 'checklist', 'Read the full Employee Handbook', null, 3),
  ('aaaa0001-0000-0000-0000-000000000001', 'checklist', 'Understand Southern Hospitality — greet first, be proactive, make every guest feel like a VIP', null, 4),
  ('aaaa0001-0000-0000-0000-000000000001', 'checklist', 'Learn The Mallards Way: Look good, Be on time, Have fun, Make money', null, 5),
  -- Module 2: Policies
  ('aaaa0001-0000-0000-0000-000000000002', 'video', 'Policies & Uniform Standards Overview', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0001-0000-0000-0000-000000000002', 'info', 'FOH Uniform', 'Mallards logo T-shirt, dark blue jeans or khaki cargo shorts (no leggings/sweatpants), clean black apron, 5 pens, and a wine key. Always smile and take pride in your appearance!', 2),
  ('aaaa0001-0000-0000-0000-000000000002', 'checklist', 'Confirm your uniform is complete and ready for your first shift', null, 3),
  ('aaaa0001-0000-0000-0000-000000000002', 'checklist', 'Know how to clock in/out — if you forget, notify a manager immediately', null, 4),
  ('aaaa0001-0000-0000-0000-000000000002', 'checklist', 'Review time-off policy — requests must be submitted at least 14 days in advance', null, 5),
  ('aaaa0001-0000-0000-0000-000000000002', 'checklist', 'Understand the harassment policy and know to report issues to your General Manager', null, 6),
  -- Module 3: Food Safety
  ('aaaa0001-0000-0000-0000-000000000003', 'video', 'Food Safety & Handwashing', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0001-0000-0000-0000-000000000003', 'info', 'Temperature Danger Zone', 'The danger zone is 40°F–140°F. Food in the danger zone for more than 4 hours must be discarded. Cold storage: 34–40°F. Hot holding: 160–180°F. When in doubt, ask a manager.', 2),
  ('aaaa0001-0000-0000-0000-000000000003', 'checklist', 'Demonstrate proper handwashing technique to a manager (20+ seconds, soap, dry with paper towel)', null, 3),
  ('aaaa0001-0000-0000-0000-000000000003', 'checklist', 'Know when to wash hands: before food handling, after restroom, after touching face/hair, after garbage', null, 4),
  -- Module 4: Server Training
  ('aaaa0001-0000-0000-0000-000000000004', 'video', 'Table Service Steps & POS System', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0001-0000-0000-0000-000000000004', 'video', 'Menu Walkthrough & Upselling', 'https://www.youtube.com/embed/PLACEHOLDER', 2),
  ('aaaa0001-0000-0000-0000-000000000004', 'checklist', 'Shadow an experienced server for 2 full shifts', null, 3),
  ('aaaa0001-0000-0000-0000-000000000004', 'checklist', 'Complete a practice run on the POS system with a manager', null, 4),
  ('aaaa0001-0000-0000-0000-000000000004', 'checklist', 'Memorize the top 10 menu items and their descriptions', null, 5),
  ('aaaa0001-0000-0000-0000-000000000004', 'checklist', 'Know all allergen information for the menu', null, 6),
  ('aaaa0001-0000-0000-0000-000000000004', 'checklist', 'Complete one full section solo with manager observation', null, 7),
  -- Module 5: Sign-Off
  ('aaaa0001-0000-0000-0000-000000000005', 'checklist', 'Pass the menu knowledge quiz (80% or higher)', null, 1),
  ('aaaa0001-0000-0000-0000-000000000005', 'checklist', 'Receive manager sign-off on service quality', null, 2),
  ('aaaa0001-0000-0000-0000-000000000005', 'checklist', 'Complete and submit your signed Employee Handbook acknowledgment', null, 3)
on conflict do nothing;


-- ── FOH SUPPORT STAFF MODULES ───────────────────────────────
insert into modules (id, track_id, title, description, order_index) values
  ('aaaa0002-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000002', 'Welcome to Mallards', 'Learn who we are, where we came from, and what Southern Hospitality means to us.', 1),
  ('aaaa0002-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000002', 'Policies & Standards', 'Everything you need to know about uniforms, SOPs, and how we operate.', 2),
  ('aaaa0002-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000002', 'Food Safety & Sanitation', 'Keep our guests and team safe with proper food handling and hygiene.', 3),
  ('aaaa0002-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000002', 'Host & Seating Training', 'First impressions, waitlist management, and seating flow.', 4),
  ('aaaa0002-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000002', 'Takeout & Food Runner Training', 'Takeout order accuracy, packaging, and food runner delivery standards.', 5),
  ('aaaa0002-0000-0000-0000-000000000006', '11111111-0000-0000-0000-000000000002', 'Final Sign-Off', 'Complete your certification and get your manager sign-off.', 6)
on conflict do nothing;

insert into module_items (module_id, type, title, content, order_index) values
  -- Module 1: Welcome (same content)
  ('aaaa0002-0000-0000-0000-000000000001', 'video', 'Welcome to the Mallards Family', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0002-0000-0000-0000-000000000001', 'info', 'Our Story', 'Mallards started in 2013 at the Bayport Marina on the St. Croix River with one goal: serve incredible food that brings people together. We''ve been named Best Seafood Restaurant in the East Metro three years in a row!', 2),
  ('aaaa0002-0000-0000-0000-000000000001', 'checklist', 'Read the full Employee Handbook', null, 3),
  ('aaaa0002-0000-0000-0000-000000000001', 'checklist', 'Understand Southern Hospitality — greet first, be proactive, make every guest feel like a VIP', null, 4),
  ('aaaa0002-0000-0000-0000-000000000001', 'checklist', 'Learn The Mallards Way: Look good, Be on time, Have fun, Make money', null, 5),
  -- Module 2: Policies
  ('aaaa0002-0000-0000-0000-000000000002', 'video', 'Policies & Uniform Standards Overview', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0002-0000-0000-0000-000000000002', 'info', 'FOH Uniform', 'Mallards logo T-shirt, dark blue jeans or khaki cargo shorts (no leggings/sweatpants), clean black apron, 5 pens, and a wine key. Always smile and take pride in your appearance!', 2),
  ('aaaa0002-0000-0000-0000-000000000002', 'checklist', 'Confirm your uniform is complete and ready for your first shift', null, 3),
  ('aaaa0002-0000-0000-0000-000000000002', 'checklist', 'Know how to clock in/out — if you forget, notify a manager immediately', null, 4),
  ('aaaa0002-0000-0000-0000-000000000002', 'checklist', 'Review time-off policy — requests must be submitted at least 14 days in advance', null, 5),
  ('aaaa0002-0000-0000-0000-000000000002', 'checklist', 'Understand the harassment policy and know to report issues to your General Manager', null, 6),
  -- Module 3: Food Safety
  ('aaaa0002-0000-0000-0000-000000000003', 'video', 'Food Safety & Handwashing', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0002-0000-0000-0000-000000000003', 'info', 'Temperature Danger Zone', 'The danger zone is 40°F–140°F. Food in the danger zone for more than 4 hours must be discarded. Cold storage: 34–40°F. Hot holding: 160–180°F. When in doubt, ask a manager.', 2),
  ('aaaa0002-0000-0000-0000-000000000003', 'checklist', 'Demonstrate proper handwashing technique to a manager', null, 3),
  ('aaaa0002-0000-0000-0000-000000000003', 'checklist', 'Know when to wash hands: before food handling, after restroom, after touching face/hair, after garbage', null, 4),
  -- Module 4: Host Training
  ('aaaa0002-0000-0000-0000-000000000004', 'video', 'Hosting & Seating Flow', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0002-0000-0000-0000-000000000004', 'checklist', 'Greet every guest within 30 seconds of arrival — always with a smile and "Welcome to Mallards!"', null, 2),
  ('aaaa0002-0000-0000-0000-000000000004', 'checklist', 'Learn the floor plan and table numbering system', null, 3),
  ('aaaa0002-0000-0000-0000-000000000004', 'checklist', 'Understand waitlist management and how to quote accurate wait times', null, 4),
  ('aaaa0002-0000-0000-0000-000000000004', 'checklist', 'Know how to rotate sections evenly and communicate with servers', null, 5),
  -- Module 5: Takeout & Food Runner
  ('aaaa0002-0000-0000-0000-000000000005', 'video', 'Takeout & Food Runner Standards', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0002-0000-0000-0000-000000000005', 'checklist', 'Learn the takeout order process — how to confirm, package, and hand off orders accurately', null, 2),
  ('aaaa0002-0000-0000-0000-000000000005', 'checklist', 'Know food runner delivery steps — verify table, announce dishes, communicate with kitchen', null, 3),
  ('aaaa0002-0000-0000-0000-000000000005', 'checklist', 'Understand how to handle guest complaints on takeout orders', null, 4),
  ('aaaa0002-0000-0000-0000-000000000005', 'checklist', 'Shadow an experienced food runner for 1 full shift', null, 5),
  -- Module 6: Sign-Off
  ('aaaa0002-0000-0000-0000-000000000006', 'checklist', 'Pass the role knowledge check with your manager', null, 1),
  ('aaaa0002-0000-0000-0000-000000000006', 'checklist', 'Receive manager sign-off on guest interaction quality', null, 2),
  ('aaaa0002-0000-0000-0000-000000000006', 'checklist', 'Complete and submit your signed Employee Handbook acknowledgment', null, 3)
on conflict do nothing;


-- ── BAR MODULES ─────────────────────────────────────────────
insert into modules (id, track_id, title, description, order_index) values
  ('aaaa0003-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000003', 'Welcome to Mallards', 'Learn who we are, where we came from, and what Southern Hospitality means to us.', 1),
  ('aaaa0003-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000003', 'Policies & Standards', 'Uniforms, SOPs, and how we operate.', 2),
  ('aaaa0003-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000003', 'Food Safety & Sanitation', 'Proper hygiene and food safety behind the bar.', 3),
  ('aaaa0003-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000003', 'Bar Setup & Spirits Knowledge', 'Bar opening procedures, product knowledge, and drink builds.', 4),
  ('aaaa0003-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000003', 'Responsible Alcohol Service', 'MN alcohol service laws, ID checking, and cutting off guests safely.', 5),
  ('aaaa0003-0000-0000-0000-000000000006', '11111111-0000-0000-0000-000000000003', 'Final Sign-Off', 'Complete your certification and get your manager sign-off.', 6)
on conflict do nothing;

insert into module_items (module_id, type, title, content, order_index) values
  ('aaaa0003-0000-0000-0000-000000000001', 'video', 'Welcome to the Mallards Family', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0003-0000-0000-0000-000000000001', 'checklist', 'Read the full Employee Handbook', null, 2),
  ('aaaa0003-0000-0000-0000-000000000001', 'checklist', 'Understand Southern Hospitality and The Mallards Way', null, 3),
  ('aaaa0003-0000-0000-0000-000000000002', 'video', 'Policies & Uniform Standards', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0003-0000-0000-0000-000000000002', 'checklist', 'Confirm your uniform is ready', null, 2),
  ('aaaa0003-0000-0000-0000-000000000002', 'checklist', 'Know clock-in/out procedures', null, 3),
  ('aaaa0003-0000-0000-0000-000000000002', 'checklist', 'Review time-off and harassment policies', null, 4),
  ('aaaa0003-0000-0000-0000-000000000003', 'video', 'Food Safety & Handwashing', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0003-0000-0000-0000-000000000003', 'checklist', 'Demonstrate handwashing technique to a manager', null, 2),
  ('aaaa0003-0000-0000-0000-000000000003', 'checklist', 'Know temperature danger zone and when to discard food/garnishes', null, 3),
  ('aaaa0003-0000-0000-0000-000000000004', 'video', 'Bar Setup & Spirits Overview', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0003-0000-0000-0000-000000000004', 'video', 'Signature Cocktails & Menu Drinks', 'https://www.youtube.com/embed/PLACEHOLDER', 2),
  ('aaaa0003-0000-0000-0000-000000000004', 'checklist', 'Complete bar opening and closing checklist with a manager', null, 3),
  ('aaaa0003-0000-0000-0000-000000000004', 'checklist', 'Know all spirits, wines, and beers on the menu', null, 4),
  ('aaaa0003-0000-0000-0000-000000000004', 'checklist', 'Build all signature cocktails correctly in front of a manager', null, 5),
  ('aaaa0003-0000-0000-0000-000000000005', 'video', 'Responsible Alcohol Service (MN Law)', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0003-0000-0000-0000-000000000005', 'checklist', 'Know how to check IDs — valid forms of ID and what to look for', null, 2),
  ('aaaa0003-0000-0000-0000-000000000005', 'checklist', 'Know when and how to cut off a guest safely', null, 3),
  ('aaaa0003-0000-0000-0000-000000000005', 'checklist', 'Understand Mallards'' liability policy around alcohol service', null, 4),
  ('aaaa0003-0000-0000-0000-000000000006', 'checklist', 'Pass the bar knowledge quiz with a manager', null, 1),
  ('aaaa0003-0000-0000-0000-000000000006', 'checklist', 'Receive manager sign-off after observed shift behind the bar', null, 2),
  ('aaaa0003-0000-0000-0000-000000000006', 'checklist', 'Submit signed Employee Handbook acknowledgment', null, 3)
on conflict do nothing;


-- ── KITCHEN MODULES ─────────────────────────────────────────
insert into modules (id, track_id, title, description, order_index) values
  ('aaaa0004-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000004', 'Welcome to Mallards', 'Learn who we are and what we stand for.', 1),
  ('aaaa0004-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000004', 'Policies & Kitchen Standards', 'SOPs, uniform requirements, and how the kitchen operates.', 2),
  ('aaaa0004-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000004', 'Food Safety & Sanitation', 'Non-negotiable safety standards for our kitchen team.', 3),
  ('aaaa0004-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000004', 'Station Training', 'Learn your station, prep standards, and recipe execution.', 4),
  ('aaaa0004-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000004', 'Final Sign-Off', 'Complete your certification and get your manager sign-off.', 5)
on conflict do nothing;

insert into module_items (module_id, type, title, content, order_index) values
  ('aaaa0004-0000-0000-0000-000000000001', 'video', 'Welcome to the Mallards Family', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0004-0000-0000-0000-000000000001', 'checklist', 'Read the full Employee Handbook', null, 2),
  ('aaaa0004-0000-0000-0000-000000000001', 'checklist', 'Understand Southern Hospitality and The Mallards Way', null, 3),
  ('aaaa0004-0000-0000-0000-000000000002', 'video', 'Kitchen Policies & Uniform Standards', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0004-0000-0000-0000-000000000002', 'info', 'Kitchen Uniform', 'Hair must be restrained and covered at all times. No excessive jewelry. Chef pants, jeans, or cargo shorts in clean condition. Slip-resistant shoes are required — no exceptions.', 2),
  ('aaaa0004-0000-0000-0000-000000000002', 'checklist', 'Confirm you have slip-resistant shoes and your hair is always covered', null, 3),
  ('aaaa0004-0000-0000-0000-000000000002', 'checklist', 'Know clock-in/out procedures and time-off policy', null, 4),
  ('aaaa0004-0000-0000-0000-000000000003', 'video', 'Food Safety, Temps & Handwashing', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0004-0000-0000-0000-000000000003', 'info', 'Critical Temperature Rules', 'Cold storage: 34–40°F | Frozen: -10 to 0°F | Hot holding: 160–180°F | Danger zone: 40–140°F. Anything in the danger zone for 4+ hours gets discarded. No exceptions.', 2),
  ('aaaa0004-0000-0000-0000-000000000003', 'checklist', 'Demonstrate proper handwashing to a manager', null, 3),
  ('aaaa0004-0000-0000-0000-000000000003', 'checklist', 'Know and recite temperature guidelines without looking', null, 4),
  ('aaaa0004-0000-0000-0000-000000000003', 'checklist', 'Complete a kitchen cleanliness walkthrough with a manager', null, 5),
  ('aaaa0004-0000-0000-0000-000000000004', 'video', 'Station Setup & Recipe Standards', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0004-0000-0000-0000-000000000004', 'checklist', 'Shadow a lead cook on your station for 2 full shifts', null, 2),
  ('aaaa0004-0000-0000-0000-000000000004', 'checklist', 'Complete your station setup and breakdown independently', null, 3),
  ('aaaa0004-0000-0000-0000-000000000004', 'checklist', 'Execute 5 dishes from your station to manager''s quality standard', null, 4),
  ('aaaa0004-0000-0000-0000-000000000005', 'checklist', 'Pass the food safety knowledge check', null, 1),
  ('aaaa0004-0000-0000-0000-000000000005', 'checklist', 'Receive manager sign-off after observed service', null, 2),
  ('aaaa0004-0000-0000-0000-000000000005', 'checklist', 'Submit signed Employee Handbook acknowledgment', null, 3)
on conflict do nothing;


-- ── MANAGEMENT MODULES ──────────────────────────────────────
insert into modules (id, track_id, title, description, order_index) values
  ('aaaa0005-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000005', 'Welcome to Mallards', 'Leadership starts with understanding what we stand for.', 1),
  ('aaaa0005-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000005', 'Policies, HR & Compliance', 'Harassment policy, scheduling, disciplinary procedures, and HR responsibilities.', 2),
  ('aaaa0005-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000005', 'Food Safety & Health Compliance', 'Manager-level responsibilities for food safety, inspections, and team accountability.', 3),
  ('aaaa0005-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000005', 'Operations & Floor Management', 'Opening/closing, shift management, guest recovery, and team leadership.', 4),
  ('aaaa0005-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000005', 'Financial Accountability', 'Food cost, MarginEdge, labor management, and end-of-night reporting.', 5),
  ('aaaa0005-0000-0000-0000-000000000006', '11111111-0000-0000-0000-000000000005', 'Final Sign-Off', 'Complete management certification.', 6)
on conflict do nothing;

insert into module_items (module_id, type, title, content, order_index) values
  ('aaaa0005-0000-0000-0000-000000000001', 'video', 'Welcome to Management at Mallards', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0005-0000-0000-0000-000000000001', 'checklist', 'Read and internalize the Employee Handbook — you are now responsible for enforcing it', null, 2),
  ('aaaa0005-0000-0000-0000-000000000001', 'checklist', 'Understand Southern Hospitality at a leadership level — model it for your team daily', null, 3),
  ('aaaa0005-0000-0000-0000-000000000002', 'video', 'HR, Harassment Policy & Scheduling', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0005-0000-0000-0000-000000000002', 'checklist', 'Know the harassment policy inside and out — you are the first point of contact', null, 2),
  ('aaaa0005-0000-0000-0000-000000000002', 'checklist', 'Understand scheduling software and how to manage time-off requests', null, 3),
  ('aaaa0005-0000-0000-0000-000000000002', 'checklist', 'Know how to document and escalate disciplinary incidents', null, 4),
  ('aaaa0005-0000-0000-0000-000000000003', 'video', 'Food Safety Compliance for Managers', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0005-0000-0000-0000-000000000003', 'checklist', 'Know all temperature guidelines and how to train team members on them', null, 2),
  ('aaaa0005-0000-0000-0000-000000000003', 'checklist', 'Complete a full food safety audit walkthrough with a senior manager', null, 3),
  ('aaaa0005-0000-0000-0000-000000000004', 'video', 'Opening, Closing & Floor Management', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0005-0000-0000-0000-000000000004', 'checklist', 'Complete an opening shift solo with senior manager sign-off', null, 2),
  ('aaaa0005-0000-0000-0000-000000000004', 'checklist', 'Complete a closing shift solo with senior manager sign-off', null, 3),
  ('aaaa0005-0000-0000-0000-000000000004', 'checklist', 'Demonstrate how to handle a guest complaint and recovery scenario', null, 4),
  ('aaaa0005-0000-0000-0000-000000000004', 'checklist', 'Know how to run a pre-shift meeting', null, 5),
  ('aaaa0005-0000-0000-0000-000000000005', 'video', 'Food Cost, MarginEdge & Labor', 'https://www.youtube.com/embed/PLACEHOLDER', 1),
  ('aaaa0005-0000-0000-0000-000000000005', 'checklist', 'Complete a MarginEdge food cost review with a senior manager', null, 2),
  ('aaaa0005-0000-0000-0000-000000000005', 'checklist', 'Understand how to read and act on weekly food cost reports', null, 3),
  ('aaaa0005-0000-0000-0000-000000000005', 'checklist', 'Know labor cost targets and how to adjust staffing accordingly', null, 4),
  ('aaaa0005-0000-0000-0000-000000000006', 'checklist', 'Pass the management knowledge assessment', null, 1),
  ('aaaa0005-0000-0000-0000-000000000006', 'checklist', 'Receive final sign-off from the General Manager or Owner', null, 2),
  ('aaaa0005-0000-0000-0000-000000000006', 'checklist', 'Submit signed Employee Handbook acknowledgment', null, 3)
on conflict do nothing;
