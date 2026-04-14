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

create table public.location_loyalty_cards (
  location_id uuid primary key references public.locations (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  loyalty_card_id uuid not null references public.loyalty_cards on delete cascade
);

comment on table public.location_loyalty_cards is 'Maps a specific shopping location to a user loyalty card to ensure the correct card is shown at checkout.';

create trigger set_server_updated_at
  before update on public.location_loyalty_cards
  for each row
  execute function moddatetime (server_updated_at);

alter table public.location_loyalty_cards enable row level security;

create policy "Subscribed users can manage their own location_loyalty_cards"
  on public.location_loyalty_cards
  for all 
  to authenticated
  using (
    (select auth.uid()) = location_loyalty_cards.user_id 
  )
  with check (
    (select auth.uid()) = location_loyalty_cards.user_id 
    and ((select auth.jwt()) -> 'app_metadata' ->> 'is_subscribed')::boolean = true
  );

grant select, insert, update, delete on table public.location_loyalty_cards to authenticated;
grant all on table public.location_loyalty_cards to service_role;
revoke all on table public.location_loyalty_cards from anon;