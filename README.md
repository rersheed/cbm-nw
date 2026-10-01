# CBM-NW — City Boy Movement North-West Membership Platform

Flutter + Dart membership registration and coordination app for **North-West Nigeria** (Kaduna, Kano, Katsina, Jigawa, Kebbi, Sokoto, Zamfara).

**Branding:** City Boy Movement · green `#39a453` · blue `#5cc3e7` · red `#e52b32` · gold/brown `#976532`

**Repo:** https://github.com/rersheed/cbm-nw  
**Live web (GitHub Pages):** https://rersheed.github.io/cbm-nw/

## Roles

| Role | Home |
|------|------|
| Registration Agent | Dashboard + 5-step registration wizard + digital card |
| Ward Coordinator | Ward stats + Approve/Reject queue |
| LGA Coordinator | Totals, wards, pending + ward performance bars |
| State Coordinator | Members / LGAs / agents + State→LGA→Ward→Members drill |
| Admin (Situation Room) | NW totals, member table, agents, org tree, reports, comms |

## Stack

- Flutter / Dart + **Riverpod** + **GoRouter**
- **Hive** (offline registration drafts + sync queue)
- **supabase_flutter** hybrid: always boots DemoRepository; probes Supabase and labels connection
- Schema: `supabase/migrations/001_cbm_nw_schema.sql`

## Supabase

| | |
|--|--|
| Project | `cbm-nw` |
| URL | `https://awoliraufydoeaoorutm.supabase.co` |
| Ref | `awoliraufydoeaoorutm` |
| Region | eu-central-1 |
| Client key | **anon** (public) — see `.env.example` / `lib/core/supabase_config.dart` |

Migration `001_cbm_nw_schema` is applied (states/lgas/wards/communities/profiles/members/approvals/messages/audit + open anon demo RLS + 7 NW states seeded). Local demo geo/members live in the Flutter DemoRepository for offline UX.

### dart-define

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://awoliraufydoeaoorutm.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt>
```

## Demo login

1. Open the app → splash → login.
2. Pick a **role chip** (Agent / Ward / LGA / State / Admin). Phone + demo password prefill.
3. Tap **Login** (or **Use OTP instead** → any 6 digits → Verify).
4. No real SMS; all data is seeded locally and works offline.

## Screens shipped

Auth: Splash, Login, OTP, Forgot Password  
Agent: Dashboard, Registration wizard (5 steps), Digital membership card  
Ward: Dashboard, Approval list  
LGA: Dashboard + ward performance  
State: Dashboard + geography drill  
Admin: Situation, Members table, Agents, Org tree, Reports, Communication

## Build web (GitHub Pages)

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
flutter build web --base-href /cbm-nw/ \
  --dart-define=SUPABASE_URL=https://awoliraufydoeaoorutm.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt>
rm -rf docs && mkdir -p docs && cp -r build/web/* docs/ && touch docs/.nojekyll
```

## Prerequisites

- Flutter stable 3.35+ (Dart 3.9+)
