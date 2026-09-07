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

create table app_data.product_variants (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  product_id uuid not null references app_data.products(id) on delete cascade,
  barcode text not null,
  created_at timestamptz not null default now()
);

comment on table app_data.product_variants is 'Different variants of a product based on bar codes, etc.';

create trigger set_server_updated_at
  before update on app_data.product_variants
  for each row
  execute function moddatetime (server_updated_at);

alter table app_data.product_variants enable row level security;

create policy "Users can manage their own product_variants"
  on app_data.product_variants
  for all 
  to authenticated
  using (
    (select auth.uid()) = product_variants.user_id 
  )
  with check (
    (select auth.uid()) = product_variants.user_id
  );

create unique index product_variants_active_natural_key_idx 
ON app_data.product_variants (user_id, barcode) 
WHERE is_deleted = false;

grant select, insert, update, delete on table app_data.product_variants to authenticated;
grant all on table app_data.product_variants to service_role;
revoke all on table app_data.product_variants from anon;