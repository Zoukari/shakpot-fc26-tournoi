# SHAKPOT x FC26 — Tournoi

Site du tournoi FC26 (24 joueurs, arbre à élimination directe, paris spectateurs, classement) avec interface publique + espace organisateurs.

## 1. Créer le projet Supabase (gratuit)

1. Va sur https://supabase.com → **New project**.
2. Une fois créé, ouvre **SQL Editor** → colle le contenu de `schema.sql` → **Run**.
   Ça crée les tables `players`, `tournament_state`, `bets`, active la sécurité (RLS) et le temps réel.
3. Pas de compte à créer : l'accès organisateur fonctionne par numéro de téléphone autorisé + code PIN (voir plus bas). Le numéro `77743322` est autorisé par défaut.
4. Va dans **Project Settings → API** et récupère :
   - `Project URL`
   - `anon public` key

## 2. Configurer le site

Ouvre `index.html`, tout en haut du `<script>`, remplace :

```js
const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
```

par tes vraies valeurs. Ce sont des clés **publiques**, sans risque : la vraie protection vient des règles RLS définies dans `schema.sql` (seul un compte connecté peut inscrire des joueurs / saisir des résultats).

## 3. Déployer sur Vercel

- Connecte ce repo GitHub à Vercel (Import Project).
- Aucune configuration nécessaire : c'est un site statique (`index.html` + dossier `assets/`).
- Une fois en ligne, entre sur le site avec un numéro présent dans la liste des administrateurs (`77743322` par défaut) : le bouton "Espace organisateurs" apparaît en bas de page. Clique dessus et entre le code PIN (`2709` par défaut, modifiable dans `index.html` via la constante `ADMIN_PIN`).
- Depuis le panneau admin, tu peux ajouter ou retirer des numéros autorisés (carte "Accès organisateurs") — utile pour donner l'accès à un autre joueur ou organisateur sans partager le PIN publiquement.

## Fonctionnement

- **Public** : nom + numéro à l'entrée, arbre du tournoi, compte à rebours (07/08 19h, heure de Djibouti), paris sur les matchs à venir, classement, "Mes paris".
- **Admin** (connexion Supabase) : inscription des 24 joueurs, tirage automatique (8 joueurs qualifiés d'office par tirage au sort, 8 vrais matchs au 1er tour), saisie des scores, suivi des paris par match.
- Les données sont partagées en direct entre tous les écrans (Supabase Realtime) : ce que l'admin inscrit apparaît instantanément chez tous les spectateurs.
