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

create or replace function public.push_aisles(p_records jsonb) 
returns jsonb 
language plpgsql 
security invoker 
as $$
declare 
    v_record jsonb; 
begin 
    for v_record in select * from jsonb_array_elements(p_records) loop 
        insert into public.aisles ( 
            id, 
            user_id, 
            client_updated_at, 
            is_deleted, 
            name,
            location_id,
            rank,
            is_default
        ) values ( 
            (v_record->>'id')::uuid, 
            auth.uid(), 
            coalesce((v_record->>'client_updated_at')::timestamptz, now()), 
            coalesce((v_record->>'is_deleted')::boolean, false), 
            v_record->>'name',
            (v_record->>'location_id')::uuid,
            coalesce((v_record->>'rank')::integer, 0),
            coalesce((v_record->>'is_default')::boolean, false)
        ) on conflict (id) do update set 
            client_updated_at = excluded.client_updated_at, 
            server_updated_at = now(), 
            is_deleted = excluded.is_deleted, 
            name = excluded.name,
            location_id = excluded.location_id,
            rank = excluded.rank,
            is_default = excluded.is_default
        where public.aisles.user_id = auth.uid() 
          and public.aisles.client_updated_at < excluded.client_updated_at;
    end loop; 

    return jsonb_build_object('success', true);
end; 
$$;