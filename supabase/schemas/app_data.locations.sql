-- Copyright (C) 2026 aisleron.com
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

create table app_data.locations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  type text not null,
  default_filter text not null,
  name text not null,
  pinned boolean not null,
  -- show_default_aisle boolean not null default true,
  note_id uuid references app_data.notes on delete set null,
  -- expanded boolean not null default true,
  rank integer not null
);

comment on table app_data.locations is 'Physical or digital shopping venues (e.g., "Main Street Supermarket" or "Weekly Meal Plan").';

create trigger set_server_updated_at
  before update on app_data.locations
  for each row
  execute function moddatetime (server_updated_at);

alter table app_data.locations enable row level security;

create policy "Users can manage their own locations"
  on app_data.locations
  for all
  to authenticated
  using (
    (select auth.uid()) = locations.user_id
  )
  with check (
    (select auth.uid()) = locations.user_id
  );

create unique index locations_active_natural_key_idx 
ON app_data.locations (user_id, name, type) 
WHERE is_deleted = false;

grant select, insert, update, delete on table app_data.locations to authenticated;
grant all on table app_data.locations to service_role;
revoke all on table app_data.locations from anon;