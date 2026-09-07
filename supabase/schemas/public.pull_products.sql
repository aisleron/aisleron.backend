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

create or replace function public.pull_products(p_since_timestamp timestamptz)
returns table (
    id uuid,
    client_updated_at timestamptz,
    server_updated_at timestamptz,
    is_deleted boolean,
    name text,
    in_stock boolean,
    qty_needed double precision,
    note_id uuid,
    qty_increment double precision,
    unit_of_measure text,
    tracking_mode text
)

language sql
security invoker
set search_path = ''
as $$
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
$$;