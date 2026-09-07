set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.push_location_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
begin 
    insert into public.location_loyalty_cards ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        location_id,
        loyalty_card_id
    ) select
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        (record.payload->>'location_id')::uuid as location_id,
        (record.payload->>'loyalty_card_id')::uuid as loyalty_card_id
    from jsonb_array_elements(p_records) as record(payload)
    left join public.location_loyalty_cards as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.location_id = (record.payload->>'location_id')::uuid
        and existing.loyalty_card_id = (record.payload->>'loyalty_card_id')::uuid    
    
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        location_id = excluded.location_id,
        loyalty_card_id = excluded.loyalty_card_id
    where public.location_loyalty_cards.user_id = auth.uid() 
      and public.location_loyalty_cards.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
        record.payload->>'name' as name,
        record.payload->>'provider' as provider,
        record.payload->>'intent' as intent
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
$function$
;


