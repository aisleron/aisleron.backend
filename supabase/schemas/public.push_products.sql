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
declare
    v_record jsonb;
begin
    for v_record in select * from jsonb_array_elements(p_records) loop
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
        ) values (
            (v_record->>'id')::uuid,
            auth.uid(),
            coalesce((v_record->>'client_updated_at')::timestamptz, now()),
            coalesce((v_record->>'is_deleted')::boolean, false),
            coalesce(v_record->>'name', ''),
            coalesce((v_record->>'in_stock')::boolean, false),
            coalesce((v_record->>'qty_needed')::double precision, 0.0),
            coalesce((v_record->>'note_id')::uuid, null),
            coalesce((v_record->>'qty_increment')::double precision, 1.0),
            coalesce(v_record->>'unit_of_measure', ''),
            v_record->>'tracking_mode'
        )
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
    end loop;

    return jsonb_build_object('success', true);
end;
$$;