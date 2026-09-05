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

begin 
    insert into public.aisles ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        name,
        location_id,
        rank,
        is_default
    ) select 
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        record.payload->>'name' as name,
        (record.payload->>'location_id')::uuid as location_id,
        coalesce((record.payload->>'rank')::integer, 0) as rank,
        coalesce((record.payload->>'is_default')::boolean, false) as is_default
    from jsonb_array_elements(p_records) as record(payload)
    left join public.aisles as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.name = record.payload->>'name'
        and existing.location_id = (record.payload->>'location_id')::uuid
        
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        name = excluded.name,
        location_id = excluded.location_id,
        rank = excluded.rank,
        is_default = excluded.is_default
    where public.aisles.user_id = auth.uid() 
      and public.aisles.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$$;