-- Copyright (C) 2026 aisleron.com
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Enable extensions
create extension if not exists moddatetime schema extensions;

-- Stop giving default full access to new tables
alter default privileges in schema public revoke all on tables from authenticated;
alter default privileges in schema public revoke all on tables from anon;

-- Create custom schemas
create schema if not exists customer;
grant usage on schema customer to supabase_auth_admin;
