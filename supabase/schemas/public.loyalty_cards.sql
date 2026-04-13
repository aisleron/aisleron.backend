create table public.loyalty_cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_updated_at timestamptz not null default now(),
  server_updated_at timestamptz not null default now(),
  is_deleted boolean not null default false,
  name text not null,
  provider text not null,
  intent text not null
);

comment on table public.loyalty_cards is 'Stores user-defined loyalty programs, card names, and provider details.';

create trigger set_server_updated_at
  before update on public.loyalty_cards
  for each row
  execute function moddatetime (server_updated_at);

alter table public.loyalty_cards enable row level security;

create policy "Subscribed users can manage their own loyalty_cards"
  on public.loyalty_cards
  for all 
  to authenticated
  using (
    (select auth.uid()) = loyalty_cards.user_id
  )
  with check (
    (select auth.uid()) = loyalty_cards.user_id 
    and ((select auth.jwt()) -> 'app_metadata' ->> 'is_subscribed')::boolean = true
  );

grant select, insert, update, delete on table public.loyalty_cards to authenticated;
grant all on table public.loyalty_cards to service_role;
revoke all on table public.loyalty_cards from anon;