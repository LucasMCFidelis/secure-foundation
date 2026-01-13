begin;

-- 1️⃣ Criar usuário fake no auth.users
insert into auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'user@test.com',
  crypt('password', gen_salt('bf')),
  now(),
  '{}'::jsonb,
  '{}'::jsonb,
  now(),
  now()
);

-- 2️⃣ Simular contexto autenticado
set local role authenticated;
set local request.jwt.claim.sub = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

-- 3️⃣ Verificar se o profile foi criado
select
  count(*) as profile_count
from public.profiles
where user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
-- EXPECTED: 1

-- 4️⃣ Garantir que o usuário vê o próprio profile
select
  count(*) as visible_profiles
from public.profiles;
-- EXPECTED: 1

-- 5️⃣ Simular outro usuário
set local request.jwt.claim.sub = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- 6️⃣ Não deve ver profiles de outros usuários
select
  count(*) as other_user_profiles
from public.profiles;
-- EXPECTED: 0

rollback;
