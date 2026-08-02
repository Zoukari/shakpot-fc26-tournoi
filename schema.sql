-- ============================================================
-- SHAKPOT x FC26 — Schéma Supabase
-- À exécuter dans Supabase > SQL Editor (nouvelle requête, "Run")
-- ============================================================

create table if not exists players (
  id text primary key,
  nom text not null,
  prenom text not null,
  age int not null,
  club text not null,
  created_at timestamptz default now()
);

create table if not exists tournament_state (
  id int primary key,
  bracket jsonb,
  updated_at timestamptz default now()
);
insert into tournament_state (id, bracket)
  values (1, null)
  on conflict (id) do nothing;

create table if not exists bets (
  id bigint generated always as identity primary key,
  match_id text not null,
  nom text not null,
  tel text not null,
  side text not null check (side in ('p1','p2')),
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

-- Un visiteur (anonyme) peut placer un pari, mais pas modifier joueurs / tirage
create policy "public insert bets" on bets for insert with check (true);

-- Seul un compte admin connecté (Supabase Auth) peut inscrire des joueurs
-- et générer/mettre à jour le tirage + les résultats
create policy "admin insert players" on players for insert to authenticated with check (true);
create policy "admin delete players" on players for delete to authenticated using (true);
create policy "admin update state" on tournament_state for update to authenticated using (true);
create policy "admin insert state" on tournament_state for insert to authenticated with check (true);
create policy "admin delete bets" on bets for delete to authenticated using (true);

-- ---------- Realtime (mise à jour live sur tous les écrans) ----------
alter publication supabase_realtime add table players;
alter publication supabase_realtime add table tournament_state;
alter publication supabase_realtime add table bets;
