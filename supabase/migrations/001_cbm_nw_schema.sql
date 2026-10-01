-- CBM-NW initial schema (PostgreSQL / Supabase)
-- Applied as migration 001_cbm_nw_schema on project awoliraufydoeaoorutm

create extension if not exists "pgcrypto";

do $$ begin
  create type public.app_role as enum (
    'registration_agent', 'ward_coordinator', 'lga_coordinator', 'state_coordinator', 'admin'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.member_category as enum (
    'youth', 'women', 'student', 'professional', 'business', 'volunteer', 'community_leader'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.member_status as enum ('pending', 'approved', 'rejected');
exception when duplicate_object then null;
end $$;

create table if not exists public.states (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.lgas (
  id uuid primary key default gen_random_uuid(),
  state_id uuid not null references public.states(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);
create index if not exists lgas_state_id_idx on public.lgas(state_id);

create table if not exists public.wards (
  id uuid primary key default gen_random_uuid(),
  lga_id uuid not null references public.lgas(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);
create index if not exists wards_lga_id_idx on public.wards(lga_id);

create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  ward_id uuid not null references public.wards(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);
create index if not exists communities_ward_id_idx on public.communities(ward_id);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid,
  full_name text not null,
  phone text,
  role public.app_role not null,
  state_id uuid references public.states(id),
  lga_id uuid references public.lgas(id),
  ward_id uuid references public.wards(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  member_code text unique,
  full_name text not null,
  gender text,
  date_of_birth date,
  phone text,
  occupation text,
  education text,
  category public.member_category not null,
  status public.member_status not null default 'pending',
  state_id uuid references public.states(id),
  lga_id uuid references public.lgas(id),
  ward_id uuid references public.wards(id),
  community_id uuid references public.communities(id),
  photo_url text,
  id_document_url text,
  registered_by uuid references public.profiles(id),
  approved_by uuid references public.profiles(id),
  approved_at timestamptz,
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists members_status_idx on public.members(status);
create index if not exists members_state_id_idx on public.members(state_id);

create table if not exists public.approvals (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  actor_id uuid references public.profiles(id),
  action text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  audience_scope text not null,
  audience_ref text,
  body text not null,
  sent_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id),
  action text not null,
  entity text,
  entity_id uuid,
  meta jsonb,
  created_at timestamptz not null default now()
);

-- Seed NW states
insert into public.states (code, name) values
  ('KD', 'Kaduna'), ('KN', 'Kano'), ('KT', 'Katsina'),
  ('JG', 'Jigawa'), ('KB', 'Kebbi'), ('SO', 'Sokoto'), ('ZA', 'Zamfara')
on conflict (code) do nothing;

-- Demo-open RLS (tighten before production)
alter table public.states enable row level security;
alter table public.lgas enable row level security;
alter table public.wards enable row level security;
alter table public.communities enable row level security;
alter table public.profiles enable row level security;
alter table public.members enable row level security;
alter table public.approvals enable row level security;
alter table public.messages enable row level security;
alter table public.audit_log enable row level security;

do $$ begin
  create policy anon_all_states on public.states for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_lgas on public.lgas for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_wards on public.wards for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_communities on public.communities for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_profiles on public.profiles for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_members on public.members for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_approvals on public.approvals for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_messages on public.messages for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy anon_all_audit on public.audit_log for all to anon using (true) with check (true);
exception when duplicate_object then null; end $$;
