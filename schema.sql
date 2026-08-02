-- ============================================================
-- SHAKPOT x FC26 — Schéma Supabase
-- À exécuter dans Supabase > SQL Editor (nouvelle requête, "Run")
--
-- Ce projet n'utilise PAS Supabase Auth : l'accès organisateur se fait
-- via un numéro de téléphone autorisé (stocké dans tournament_state.admins)
-- + un code PIN partagé, vérifiés côté site (index.html).
-- ============================================================

create table if not exists players (
  id text primary key,
  nom text not null,
  prenom text not null,
  age int not null,
  club text not null,
  tel text not null default '',
  pin text not null default '',
  created_at timestamptz default now()
);

alter table players add column if not exists tel text not null default '';
alter table players add column if not exists pin text not null default '';

create table if not exists tournament_state (
  id int primary key,
  bracket jsonb,
  admins jsonb default '["77743322"]'::jsonb,
  viewer_base int,
  updated_at timestamptz default now()
);

alter table tournament_state add column if not exists admins jsonb default '["77743322"]'::jsonb;
alter table tournament_state add column if not exists viewer_base int;

insert into tournament_state (id, bracket, admins)
  values (1, null, '["77743322"]'::jsonb)
  on conflict (id) do nothing;

create table if not exists bets (
  id bigint generated always as identity primary key,
  match_id text not null,
  nom text not null,
  tel text not null,
  pred1 int,
  pred2 int,
  created_at timestamptz default now()
);

-- ---------- Sécurité (RLS) ----------
alter table players enable row level security;
alter table tournament_state enable row level security;
alter table bets enable row level security;

-- Tout le monde peut lire (le site public affiche l'arbre, le classement, les paris)
create policy "public read players" on players for select using (true);
create policy "public read state" on tournament_state for select using (true);
create policy "public read bets" on bets for select using (true);

-- Un visiteur (anonyme) peut placer un pari
create policy "public insert bets" on bets for insert with check (true);

-- Pas de compte Supabase Auth : la protection admin se fait côté site
-- (numéro autorisé + code PIN). Les écritures admin passent donc par
-- le rôle "anon" comme le reste du site.
create policy "public insert players" on players for insert to anon, authenticated with check (true);
create policy "public delete players" on players for delete to anon, authenticated using (true);
create policy "public update state" on tournament_state for update to anon, authenticated using (true);
create policy "public insert state" on tournament_state for insert to anon, authenticated with check (true);
create policy "public delete bets" on bets for delete to anon, authenticated using (true);

-- ---------- Realtime (mise à jour live sur tous les écrans) ----------
alter publication supabase_realtime add table players;
alter publication supabase_realtime add table tournament_state;
alter publication supabase_realtime add table bets;
