-- Enable extensions
create extension if not exists moddatetime schema extensions;

-- Stop giving default full access to new tables
alter default privileges in schema public revoke all on tables from authenticated;
alter default privileges in schema public revoke all on tables from anon;

-- Create custom schemas
create schema if not exists customer;
grant usage on schema customer to supabase_auth_admin;
