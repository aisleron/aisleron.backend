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

create or replace function public.push_loyalty_cards(p_records jsonb) 
returns jsonb 
language plpgsql 
security invoker 
as $$
begin 
    insert into public.loyalty_cards ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        name,
        provider,
        intent
    ) select
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        v_record->>'name' as name,
        v_record->>'provider' as provider,
        v_record->>'intent' as intent
    from jsonb_array_elements(p_records) as record(payload)
    left join public.loyalty_cards as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.provider = record.payload->>'provider'
        and existing.intent = record.payload->>'intent'
    
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        name = excluded.name,
        provider = excluded.provider,
        intent = excluded.intent
    where public.loyalty_cards.user_id = auth.uid() 
      and public.loyalty_cards.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$$;