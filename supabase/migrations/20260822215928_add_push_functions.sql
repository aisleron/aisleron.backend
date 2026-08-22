revoke references on table "public"."aisle_products" from "anon";

revoke trigger on table "public"."aisle_products" from "anon";

revoke truncate on table "public"."aisle_products" from "anon";

revoke references on table "public"."aisle_products" from "authenticated";

revoke trigger on table "public"."aisle_products" from "authenticated";

revoke truncate on table "public"."aisle_products" from "authenticated";

revoke references on table "public"."aisles" from "anon";

revoke trigger on table "public"."aisles" from "anon";

revoke truncate on table "public"."aisles" from "anon";

revoke references on table "public"."aisles" from "authenticated";

revoke trigger on table "public"."aisles" from "authenticated";

revoke truncate on table "public"."aisles" from "authenticated";

revoke references on table "public"."location_loyalty_cards" from "anon";

revoke trigger on table "public"."location_loyalty_cards" from "anon";

revoke truncate on table "public"."location_loyalty_cards" from "anon";

revoke references on table "public"."location_loyalty_cards" from "authenticated";

revoke trigger on table "public"."location_loyalty_cards" from "authenticated";

revoke truncate on table "public"."location_loyalty_cards" from "authenticated";

revoke references on table "public"."locations" from "anon";

revoke trigger on table "public"."locations" from "anon";

revoke truncate on table "public"."locations" from "anon";

revoke references on table "public"."locations" from "authenticated";

revoke trigger on table "public"."locations" from "authenticated";

revoke truncate on table "public"."locations" from "authenticated";

revoke references on table "public"."loyalty_cards" from "anon";

revoke trigger on table "public"."loyalty_cards" from "anon";

revoke truncate on table "public"."loyalty_cards" from "anon";

revoke references on table "public"."loyalty_cards" from "authenticated";

revoke trigger on table "public"."loyalty_cards" from "authenticated";

revoke truncate on table "public"."loyalty_cards" from "authenticated";

revoke references on table "public"."notes" from "anon";

revoke trigger on table "public"."notes" from "anon";

revoke truncate on table "public"."notes" from "anon";

revoke references on table "public"."notes" from "authenticated";

revoke trigger on table "public"."notes" from "authenticated";

revoke truncate on table "public"."notes" from "authenticated";

revoke references on table "public"."product_variants" from "anon";

revoke trigger on table "public"."product_variants" from "anon";

revoke truncate on table "public"."product_variants" from "anon";

revoke references on table "public"."product_variants" from "authenticated";

revoke trigger on table "public"."product_variants" from "authenticated";

revoke truncate on table "public"."product_variants" from "authenticated";

revoke references on table "public"."products" from "anon";

revoke trigger on table "public"."products" from "anon";

revoke truncate on table "public"."products" from "anon";

revoke references on table "public"."products" from "authenticated";

revoke trigger on table "public"."products" from "authenticated";

revoke truncate on table "public"."products" from "authenticated";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.push_aisle_products(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare 
    v_record jsonb; 
begin 
    for v_record in select * from jsonb_array_elements(p_records) loop 
        insert into public.aisle_products ( 
            id, 
            user_id, 
            client_updated_at, 
            is_deleted, 
            aisle_id,
            product_id,
            rank
        ) values ( 
            (v_record->>'id')::uuid, 
            auth.uid(), 
            coalesce((v_record->>'client_updated_at')::timestamptz, now()), 
            coalesce((v_record->>'is_deleted')::boolean, false), 
            (v_record->>'aisle_id')::uuid,
            (v_record->>'product_id')::uuid,
            coalesce((v_record->>'rank')::integer, 0)
        ) on conflict (id) do update set 
            client_updated_at = excluded.client_updated_at, 
            server_updated_at = now(), 
            is_deleted = excluded.is_deleted, 
            aisle_id = excluded.aisle_id,
            product_id = excluded.product_id,
            rank = excluded.rank
        where public.aisle_products.user_id = auth.uid() 
          and public.aisle_products.client_updated_at < excluded.client_updated_at;
    end loop; 

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_aisles(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.push_location_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare 
    v_record jsonb; 
begin 
    for v_record in select * from jsonb_array_elements(p_records) loop 
        insert into public.location_loyalty_cards ( 
            id, 
            user_id, 
            client_updated_at, 
            is_deleted, 
            location_id,
            loyalty_card_id
        ) values ( 
            (v_record->>'id')::uuid, 
            auth.uid(), 
            coalesce((v_record->>'client_updated_at')::timestamptz, now()), 
            coalesce((v_record->>'is_deleted')::boolean, false), 
            (v_record->>'location_id')::uuid,
            (v_record->>'loyalty_card_id')::uuid
        ) on conflict (id) do update set 
            client_updated_at = excluded.client_updated_at, 
            server_updated_at = now(), 
            is_deleted = excluded.is_deleted, 
            location_id = excluded.location_id,
            loyalty_card_id = excluded.loyalty_card_id
        where public.location_loyalty_cards.user_id = auth.uid() 
          and public.location_loyalty_cards.client_updated_at < excluded.client_updated_at;
    end loop; 

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_locations(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare 
    v_record jsonb; 
begin 
    for v_record in select * from jsonb_array_elements(p_records) loop 
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
        ) values ( 
            (v_record->>'id')::uuid, 
            auth.uid(), 
            coalesce((v_record->>'client_updated_at')::timestamptz, now()), 
            coalesce((v_record->>'is_deleted')::boolean, false), 
            v_record->>'type',
            v_record->>'default_filter',
            v_record->>'name',
            coalesce((v_record->>'pinned')::boolean, false),
            (v_record->>'note_id')::uuid,
            coalesce((v_record->>'rank')::integer, 0)
        ) on conflict (id) do update set 
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
    end loop; 

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare 
    v_record jsonb; 
begin 
    for v_record in select * from jsonb_array_elements(p_records) loop 
        insert into public.loyalty_cards ( 
            id, 
            user_id, 
            client_updated_at, 
            is_deleted, 
            name,
            provider,
            intent
        ) values ( 
            (v_record->>'id')::uuid, 
            auth.uid(), 
            coalesce((v_record->>'client_updated_at')::timestamptz, now()), 
            coalesce((v_record->>'is_deleted')::boolean, false), 
            v_record->>'name',
            v_record->>'provider',
            v_record->>'intent'
        ) on conflict (id) do update set 
            client_updated_at = excluded.client_updated_at, 
            server_updated_at = now(), 
            is_deleted = excluded.is_deleted, 
            name = excluded.name,
            provider = excluded.provider,
            intent = excluded.intent
        where public.loyalty_cards.user_id = auth.uid() 
          and public.loyalty_cards.client_updated_at < excluded.client_updated_at;
    end loop; 

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_notes(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
    v_record jsonb;
begin
    for v_record in select * from jsonb_array_elements(p_records) loop
        insert into public.notes (
            id,
            user_id,
            client_updated_at,
            is_deleted,
            note_text
        ) values (
            (v_record->>'id')::uuid,
            auth.uid(),
            coalesce((v_record->>'client_updated_at')::timestamptz, now()),
            coalesce((v_record->>'is_deleted')::boolean, false),
            coalesce(v_record->>'note_text', '')
        )
        on conflict (id) do update set
            client_updated_at = excluded.client_updated_at,
            server_updated_at = now(),
            is_deleted = excluded.is_deleted,
            note_text = excluded.note_text
        where public.notes.user_id = auth.uid()
          and public.notes.client_updated_at < excluded.client_updated_at;
    end loop;

    return jsonb_build_object('success', true);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.push_product_variants(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare 
    v_record jsonb; 
begin 
    for v_record in select * from jsonb_array_elements(p_records) loop 
        insert into public.product_variants ( 
            id, 
            user_id, 
            client_updated_at, 
            is_deleted, 
            product_id,
            barcode,
            created_at
        ) values ( 
            (v_record->>'id')::uuid, 
            auth.uid(), 
            coalesce((v_record->>'client_updated_at')::timestamptz, now()), 
            coalesce((v_record->>'is_deleted')::boolean, false), 
            (v_record->>'product_id')::uuid,
            v_record->>'barcode',
            coalesce((v_record->>'created_at')::timestamptz, now())
        ) on conflict (id) do update set 
            client_updated_at = excluded.client_updated_at, 
            server_updated_at = now(), 
            is_deleted = excluded.is_deleted, 
            product_id = excluded.product_id,
            barcode = excluded.barcode,
            created_at = excluded.created_at
        where public.product_variants.user_id = auth.uid() 
          and public.product_variants.client_updated_at < excluded.client_updated_at;
    end loop; 

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_products(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;


