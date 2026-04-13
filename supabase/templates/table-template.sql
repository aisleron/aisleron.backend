-- TEMPLATE: New Aisleron Table (Dual-Timestamp Sync)
-- Replace {{table_name}} with your entity name

create table {{schema}}.{{table_name}} (
  -- 1. Identity (UUIDs are mandatory for reliable sync)
  id uuid primary key default gen_random_uuid(),
  
  -- 2. Ownership
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  
  -- 3. The "Truth" Timestamp (Managed by Android/Kotlin)
  -- Use this for Conflict Resolution: "Which version is newer?"
  client_updated_at timestamptz not null default now(),
  
  -- 4. The "Pointer" Timestamp (Managed by Supabase)
  -- Use this for the Fetch Query: "What has arrived since my last sync?"
  server_updated_at timestamptz not null default now(),
  
  -- 5. Sync Flags
  is_deleted boolean not null default false,
  
  -- 6. Entity Data, add entity specific attributes here, e.g.:
  name text not null,
  ...
);

comment on table {{schema}}.{{table_name}} is '{{comment}}';


-- 7. The "Pointer" Trigger
-- This ensures server_updated_at ALWAYS updates to the current global time 
-- on the server, even if the client tries to send its own value.
create trigger set_server_updated_at
  before update on {{schema}}.{{table_name}}
  for each row
  execute function moddatetime (server_updated_at);

-- 8. Security
alter table {{schema}}.{{table_name}} enable row level security;

-- Unsubscribed users can view and delete their data
-- Only subscribed users can add or edit their data
create policy "Subscribed users can manage their own {{table_name}}"
  on {{schema}}.{{table_name}}
  for all 
  to authenticated
  using (
    (select auth.uid()) = {{table_name}}.user_id 
  )
  with check (
    (select auth.uid()) = {{table_name}}.user_id 
    and ((select auth.jwt()) -> 'app_metadata' ->> 'is_subscribed')::boolean = true
  );

-- 9. Grants
grant select, insert, update, delete on table {{schema}}.{{table_name}} to authenticated;
grant all on table {{schema}}.{{table_name}} to service_role;
revoke all on table {{schema}}.{{table_name}} from anon;