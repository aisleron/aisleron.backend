alter table "public"."aisle_products" add column "location_id" uuid not null;

alter table "public"."notes" add column "created_at" timestamp with time zone not null default now();

CREATE UNIQUE INDEX aisle_products_active_natural_key_idx ON public.aisle_products USING btree (user_id, location_id, product_id) WHERE (is_deleted = false);

CREATE UNIQUE INDEX aisles_active_natural_key_idx ON public.aisles USING btree (user_id, name, location_id) WHERE (is_deleted = false);

CREATE UNIQUE INDEX location_loyalty_cards_active_natural_key_idx ON public.location_loyalty_cards USING btree (user_id, location_id, loyalty_card_id) WHERE (is_deleted = false);

CREATE UNIQUE INDEX locations_active_natural_key_idx ON public.locations USING btree (user_id, name, type) WHERE (is_deleted = false);

CREATE UNIQUE INDEX loyalty_cards_active_natural_key_idx ON public.loyalty_cards USING btree (user_id, provider, intent) WHERE (is_deleted = false);

CREATE UNIQUE INDEX notes_active_natural_key_idx ON public.notes USING btree (user_id, note_text, created_at) WHERE (is_deleted = false);

CREATE UNIQUE INDEX product_variants_active_natural_key_idx ON public.product_variants USING btree (user_id, barcode) WHERE (is_deleted = false);

CREATE UNIQUE INDEX products_active_natural_key_idx ON public.products USING btree (user_id, name) WHERE (is_deleted = false);

alter table "public"."aisle_products" add constraint "aisle_products_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."aisle_products" validate constraint "aisle_products_location_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.push_aisle_products(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.push_aisles(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$

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
$function$
;

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
        (v_record->>'location_id')::uuid as location_id,
        (v_record->>'loyalty_card_id')::uuid as loyalty_card_id
    from jsonb_array_elements(p_records) as record(payload)
    left join public.location_loyalty_cards as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.location_id = (v_record->>'location_id')::uuid
        and existing.loyalty_card_id = (v_record->>'loyalty_card_id')::uuid    
    
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

CREATE OR REPLACE FUNCTION public.push_locations(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
begin 
    insert into public.locations ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        type,
        default_filter,
        name,
        pinned,
        note_id,
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
        record.payload->>'type' as type,
        record.payload->>'default_filter' as default_filter,
        record.payload->>'name' as name,
        coalesce((record.payload->>'pinned')::boolean, false) as pinned,
        (record.payload->>'note_id')::uuid as note_id,
        coalesce((record.payload->>'rank')::integer, 0) as rank
    from jsonb_array_elements(p_records) as record(payload)
    left join public.locations as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.name = record.payload->>'name'
        and existing.type = record.payload->>'type'
    
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        type = excluded.type,
        default_filter = excluded.default_filter,
        name = excluded.name,
        pinned = excluded.pinned,
        note_id = excluded.note_id,
        rank = excluded.rank
    where public.locations.user_id = auth.uid() 
      and public.locations.client_updated_at < excluded.client_updated_at;

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
$function$
;

CREATE OR REPLACE FUNCTION public.push_notes(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
begin
    insert into public.notes (
        id,
        user_id,
        client_updated_at,
        is_deleted,
        note_text,
        created_at
    ) select
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        coalesce(record.payload->>'note_text', '') as note_text,
        (record.payload->>'created_at')::timestamptz as created_at
    from jsonb_array_elements(p_records) as record(payload)
    left join public.notes as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.note_text = record.payload->>'note_text'
        and existing.created_at = (record.payload->>'created_at')::timestamptz
        
    on conflict (id) do update set
        client_updated_at = excluded.client_updated_at,
        server_updated_at = now(),
        is_deleted = excluded.is_deleted,
        note_text = excluded.note_text
    where public.notes.user_id = auth.uid()
      and public.notes.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.push_product_variants(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
begin 
    insert into public.product_variants ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        product_id,
        barcode,
        created_at
    ) select
        coalesce(
            nullif(record.payload->>'id', '')::uuid, 
            existing.id, 
            gen_random_uuid()
        ) as id,
        auth.uid() as user_id,
        coalesce((record.payload->>'client_updated_at')::timestamptz, now()) as client_updated_at,
        coalesce((record.payload->>'is_deleted')::boolean, false) as is_deleted,
        (record.payload->>'product_id')::uuid as product_id,
        record.payload->>'barcode' as barcode,
        coalesce((record.payload->>'created_at')::timestamptz, now()) as created_at
    from jsonb_array_elements(p_records) as record(payload)
    left join public.product_variants as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.barcode = record.payload->>'barcode'
        
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        product_id = excluded.product_id,
        barcode = excluded.barcode,
        created_at = excluded.created_at
    where public.product_variants.user_id = auth.uid() 
      and public.product_variants.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_products(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;


