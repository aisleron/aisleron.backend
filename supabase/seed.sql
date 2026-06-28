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

-- Add users
INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, 
    last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, 
    email_change, email_change_token_new, recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
  'authenticated',
  'authenticated',
  'a@b.com',
  extensions.crypt('aatbdotcom', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"name":"Active User"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  'b2c3d4e5-f6a7-5b6c-9d0e-1f2a3b4c5d6e',
  'authenticated',
  'authenticated',
  'x@y.zom',
  extensions.crypt('xatydotzom', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"name":"Expired User"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  'f370af38-8655-46ff-9085-9916835d6c48',
  'authenticated',
  'authenticated',
  'l@m.nom',
  extensions.crypt('latmdotnom', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"name":"No Sub User"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO NOTHING;

-- Add subscriptions
INSERT INTO customer.subscriptions (user_id, current_period_end, status)
VALUES 
  ('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', now() + interval '1 year', 'active'),
  ('b2c3d4e5-f6a7-5b6c-9d0e-1f2a3b4c5d6e', now() - interval '1 year', 'active')
ON CONFLICT (user_id) DO NOTHING;

-- Add some products
INSERT INTO public.products (user_id, name, in_stock, qty_needed)
VALUES 
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Product for abc', true, 2),
('b2c3d4e5-f6a7-5b6c-9d0e-1f2a3b4c5d6e', 'Product for xyz', true, 2),
('f370af38-8655-46ff-9085-9916835d6c48', 'Product for lmn', true, 2)
ON CONFLICT DO NOTHING;