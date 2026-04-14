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

create table public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  note_text text not null
);

comment on table public.notes is 'Generic text entries linked to products or locations for additional user context.';

create trigger set_server_updated_at
  before update on public.notes
  for each row
  execute function moddatetime (server_updated_at);

alter table public.notes enable row level security;

create policy "Subscribed users can manage their own notes"
  on public.notes
  for all 
  to authenticated
  using (
    (select auth.uid()) = notes.user_id 
  )
  with check (
    (select auth.uid()) = notes.user_id 
    and ((select auth.jwt()) -> 'app_metadata' ->> 'is_subscribed')::boolean = true
  );

grant select, insert, update, delete on table public.notes to authenticated;
grant all on table public.notes to service_role;
revoke all on table public.notes from anon;