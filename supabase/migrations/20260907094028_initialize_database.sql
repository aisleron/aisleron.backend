create extension if not exists "moddatetime" with schema "extensions";


  create table "app_data"."aisle_products" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "aisle_id" uuid not null,
    "product_id" uuid not null,
    "rank" integer not null
      );


alter table "app_data"."aisle_products" enable row level security;


  create table "app_data"."aisles" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "name" text not null,
    "location_id" uuid not null,
    "rank" integer not null,
    "is_default" boolean not null default false
      );


alter table "app_data"."aisles" enable row level security;


  create table "app_data"."location_loyalty_cards" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "location_id" uuid not null,
    "loyalty_card_id" uuid not null
      );


alter table "app_data"."location_loyalty_cards" enable row level security;


  create table "app_data"."locations" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "type" text not null,
    "default_filter" text not null,
    "name" text not null,
    "pinned" boolean not null,
    "note_id" uuid,
    "rank" integer not null
      );


alter table "app_data"."locations" enable row level security;


  create table "app_data"."loyalty_cards" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "name" text not null,
    "provider" text not null,
    "intent" text not null
      );


alter table "app_data"."loyalty_cards" enable row level security;


  create table "app_data"."notes" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "note_text" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "app_data"."notes" enable row level security;


  create table "app_data"."product_variants" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "product_id" uuid not null,
    "barcode" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "app_data"."product_variants" enable row level security;


  create table "app_data"."products" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "name" text not null,
    "in_stock" boolean not null,
    "qty_needed" double precision not null default 0,
    "note_id" uuid,
    "qty_increment" double precision not null default 1,
    "unit_of_measure" text not null default ''::text,
    "tracking_mode" text
      );


alter table "app_data"."products" enable row level security;


  create table "customer"."subscriptions" (
    "user_id" uuid not null,
    "current_period_end" timestamp with time zone not null,
    "status" text not null default 'inactive'::text,
    "provider" text,
    "provider_customer_id" text,
    "provider_subscription_id" text
      );


CREATE UNIQUE INDEX aisle_products_active_natural_key_idx ON app_data.aisle_products USING btree (user_id, aisle_id, product_id) WHERE (is_deleted = false);

CREATE UNIQUE INDEX aisle_products_pkey ON app_data.aisle_products USING btree (id);

CREATE UNIQUE INDEX aisles_active_natural_key_idx ON app_data.aisles USING btree (user_id, name, location_id) WHERE (is_deleted = false);

CREATE UNIQUE INDEX aisles_pkey ON app_data.aisles USING btree (id);

CREATE UNIQUE INDEX location_loyalty_cards_active_natural_key_idx ON app_data.location_loyalty_cards USING btree (user_id, location_id, loyalty_card_id) WHERE (is_deleted = false);

CREATE UNIQUE INDEX location_loyalty_cards_location_id_key ON app_data.location_loyalty_cards USING btree (location_id);

CREATE UNIQUE INDEX location_loyalty_cards_pkey ON app_data.location_loyalty_cards USING btree (id);

CREATE UNIQUE INDEX locations_active_natural_key_idx ON app_data.locations USING btree (user_id, name, type) WHERE (is_deleted = false);

CREATE UNIQUE INDEX locations_pkey ON app_data.locations USING btree (id);

CREATE UNIQUE INDEX loyalty_cards_active_natural_key_idx ON app_data.loyalty_cards USING btree (user_id, provider, intent) WHERE (is_deleted = false);

CREATE UNIQUE INDEX loyalty_cards_pkey ON app_data.loyalty_cards USING btree (id);

CREATE UNIQUE INDEX notes_active_natural_key_idx ON app_data.notes USING btree (user_id, note_text, created_at) WHERE (is_deleted = false);

CREATE UNIQUE INDEX notes_pkey ON app_data.notes USING btree (id);

CREATE UNIQUE INDEX product_variants_active_natural_key_idx ON app_data.product_variants USING btree (user_id, barcode) WHERE (is_deleted = false);

CREATE UNIQUE INDEX product_variants_pkey ON app_data.product_variants USING btree (id);

CREATE UNIQUE INDEX products_active_natural_key_idx ON app_data.products USING btree (user_id, name) WHERE (is_deleted = false);

CREATE UNIQUE INDEX products_pkey ON app_data.products USING btree (id);

CREATE UNIQUE INDEX subscriptions_pkey ON customer.subscriptions USING btree (user_id);

alter table "app_data"."aisle_products" add constraint "aisle_products_pkey" PRIMARY KEY using index "aisle_products_pkey";

alter table "app_data"."aisles" add constraint "aisles_pkey" PRIMARY KEY using index "aisles_pkey";

alter table "app_data"."location_loyalty_cards" add constraint "location_loyalty_cards_pkey" PRIMARY KEY using index "location_loyalty_cards_pkey";

alter table "app_data"."locations" add constraint "locations_pkey" PRIMARY KEY using index "locations_pkey";

alter table "app_data"."loyalty_cards" add constraint "loyalty_cards_pkey" PRIMARY KEY using index "loyalty_cards_pkey";

alter table "app_data"."notes" add constraint "notes_pkey" PRIMARY KEY using index "notes_pkey";

alter table "app_data"."product_variants" add constraint "product_variants_pkey" PRIMARY KEY using index "product_variants_pkey";

alter table "app_data"."products" add constraint "products_pkey" PRIMARY KEY using index "products_pkey";

alter table "customer"."subscriptions" add constraint "subscriptions_pkey" PRIMARY KEY using index "subscriptions_pkey";

alter table "app_data"."aisle_products" add constraint "aisle_products_aisle_id_fkey" FOREIGN KEY (aisle_id) REFERENCES app_data.aisles(id) not valid;

alter table "app_data"."aisle_products" validate constraint "aisle_products_aisle_id_fkey";

alter table "app_data"."aisle_products" add constraint "aisle_products_product_id_fkey" FOREIGN KEY (product_id) REFERENCES app_data.products(id) not valid;

alter table "app_data"."aisle_products" validate constraint "aisle_products_product_id_fkey";

alter table "app_data"."aisle_products" add constraint "aisle_products_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."aisle_products" validate constraint "aisle_products_user_id_fkey";

alter table "app_data"."aisles" add constraint "aisles_location_id_fkey" FOREIGN KEY (location_id) REFERENCES app_data.locations(id) not valid;

alter table "app_data"."aisles" validate constraint "aisles_location_id_fkey";

alter table "app_data"."aisles" add constraint "aisles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."aisles" validate constraint "aisles_user_id_fkey";

alter table "app_data"."location_loyalty_cards" add constraint "location_loyalty_cards_location_id_fkey" FOREIGN KEY (location_id) REFERENCES app_data.locations(id) ON DELETE CASCADE not valid;

alter table "app_data"."location_loyalty_cards" validate constraint "location_loyalty_cards_location_id_fkey";

alter table "app_data"."location_loyalty_cards" add constraint "location_loyalty_cards_location_id_key" UNIQUE using index "location_loyalty_cards_location_id_key";

alter table "app_data"."location_loyalty_cards" add constraint "location_loyalty_cards_loyalty_card_id_fkey" FOREIGN KEY (loyalty_card_id) REFERENCES app_data.loyalty_cards(id) ON DELETE CASCADE not valid;

alter table "app_data"."location_loyalty_cards" validate constraint "location_loyalty_cards_loyalty_card_id_fkey";

alter table "app_data"."location_loyalty_cards" add constraint "location_loyalty_cards_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."location_loyalty_cards" validate constraint "location_loyalty_cards_user_id_fkey";

alter table "app_data"."locations" add constraint "locations_note_id_fkey" FOREIGN KEY (note_id) REFERENCES app_data.notes(id) ON DELETE SET NULL not valid;

alter table "app_data"."locations" validate constraint "locations_note_id_fkey";

alter table "app_data"."locations" add constraint "locations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."locations" validate constraint "locations_user_id_fkey";

alter table "app_data"."loyalty_cards" add constraint "loyalty_cards_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."loyalty_cards" validate constraint "loyalty_cards_user_id_fkey";

alter table "app_data"."notes" add constraint "notes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."notes" validate constraint "notes_user_id_fkey";

alter table "app_data"."product_variants" add constraint "product_variants_product_id_fkey" FOREIGN KEY (product_id) REFERENCES app_data.products(id) ON DELETE CASCADE not valid;

alter table "app_data"."product_variants" validate constraint "product_variants_product_id_fkey";

alter table "app_data"."product_variants" add constraint "product_variants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."product_variants" validate constraint "product_variants_user_id_fkey";

alter table "app_data"."products" add constraint "products_note_id_fkey" FOREIGN KEY (note_id) REFERENCES app_data.notes(id) ON DELETE SET NULL not valid;

alter table "app_data"."products" validate constraint "products_note_id_fkey";

alter table "app_data"."products" add constraint "products_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "app_data"."products" validate constraint "products_user_id_fkey";

alter table "customer"."subscriptions" add constraint "subscriptions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "customer"."subscriptions" validate constraint "subscriptions_user_id_fkey";

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
    from app_data.aisle_products pt
    join app_data.aisles a on a.id = pt.aisle_id
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
    from app_data.aisles pt
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
    from app_data.location_loyalty_cards pt
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
    from app_data.locations pt
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
    from app_data.loyalty_cards pt
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
    from app_data.notes pt
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
    from app_data.product_variants pt
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
    from app_data.products pt
    where pt.user_id = auth.uid()
      and pt.server_updated_at > p_since_timestamp;
$function$
;

CREATE OR REPLACE FUNCTION public.push_aisle_products(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin 
    insert into app_data.aisle_products ( 
        id, 
        user_id, 
        client_updated_at, 
        is_deleted, 
        aisle_id,
        product_id,
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
        coalesce((record.payload->>'rank')::integer, 0) as rank
    from jsonb_array_elements(p_records) as record(payload)
    left join lateral (
        select ap.id 
        from app_data.aisle_products ap
        where ap.user_id = auth.uid()
          and ap.is_deleted = false
          and ap.product_id = (record.payload->>'product_id')::uuid
          and exists (
              select null from app_data.aisles a 
              where a.id = ap.aisle_id 
                and a.location_id = (record.payload->>'location_id')::uuid 
          )
        order by ap.client_updated_at desc
        limit 1
    ) existing on true
        
    on conflict (id) do update set 
        client_updated_at = excluded.client_updated_at, 
        server_updated_at = now(), 
        is_deleted = excluded.is_deleted, 
        aisle_id = excluded.aisle_id,
        product_id = excluded.product_id,
        rank = excluded.rank
    where app_data.aisle_products.user_id = auth.uid() 
      and app_data.aisle_products.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_aisles(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin 
    insert into app_data.aisles ( 
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
    left join app_data.aisles as existing 
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
    where app_data.aisles.user_id = auth.uid() 
      and app_data.aisles.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_location_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin 
    insert into app_data.location_loyalty_cards ( 
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
    left join app_data.location_loyalty_cards as existing 
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
    where app_data.location_loyalty_cards.user_id = auth.uid() 
      and app_data.location_loyalty_cards.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_locations(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin 
    insert into app_data.locations ( 
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
    left join app_data.locations as existing 
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
    where app_data.locations.user_id = auth.uid() 
      and app_data.locations.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_loyalty_cards(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin 
    insert into app_data.loyalty_cards ( 
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
    left join app_data.loyalty_cards as existing 
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
    where app_data.loyalty_cards.user_id = auth.uid() 
      and app_data.loyalty_cards.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_notes(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
    insert into app_data.notes (
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
    left join app_data.notes as existing 
        on existing.user_id = auth.uid()
        and existing.is_deleted = false
        and existing.note_text = record.payload->>'note_text'
        and existing.created_at = (record.payload->>'created_at')::timestamptz
        
    on conflict (id) do update set
        client_updated_at = excluded.client_updated_at,
        server_updated_at = now(),
        is_deleted = excluded.is_deleted,
        note_text = excluded.note_text
    where app_data.notes.user_id = auth.uid()
      and app_data.notes.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.push_product_variants(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin 
    insert into app_data.product_variants ( 
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
    left join app_data.product_variants as existing 
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
    where app_data.product_variants.user_id = auth.uid() 
      and app_data.product_variants.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end; 
$function$
;

CREATE OR REPLACE FUNCTION public.push_products(p_records jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
    insert into app_data.products (
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
    left join app_data.products as existing 
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
    where app_data.products.user_id = auth.uid()
      and app_data.products.client_updated_at < excluded.client_updated_at;

    return jsonb_build_object('success', true);
end;
$function$
;

grant delete on table "app_data"."aisle_products" to "authenticated";

grant insert on table "app_data"."aisle_products" to "authenticated";

grant select on table "app_data"."aisle_products" to "authenticated";

grant update on table "app_data"."aisle_products" to "authenticated";

grant delete on table "app_data"."aisle_products" to "service_role";

grant insert on table "app_data"."aisle_products" to "service_role";

grant references on table "app_data"."aisle_products" to "service_role";

grant select on table "app_data"."aisle_products" to "service_role";

grant trigger on table "app_data"."aisle_products" to "service_role";

grant truncate on table "app_data"."aisle_products" to "service_role";

grant update on table "app_data"."aisle_products" to "service_role";

grant delete on table "app_data"."aisles" to "authenticated";

grant insert on table "app_data"."aisles" to "authenticated";

grant select on table "app_data"."aisles" to "authenticated";

grant update on table "app_data"."aisles" to "authenticated";

grant delete on table "app_data"."aisles" to "service_role";

grant insert on table "app_data"."aisles" to "service_role";

grant references on table "app_data"."aisles" to "service_role";

grant select on table "app_data"."aisles" to "service_role";

grant trigger on table "app_data"."aisles" to "service_role";

grant truncate on table "app_data"."aisles" to "service_role";

grant update on table "app_data"."aisles" to "service_role";

grant delete on table "app_data"."location_loyalty_cards" to "authenticated";

grant insert on table "app_data"."location_loyalty_cards" to "authenticated";

grant select on table "app_data"."location_loyalty_cards" to "authenticated";

grant update on table "app_data"."location_loyalty_cards" to "authenticated";

grant delete on table "app_data"."location_loyalty_cards" to "service_role";

grant insert on table "app_data"."location_loyalty_cards" to "service_role";

grant references on table "app_data"."location_loyalty_cards" to "service_role";

grant select on table "app_data"."location_loyalty_cards" to "service_role";

grant trigger on table "app_data"."location_loyalty_cards" to "service_role";

grant truncate on table "app_data"."location_loyalty_cards" to "service_role";

grant update on table "app_data"."location_loyalty_cards" to "service_role";

grant delete on table "app_data"."locations" to "authenticated";

grant insert on table "app_data"."locations" to "authenticated";

grant select on table "app_data"."locations" to "authenticated";

grant update on table "app_data"."locations" to "authenticated";

grant delete on table "app_data"."locations" to "service_role";

grant insert on table "app_data"."locations" to "service_role";

grant references on table "app_data"."locations" to "service_role";

grant select on table "app_data"."locations" to "service_role";

grant trigger on table "app_data"."locations" to "service_role";

grant truncate on table "app_data"."locations" to "service_role";

grant update on table "app_data"."locations" to "service_role";

grant delete on table "app_data"."loyalty_cards" to "authenticated";

grant insert on table "app_data"."loyalty_cards" to "authenticated";

grant select on table "app_data"."loyalty_cards" to "authenticated";

grant update on table "app_data"."loyalty_cards" to "authenticated";

grant delete on table "app_data"."loyalty_cards" to "service_role";

grant insert on table "app_data"."loyalty_cards" to "service_role";

grant references on table "app_data"."loyalty_cards" to "service_role";

grant select on table "app_data"."loyalty_cards" to "service_role";

grant trigger on table "app_data"."loyalty_cards" to "service_role";

grant truncate on table "app_data"."loyalty_cards" to "service_role";

grant update on table "app_data"."loyalty_cards" to "service_role";

grant delete on table "app_data"."notes" to "authenticated";

grant insert on table "app_data"."notes" to "authenticated";

grant select on table "app_data"."notes" to "authenticated";

grant update on table "app_data"."notes" to "authenticated";

grant delete on table "app_data"."notes" to "service_role";

grant insert on table "app_data"."notes" to "service_role";

grant references on table "app_data"."notes" to "service_role";

grant select on table "app_data"."notes" to "service_role";

grant trigger on table "app_data"."notes" to "service_role";

grant truncate on table "app_data"."notes" to "service_role";

grant update on table "app_data"."notes" to "service_role";

grant delete on table "app_data"."product_variants" to "authenticated";

grant insert on table "app_data"."product_variants" to "authenticated";

grant select on table "app_data"."product_variants" to "authenticated";

grant update on table "app_data"."product_variants" to "authenticated";

grant delete on table "app_data"."product_variants" to "service_role";

grant insert on table "app_data"."product_variants" to "service_role";

grant references on table "app_data"."product_variants" to "service_role";

grant select on table "app_data"."product_variants" to "service_role";

grant trigger on table "app_data"."product_variants" to "service_role";

grant truncate on table "app_data"."product_variants" to "service_role";

grant update on table "app_data"."product_variants" to "service_role";

grant delete on table "app_data"."products" to "authenticated";

grant insert on table "app_data"."products" to "authenticated";

grant select on table "app_data"."products" to "authenticated";

grant update on table "app_data"."products" to "authenticated";

grant delete on table "app_data"."products" to "service_role";

grant insert on table "app_data"."products" to "service_role";

grant references on table "app_data"."products" to "service_role";

grant select on table "app_data"."products" to "service_role";

grant trigger on table "app_data"."products" to "service_role";

grant truncate on table "app_data"."products" to "service_role";

grant update on table "app_data"."products" to "service_role";


  create policy "Users can manage their own aisle_products"
  on "app_data"."aisle_products"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own aisles"
  on "app_data"."aisles"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own location_loyalty_cards"
  on "app_data"."location_loyalty_cards"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own locations"
  on "app_data"."locations"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own loyalty_cards"
  on "app_data"."loyalty_cards"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own notes"
  on "app_data"."notes"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own product_variants"
  on "app_data"."product_variants"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own products"
  on "app_data"."products"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));


CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.aisle_products FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.aisles FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.location_loyalty_cards FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.locations FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.loyalty_cards FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.notes FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.product_variants FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON app_data.products FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');


