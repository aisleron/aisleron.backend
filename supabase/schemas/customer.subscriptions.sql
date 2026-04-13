-- TODO: Make sure no weird grants exist on subscription

create table customer.subscriptions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  current_period_end timestamptz not null,
  status text not null default 'inactive',
  provider text,
  provider_customer_id text,
  provider_subscription_id text
);

comment on table customer.subscriptions is 'Stores active subscription states, expiry dates, and third-party provider IDs for users.';

-- alter table customer.subscriptions enable row level security;

revoke all on table customer.subscriptions from authenticated;
revoke all on table customer.subscriptions from anon;
