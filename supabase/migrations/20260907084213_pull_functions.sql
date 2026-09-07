alter table "public"."product_variants" add column "created_at" timestamp with time zone not null default now();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.pull_aisle_products(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, location_id uuid, product_id uuid, aisle_id uuid, rank integer)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        a.location_id,
        pt.product_id,
        pt.aisle_id,
        pt.rank
    from public.aisle_products pt
    join public.aisles a on a.id = pt.aisle_id
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_aisles(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, name text, location_id uuid, rank integer, is_default boolean)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.name,
        pt.location_id,
        pt.rank,
        pt.is_default
    from public.aisles pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_location_loyalty_cards(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, location_id uuid, loyalty_card_id uuid)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.location_id,
        pt.loyalty_card_id
    from public.location_loyalty_cards pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_locations(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, type text, default_filter text, name text, pinned boolean, note_id uuid, rank integer)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.type,
        pt.default_filter,
        pt.name,
        pt.pinned,
        pt.note_id,
        pt.rank
    from public.locations pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_loyalty_cards(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, name text, provider text, intent text)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.name,
        pt.provider,
        pt.intent
    from public.loyalty_cards pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_notes(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, note_text text, created_at timestamp with time zone)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.note_text,
        pt.created_at 
    from public.notes pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_product_variants(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, product_id uuid, barcode text, created_at timestamp with time zone)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.product_id,
        pt.barcode,
        pt.created_at 
    from public.product_variants pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.pull_products(p_since_timestamp timestamp with time zone)
 RETURNS TABLE(id uuid, client_updated_at timestamp with time zone, server_updated_at timestamp with time zone, is_deleted boolean, name text, in_stock boolean, qty_needed double precision, note_id uuid, qty_increment double precision, unit_of_measure text, tracking_mode text)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
    select 
        pt.id,
        pt.client_updated_at,
        pt.server_updated_at,
        pt.is_deleted,
        pt.name,
        pt.in_stock,
        pt.qty_needed,
        pt.note_id,
        pt.qty_increment,
        pt.unit_of_measure,
        pt.tracking_mode
    from public.products pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.push_location_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
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


