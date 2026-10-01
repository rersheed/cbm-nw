-- CBM-NW simplify to Member + Admin only
-- Parent must apply this migration to project awoliraufydoeaoorutm
--
-- PRIVACY NOTES (demo-open RLS kept for now):
-- * anon policies still allow full table access for demo/prototyping.
-- * VIN and voter_card_url are sensitive — never expose on public QR / member card.
-- * App logic: members see own profile only; admins see all including voter card.
-- * Before production: tighten RLS so members SELECT/UPDATE own row by auth.uid();
--   admins via admins table; hide vin/voter_card_url from non-admin clients.

create extension if not exists "pgcrypto";

-- Narrow app_role conceptually to member|admin (keep enum values for compatibility;
-- new code only uses member + admin profiles / admins table).
do $$ begin
  alter type public.app_role add value if not exists 'member';
exception when duplicate_object then null;
end $$;

-- Polling units (replaces communities for registration location leaf)
create table if not exists public.polling_units (
  id uuid primary key default gen_random_uuid(),
  ward_id uuid not null references public.wards(id) on delete cascade,
  code text not null,
  name text not null,
  created_at timestamptz not null default now(),
  unique (ward_id, code)
);
create index if not exists polling_units_ward_id_idx on public.polling_units(ward_id);

-- Members: registration + voter fields
alter table public.members add column if not exists email text;
alter table public.members add column if not exists polling_unit_id uuid references public.polling_units(id);
alter table public.members add column if not exists is_registered_voter boolean not null default false;
alter table public.members add column if not exists vin text;
alter table public.members add column if not exists voter_card_url text;
alter table public.members add column if not exists membership_number text;
alter table public.members add column if not exists rejected_at timestamptz;
alter table public.members add column if not exists rejected_by uuid references public.profiles(id);

-- Backfill membership_number from legacy member_code where present
update public.members
set membership_number = member_code
where membership_number is null and member_code is not null;

create unique index if not exists members_membership_number_uidx
  on public.members(membership_number)
  where membership_number is not null;

create index if not exists members_polling_unit_id_idx on public.members(polling_unit_id);
create index if not exists members_vin_idx on public.members(vin) where vin is not null;
create index if not exists members_phone_idx on public.members(phone);

-- Make category optional for simplified registration (occupation is free text)
alter table public.members alter column category drop not null;

-- Admins table (simple admin roster; demo open)
create table if not exists public.admins (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid,
  full_name text not null,
  phone text,
  email text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Soft-drop unused coordinator bits where safe (keep tables for history;
-- messages/comms module unused by simplified app)
comment on table public.messages is 'DEPRECATED for CBM-NW simplify — communication module removed from app';
comment on table public.communities is 'DEPRECATED — use polling_units as location leaf';
comment on column public.members.community_id is 'DEPRECATED — prefer polling_unit_id';
comment on column public.members.id_document_url is 'DEPRECATED — use voter_card_url for voter card';
comment on column public.members.member_code is 'DEPRECATED — use membership_number (CBM-NW-{STATE}-{######})';

-- RLS for new tables (demo-open — tighten before production)
alter table public.polling_units enable row level security;
alter table public.admins enable row level security;

do $$ begin
  create policy anon_all_polling_units on public.polling_units for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_admins on public.admins for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;

-- Seed a few polling units under existing demo wards (if any)
insert into public.polling_units (ward_id, code, name)
select w.id, 'PU01', w.name || ' PU 01'
from public.wards w
where not exists (
  select 1 from public.polling_units p where p.ward_id = w.id and p.code = 'PU01'
)
limit 20;

insert into public.polling_units (ward_id, code, name)
select w.id, 'PU02', w.name || ' PU 02'
from public.wards w
where not exists (
  select 1 from public.polling_units p where p.ward_id = w.id and p.code = 'PU02'
)
limit 20;

insert into public.polling_units (ward_id, code, name)
select w.id, 'PU03', w.name || ' PU 03'
from public.wards w
where not exists (
  select 1 from public.polling_units p where p.ward_id = w.id and p.code = 'PU03'
)
limit 10;

-- Demo admin roster row
insert into public.admins (full_name, phone, email)
select 'Situation Room Admin', '08030000005', 'admin@cbm-nw.demo'
where not exists (select 1 from public.admins where phone = '08030000005');
