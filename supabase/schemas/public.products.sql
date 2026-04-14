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

create table public.products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  name text not null,
  in_stock boolean not null,
  qty_needed double precision not null default 0,
  note_id uuid references public.notes on delete set null,
  qty_increment double precision not null default 1,
  unit_of_measure text not null default '',
  tracking_mode text
);

comment on table public.products is 'Individual items within the master product list, including stock status and tracking metadata.';

create trigger set_server_updated_at
  before update on public.products
  for each row
  execute function moddatetime (server_updated_at);

alter table public.products enable row level security;

create policy "Subscribed users can manage their own products"
  on public.products
  for all
  to authenticated
  using (
    (select auth.uid()) = products.user_id 
  )
  with check (
    (select auth.uid()) = products.user_id 
    and ((select auth.jwt()) -> 'app_metadata' ->> 'is_subscribed')::boolean = true
  );

grant select, insert, update, delete on table public.products to authenticated;
grant all on table public.products to service_role;
revoke all on table public.products from anon;