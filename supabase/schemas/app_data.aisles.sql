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

create table app_data.aisles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  name text not null,
  location_id uuid not null references app_data.locations,
  rank integer not null,
  is_default boolean not null default false --,
  -- expanded boolean not null default true
);

comment on table app_data.aisles is 'Categorization zones within a shopping location, used to group products.';

create trigger set_server_updated_at
  before update on app_data.aisles
  for each row
  execute function moddatetime (server_updated_at);

alter table app_data.aisles enable row level security;

create policy "Users can manage their own aisles"
  on app_data.aisles
  for all
  to authenticated
  using (
    (select auth.uid()) = aisles.user_id
  )
  with check (
    (select auth.uid()) = aisles.user_id
  );

create unique index aisles_active_natural_key_idx 
ON app_data.aisles (user_id, name, location_id) 
WHERE is_deleted = false;

grant select, insert, update, delete on table app_data.aisles to authenticated;
grant all on table app_data.aisles to service_role;
revoke all on table app_data.aisles from anon;