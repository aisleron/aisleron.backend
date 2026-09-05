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

create or replace function public.push_aisle_products(p_records jsonb) 
returns jsonb 
language plpgsql 
security invoker 
as $$
begin 
    insert into public.aisle_products ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        aisle_id,
        product_id,
        location_id,
        rank
    ) select
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        (record.payload->>'aisle_id')::uuid as aisle_id,
        (record.payload->>'product_id')::uuid as product_id,
        (record.payload->>'location_id')::uuid as location_id,
        coalesce((record.payload->>'rank')::integer, 0) as rank
    from jsonb_array_elements(p_records) as record(payload)
    left join public.notes as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.location_id = (record.payload->>'location_id')::uuid
        and existing.product_id = (record.payload->>'product_id')::uuid
        
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        aisle_id = excluded.aisle_id,
        product_id = excluded.product_id,
        location_id = excluded.location_id,
        rank = excluded.rank
    where public.aisle_products.user_id = auth.uid() 
        and public.aisle_products.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$$;