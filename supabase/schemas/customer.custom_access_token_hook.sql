create or replace function customer.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
security definer 
set search_path = public, customer, auth
as $$
  declare
    sub_record record;
    new_claims jsonb;
  begin
    /* 1. Fetch subscription details */
    select 
      s.current_period_end, 
      (s.current_period_end > now()) as is_active
    into sub_record
    from customer.subscriptions s
    where s.user_id = (event ->> 'user_id')::uuid;

    /* 2. Isolate the existing claims from the input event */
    new_claims := event -> 'claims';

    /* 3. Inject into app_metadata (using coalesce for safety) */
    new_claims := jsonb_set(
      new_claims, 
      '{app_metadata, is_subscribed}', 
      to_jsonb(coalesce(sub_record.is_active, false))
    );
                       
    new_claims := jsonb_set(
      new_claims, 
      '{app_metadata, sub_expiry}', 
      to_jsonb(coalesce(sub_record.current_period_end::text, ''))
    );

    /* 4. Return the specific structure the Auth service expects */
    return jsonb_build_object('claims', new_claims);
  end;
$$;

/* Permissions for the Auth service */
-- grant execute on function customer.custom_access_token_hook to supabase_auth_admin;

/*
TODO: which of these are not applied by the migrations automatically?

** Looks like just 1. is required

-- 1. Let the Auth service "see" the schema
grant usage on schema customer to supabase_auth_admin;

-- 2. Let the Auth service "see" the table
grant select on table customer.subscriptions to supabase_auth_admin;

-- 3. Let the Auth service "run" the function
grant execute on function customer.custom_access_token_hook to supabase_auth_admin;

-- 4. If you have RLS enabled on the subscriptions table, 
-- you must also allow the service role to bypass it or add a specific policy.
alter table customer.subscriptions force row level security; -- ensure it's on
create policy "Allow auth service to read subscriptions" 
on customer.subscriptions
for select
to supabase_auth_admin
using (true);
*/