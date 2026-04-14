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

create table public.aisle_products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  aisle_id uuid not null references public.aisles,
  product_id uuid not null references public.products,
  rank integer not null
);

comment on table public.aisle_products is 'Mapping table that defines the specific aisle and sort rank for a product within a location.';

create trigger set_server_updated_at
  before update on public.aisle_products
  for each row
  execute function moddatetime (server_updated_at);

alter table public.aisle_products enable row level security;

create policy "Subscribed users can manage their own aisle_products"
  on public.aisle_products
  for all 
  to authenticated
  using (
    (select auth.uid()) = aisle_products.user_id 
  )
  with check (
    (select auth.uid()) = aisle_products.user_id 
    and ((select auth.jwt()) -> 'app_metadata' ->> 'is_subscribed')::boolean = true
  );

grant select, insert, update, delete on table public.aisle_products to authenticated;
grant all on table public.aisle_products to service_role;
-- revoke all on table public.aisle_products from anon;