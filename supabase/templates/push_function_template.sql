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

-- TEMPLATE: New Aisleron Sync Push Function
-- Replace {{table_name}} with your entity name, e.g. products

create or replace function public.push_{{table_name}}(p_records jsonb)
returns jsonb
language plpgsql
security invoker
as $$
begin
    
    insert into public.{{table_name}} (
        id,
        user_id,
        client_updated_at,
        is_deleted,
        -- Add remaining entity columns here, e,g,:
        -- name,  

    ) select 
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        -- Add remaining entity columns here, e,g,:
        -- coalesce(record.payload->>'name', ''),

    from jsonb_array_elements(p_records) as record(payload)
    left join public.{{table_name}} as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        -- Add conditions for natural key lookup, e.g.:
        -- and existing.name = record.payload->>'name'
    
    on conflict (id) do update set
        client_updated_at = excluded.client_updated_at,
        server_updated_at = now(),
        is_deleted = excluded.is_deleted,
        -- Add remaining entity columns here, e,g,:
        -- name = excluded.name,
        
    where public.{{table_name}}.user_id = auth.uid()
      and public.{{table_name}}.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end;
$$;