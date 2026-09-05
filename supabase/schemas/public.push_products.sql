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

create or replace function public.push_products(p_records jsonb)
returns jsonb
language plpgsql
security invoker
as $$
begin
    insert into public.products (
        id,
        user_id,
        client_updated_at,
        is_deleted,
        name,
        in_stock,
        qty_needed,
        note_id,
        qty_increment,
        unit_of_measure,
        tracking_mode
    ) select
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        coalesce(record.payload->>'name', '') as name,
        coalesce((record.payload->>'in_stock')::boolean, false) as in_stock,
        coalesce((record.payload->>'qty_needed')::double precision, 0.0) as qty_needed,
        coalesce((record.payload->>'note_id')::uuid, null) as note_id,
        coalesce((record.payload->>'qty_increment')::double precision, 1.0) as qty_increment,
        coalesce(record.payload->>'unit_of_measure', '') as unit_of_measure,
        record.payload->>'tracking_mode' as tracking_mode
    from jsonb_array_elements(p_records) as record(payload)
    left join public.products as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.name = record.payload->>'name'
    
    on conflict (id) do update set
        client_updated_at = excluded.client_updated_at,
        server_updated_at = now(),
        is_deleted = excluded.is_deleted,
        name = excluded.name,
        in_stock = excluded.in_stock,
        qty_needed = excluded.qty_needed,
        note_id = excluded.note_id,
        qty_increment = excluded.qty_increment,
        unit_of_measure = excluded.unit_of_measure,
        tracking_mode = excluded.tracking_mode
    where public.products.user_id = auth.uid()
      and public.products.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end;
$$;