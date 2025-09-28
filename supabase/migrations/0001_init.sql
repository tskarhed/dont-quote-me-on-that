-- ==============================
-- Allowlist-only Quotes App Schema
-- ==============================

-- Enable UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- ------------------------------
-- Profiles
-- ------------------------------
create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  role text check (role in ('admin','user')) default 'user'
);

alter table profiles enable row level security;

-- Policy: users can see their own profile
create policy "users can see own profile"
on profiles for select
using (id = auth.uid());

-- Policy: users can update their own profile (optional)
create policy "users can update own profile"
on profiles for update
using (id = auth.uid());

-- ------------------------------
-- Allowlist
-- ------------------------------
create table if not exists allowlist (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  created_by uuid references auth.users,
  created_at timestamptz default now()
);

alter table allowlist enable row level security;

-- Policy: only admins can manage allowlist
create policy "admins can manage allowlist"
on allowlist for all
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- Policy: users can check if their email is in allowlist
create policy "users can check allowlist"
on allowlist for select
using (email = auth.email());

-- ------------------------------
-- Quotes
-- ------------------------------
create table if not exists quotes (
  id bigint generated always as identity primary key,
  number bigint generated always as identity,
  text text not null,
  author text not null,
  created_at timestamptz default now(),
  created_by uuid references auth.users on delete set null
);

alter table quotes enable row level security;

-- Policy: admins and allowlisted users can read quotes
create policy "admins and allowlisted users can read quotes"
on quotes for select
using (
  auth.uid() is not null and (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    ) or
    exists (
      select 1 from allowlist a
      where a.email = auth.email()
    )
  )
);

-- Policy: admins and allowlisted users can add quotes
create policy "admins and allowlisted users can add quotes"
on quotes for insert
with check (
  auth.uid() = created_by and (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    ) or
    exists (
      select 1 from allowlist a
      where a.email = auth.email()
    )
  )
);

-- Policy: only admins can delete quotes
create policy "only admins can delete quotes"
on quotes for delete
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- ------------------------------
-- Auto-insert profile on signup
-- ------------------------------
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, role) values (new.id, 'user');
  return new;
end;
$$ language plpgsql security definer set search_path = '';

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function handle_new_user();

-- ==============================
-- End of migration
-- ==============================
