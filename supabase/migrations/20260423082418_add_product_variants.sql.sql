
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

CREATE UNIQUE INDEX product_variants_pkey ON public.product_variants USING btree (id);

alter table "public"."product_variants" add constraint "product_variants_pkey" PRIMARY KEY using index "product_variants_pkey";

alter table "public"."product_variants" add constraint "product_variants_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE not valid;

alter table "public"."product_variants" validate constraint "product_variants_product_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."product_variants" validate constraint "product_variants_user_id_fkey";

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


  create policy "Subscribed users can manage their own product_variants"
  on "public"."product_variants"
  as permissive
  for all
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check (((( SELECT auth.uid() AS uid) = user_id) AND ((((( SELECT auth.jwt() AS jwt) -> 'app_metadata'::text) ->> 'is_subscribed'::text))::boolean = true)));


CREATE TRIGGER set_server_updated_at BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('server_updated_at');


