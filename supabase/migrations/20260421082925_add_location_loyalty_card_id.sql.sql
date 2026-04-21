revoke delete on table "public"."aisle_products" from "anon";

revoke insert on table "public"."aisle_products" from "anon";

revoke references on table "public"."aisle_products" from "anon";

revoke select on table "public"."aisle_products" from "anon";

revoke trigger on table "public"."aisle_products" from "anon";

revoke truncate on table "public"."aisle_products" from "anon";

revoke update on table "public"."aisle_products" from "anon";

revoke references on table "public"."aisle_products" from "authenticated";

revoke trigger on table "public"."aisle_products" from "authenticated";

revoke truncate on table "public"."aisle_products" from "authenticated";

revoke delete on table "public"."aisles" from "anon";

revoke insert on table "public"."aisles" from "anon";

revoke references on table "public"."aisles" from "anon";

revoke select on table "public"."aisles" from "anon";

revoke trigger on table "public"."aisles" from "anon";

revoke truncate on table "public"."aisles" from "anon";

revoke update on table "public"."aisles" from "anon";

revoke references on table "public"."aisles" from "authenticated";

revoke trigger on table "public"."aisles" from "authenticated";

revoke truncate on table "public"."aisles" from "authenticated";

revoke delete on table "public"."location_loyalty_cards" from "anon";

revoke insert on table "public"."location_loyalty_cards" from "anon";

revoke references on table "public"."location_loyalty_cards" from "anon";

revoke select on table "public"."location_loyalty_cards" from "anon";

revoke trigger on table "public"."location_loyalty_cards" from "anon";

revoke truncate on table "public"."location_loyalty_cards" from "anon";

revoke update on table "public"."location_loyalty_cards" from "anon";

revoke references on table "public"."location_loyalty_cards" from "authenticated";

revoke trigger on table "public"."location_loyalty_cards" from "authenticated";

revoke truncate on table "public"."location_loyalty_cards" from "authenticated";

revoke delete on table "public"."locations" from "anon";

revoke insert on table "public"."locations" from "anon";

revoke references on table "public"."locations" from "anon";

revoke select on table "public"."locations" from "anon";

revoke trigger on table "public"."locations" from "anon";

revoke truncate on table "public"."locations" from "anon";

revoke update on table "public"."locations" from "anon";

revoke references on table "public"."locations" from "authenticated";

revoke trigger on table "public"."locations" from "authenticated";

revoke truncate on table "public"."locations" from "authenticated";

revoke delete on table "public"."loyalty_cards" from "anon";

revoke insert on table "public"."loyalty_cards" from "anon";

revoke references on table "public"."loyalty_cards" from "anon";

revoke select on table "public"."loyalty_cards" from "anon";

revoke trigger on table "public"."loyalty_cards" from "anon";

revoke truncate on table "public"."loyalty_cards" from "anon";

revoke update on table "public"."loyalty_cards" from "anon";

revoke references on table "public"."loyalty_cards" from "authenticated";

revoke trigger on table "public"."loyalty_cards" from "authenticated";

revoke truncate on table "public"."loyalty_cards" from "authenticated";

revoke delete on table "public"."notes" from "anon";

revoke insert on table "public"."notes" from "anon";

revoke references on table "public"."notes" from "anon";

revoke select on table "public"."notes" from "anon";

revoke trigger on table "public"."notes" from "anon";

revoke truncate on table "public"."notes" from "anon";

revoke update on table "public"."notes" from "anon";

revoke references on table "public"."notes" from "authenticated";

revoke trigger on table "public"."notes" from "authenticated";

revoke truncate on table "public"."notes" from "authenticated";

revoke delete on table "public"."products" from "anon";

revoke insert on table "public"."products" from "anon";

revoke references on table "public"."products" from "anon";

revoke select on table "public"."products" from "anon";

revoke trigger on table "public"."products" from "anon";

revoke truncate on table "public"."products" from "anon";

revoke update on table "public"."products" from "anon";

revoke references on table "public"."products" from "authenticated";

revoke trigger on table "public"."products" from "authenticated";

revoke truncate on table "public"."products" from "authenticated";

alter table "public"."location_loyalty_cards" drop constraint "location_loyalty_cards_pkey";

drop index if exists "public"."location_loyalty_cards_pkey";

alter table "public"."location_loyalty_cards" add column "id" uuid not null default gen_random_uuid();

CREATE UNIQUE INDEX location_loyalty_cards_location_id_key ON public.location_loyalty_cards USING btree (location_id);

CREATE UNIQUE INDEX location_loyalty_cards_pkey ON public.location_loyalty_cards USING btree (id);

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_pkey" PRIMARY KEY using index "location_loyalty_cards_pkey";

alter table "public"."location_loyalty_cards" add constraint "location_loyalty_cards_location_id_key" UNIQUE using index "location_loyalty_cards_location_id_key";


