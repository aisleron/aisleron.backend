-- Create customer schema and allow usage by supabase_auth_admin
-- Workaround for migrations not applying grants to supabase_auth_admin
create schema if not exists customer;
grant usage on schema customer to supabase_auth_admin;