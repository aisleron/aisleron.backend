create extension if not exists "moddatetime" with schema "extensions";


  create table "customer"."subscriptions" (
    "user_id" uuid not null,
    "current_period_end" timestamp with time zone not null,
    "status" text not null default 'inactive'::text,
    "provider" text,
    "provider_customer_id" text,
    "provider_subscription_id" text
      );



  create table "public"."aisle_products" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "aisle_id" uuid not null,
    "product_id" uuid not null,
    "rank" integer not null
      );


alter table "public"."aisle_products" enable row level security;


  create table "public"."aisles" (
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


alter table "public"."aisles" enable row level security;


  create table "public"."location_loyalty_cards" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "location_id" uuid not null,
    "loyalty_card_id" uuid not null
      );


alter table "public"."location_loyalty_cards" enable row level security;


  create table "public"."locations" (
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


alter table "public"."locations" enable row level security;


  create table "public"."loyalty_cards" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "name" text not null,
    "provider" text not null,
    "intent" text not null
      );


alter table "public"."loyalty_cards" enable row level security;


  create table "public"."notes" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "note_text" text not null
      );


alter table "public"."notes" enable row level security;


  create table "public"."product_variants" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null default auth.uid(),
    "client_updated_at" timestamp with time zone not null default now(),
    "server_updated_at" timestamp with time zone not null default now(),
    "is_deleted" boolean not null default false,
    "product_id" uuid not null,
    "barcode" text not null
      );


alter table "public"."product_variants" enable row level security;


  create table "public"."products" (
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


alter table "public"."products" enable row level security;

CREATE UNIQUE INDEX subscriptions_pkey ON customer.subscriptions USING btree (user_id);

CREATE UNIQUE INDEX aisle_products_pkey ON public.aisle_products USING btree (id);

CREATE UNIQUE INDEX aisles_pkey ON public.aisles USING btree (id);

CREATE UNIQUE INDEX location_loyalty_cards_location_id_key ON public.location_loyalty_cards USING btree (location_id);

CREATE UNIQUE INDEX location_loyalty_cards_pkey ON public.location_loyalty_cards USING btree (id);

CREATE UNIQUE INDEX locations_pkey ON public.locations USING btree (id);

CREATE UNIQUE INDEX loyalty_cards_pkey ON public.loyalty_cards USING btree (id);

CREATE UNIQUE INDEX notes_pkey ON public.notes USING btree (id);

CREATE UNIQUE INDEX product_variants_pkey ON public.product_variants USING btree (id);

CREATE UNIQUE INDEX products_pkey ON public.products USING btree (id);

alter table "customer"."subscriptions" add constraint "subscriptions_pkey" PRIMARY KEY using index "subscriptions_pkey";

alter table "public"."aisle_products" add constraint "aisle_products_pkey" PRIMARY KEY using index "aisle_products_pkey";

alter table "public"."aisles" add constraint "aisles_pkey" PRIMARY KEY using index "aisles_pkey";

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_pkey" PRIMARY KEY using index "location_loyalty_cards_pkey";

alter table "public"."locations" add constraint "locations_pkey" PRIMARY KEY using index "locations_pkey";

alter table "public"."loyalty_cards" add constraint "loyalty_cards_pkey" PRIMARY KEY using index "loyalty_cards_pkey";

alter table "public"."notes" add constraint "notes_pkey" PRIMARY KEY using index "notes_pkey";

alter table "public"."product_variants" add constraint "product_variants_pkey" PRIMARY KEY using index "product_variants_pkey";

alter table "public"."products" add constraint "products_pkey" PRIMARY KEY using index "products_pkey";

alter table "customer"."subscriptions" add constraint "subscriptions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "customer"."subscriptions" validate constraint "subscriptions_user_id_fkey";

alter table "public"."aisle_products" add constraint "aisle_products_aisle_id_fkey" FOREIGN KEY (aisle_id) REFERENCES public.aisles(id) not valid;

alter table "public"."aisle_products" validate constraint "aisle_products_aisle_id_fkey";

alter table "public"."aisle_products" add constraint "aisle_products_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) not valid;

alter table "public"."aisle_products" validate constraint "aisle_products_product_id_fkey";

alter table "public"."aisle_products" add constraint "aisle_products_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."aisle_products" validate constraint "aisle_products_user_id_fkey";

alter table "public"."aisles" add constraint "aisles_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) not valid;

alter table "public"."aisles" validate constraint "aisles_location_id_fkey";

alter table "public"."aisles" add constraint "aisles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."aisles" validate constraint "aisles_user_id_fkey";

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_location_id_fkey" FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE CASCADE not valid;

alter table "public"."location_loyalty_cards" validate constraint "location_loyalty_cards_location_id_fkey";

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_location_id_key" UNIQUE using index "location_loyalty_cards_location_id_key";

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_loyalty_card_id_fkey" FOREIGN KEY (loyalty_card_id) REFERENCES public.loyalty_cards(id) ON DELETE CASCADE not valid;

alter table "public"."location_loyalty_cards" validate constraint "location_loyalty_cards_loyalty_card_id_fkey";

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."location_loyalty_cards" validate constraint "location_loyalty_cards_user_id_fkey";

alter table "public"."locations" add constraint "locations_note_id_fkey" FOREIGN KEY (note_id) REFERENCES public.notes(id) ON DELETE SET NULL not valid;

alter table "public"."locations" validate constraint "locations_note_id_fkey";

alter table "public"."locations" add constraint "locations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."locations" validate constraint "locations_user_id_fkey";

alter table "public"."loyalty_cards" add constraint "loyalty_cards_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."loyalty_cards" validate constraint "loyalty_cards_user_id_fkey";

alter table "public"."notes" add constraint "notes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."notes" validate constraint "notes_user_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."product_variants" validate constraint "product_variants_product_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."product_variants" validate constraint "product_variants_user_id_fkey";

alter table "public"."products" add constraint "products_note_id_fkey" FOREIGN KEY (note_id) REFERENCES public.notes(id) ON DELETE SET NULL not valid;

alter table "public"."products" validate constraint "products_note_id_fkey";

alter table "public"."products" add constraint "products_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."products" validate constraint "products_user_id_fkey";

grant delete on table "public"."aisle_products" to "authenticated";

grant insert on table "public"."aisle_products" to "authenticated";

grant select on table "public"."aisle_products" to "authenticated";

grant update on table "public"."aisle_products" to "authenticated";

grant delete on table "public"."aisle_products" to "service_role";

grant insert on table "public"."aisle_products" to "service_role";

grant references on table "public"."aisle_products" to "service_role";

grant select on table "public"."aisle_products" to "service_role";

grant trigger on table "public"."aisle_products" to "service_role";

grant truncate on table "public"."aisle_products" to "service_role";

grant update on table "public"."aisle_products" to "service_role";

grant delete on table "public"."aisles" to "authenticated";

grant insert on table "public"."aisles" to "authenticated";

grant select on table "public"."aisles" to "authenticated";

grant update on table "public"."aisles" to "authenticated";

grant delete on table "public"."aisles" to "service_role";

grant insert on table "public"."aisles" to "service_role";

grant references on table "public"."aisles" to "service_role";

grant select on table "public"."aisles" to "service_role";

grant trigger on table "public"."aisles" to "service_role";

grant truncate on table "public"."aisles" to "service_role";

grant update on table "public"."aisles" to "service_role";

grant delete on table "public"."location_loyalty_cards" to "authenticated";

grant insert on table "public"."location_loyalty_cards" to "authenticated";

grant select on table "public"."location_loyalty_cards" to "authenticated";

grant update on table "public"."location_loyalty_cards" to "authenticated";

grant delete on table "public"."location_loyalty_cards" to "service_role";

grant insert on table "public"."location_loyalty_cards" to "service_role";

grant references on table "public"."location_loyalty_cards" to "service_role";

grant select on table "public"."location_loyalty_cards" to "service_role";

grant trigger on table "public"."location_loyalty_cards" to "service_role";

grant truncate on table "public"."location_loyalty_cards" to "service_role";

grant update on table "public"."location_loyalty_cards" to "service_role";

grant delete on table "public"."locations" to "authenticated";

grant insert on table "public"."locations" to "authenticated";

grant select on table "public"."locations" to "authenticated";

grant update on table "public"."locations" to "authenticated";

grant delete on table "public"."locations" to "service_role";

grant insert on table "public"."locations" to "service_role";

grant references on table "public"."locations" to "service_role";

grant select on table "public"."locations" to "service_role";

grant trigger on table "public"."locations" to "service_role";

grant truncate on table "public"."locations" to "service_role";

grant update on table "public"."locations" to "service_role";

grant delete on table "public"."loyalty_cards" to "authenticated";

grant insert on table "public"."loyalty_cards" to "authenticated";

grant select on table "public"."loyalty_cards" to "authenticated";

grant update on table "public"."loyalty_cards" to "authenticated";

grant delete on table "public"."loyalty_cards" to "service_role";

grant insert on table "public"."loyalty_cards" to "service_role";

grant references on table "public"."loyalty_cards" to "service_role";

grant select on table "public"."loyalty_cards" to "service_role";

grant trigger on table "public"."loyalty_cards" to "service_role";

grant truncate on table "public"."loyalty_cards" to "service_role";

grant update on table "public"."loyalty_cards" to "service_role";

grant delete on table "public"."notes" to "authenticated";

grant insert on table "public"."notes" to "authenticated";

grant select on table "public"."notes" to "authenticated";

grant update on table "public"."notes" to "authenticated";

grant delete on table "public"."notes" to "service_role";

grant insert on table "public"."notes" to "service_role";

grant references on table "public"."notes" to "service_role";

grant select on table "public"."notes" to "service_role";

grant trigger on table "public"."notes" to "service_role";

grant truncate on table "public"."notes" to "service_role";

grant update on table "public"."notes" to "service_role";

grant delete on table "public"."product_variants" to "authenticated";

grant insert on table "public"."product_variants" to "authenticated";

grant select on table "public"."product_variants" to "authenticated";

grant update on table "public"."product_variants" to "authenticated";

grant delete on table "public"."product_variants" to "service_role";

grant insert on table "public"."product_variants" to "service_role";

grant references on table "public"."product_variants" to "service_role";

grant select on table "public"."product_variants" to "service_role";

grant trigger on table "public"."product_variants" to "service_role";

grant truncate on table "public"."product_variants" to "service_role";

grant update on table "public"."product_variants" to "service_role";

grant delete on table "public"."products" to "authenticated";

grant insert on table "public"."products" to "authenticated";

grant select on table "public"."products" to "authenticated";

grant update on table "public"."products" to "authenticated";

grant delete on table "public"."products" to "service_role";

grant insert on table "public"."products" to "service_role";

grant references on table "public"."products" to "service_role";

grant select on table "public"."products" to "service_role";

grant trigger on table "public"."products" to "service_role";

grant truncate on table "public"."products" to "service_role";

grant update on table "public"."products" to "service_role";


  create policy "Users can manage their own aisle_products"
  on "public"."aisle_products"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own aisles"
  on "public"."aisles"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own location_loyalty_cards"
  on "public"."location_loyalty_cards"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own locations"
  on "public"."locations"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own loyalty_cards"
  on "public"."loyalty_cards"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own notes"
  on "public"."notes"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own product_variants"
  on "public"."product_variants"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));



  create policy "Users can manage their own products"
  on "public"."products"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));


CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.aisle_products FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.aisles FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.location_loyalty_cards FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.loyalty_cards FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.notes FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');

CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');


