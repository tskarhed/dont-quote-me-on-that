-- ==============================
-- Invite-only Quotes App Schema
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

-- Policy: anyone can read quotes
create policy "anyone can read quotes"
on quotes for select
using (true);

-- Policy: logged-in users can add quotes
create policy "logged-in users can add quotes"
on quotes for insert
with check (auth.uid() = created_by);

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
-- Invites
-- ------------------------------
create table if not exists invites (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  used boolean default false,
  created_by uuid references auth.users
);

alter table invites enable row level security;

-- Policy: only admins can insert invites
create policy "admins can create invites"
on invites for insert
WITH CHECK (    
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- Policy: users can read their own invite (optional)
create policy "users can read their own invite"
on invites for select
using (email = auth.email());

-- ------------------------------
-- Auto-insert profile on signup
-- ------------------------------
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, role) values (new.id, 'user');
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function handle_new_user();

-- ==============================
-- End of migration
-- ==============================
