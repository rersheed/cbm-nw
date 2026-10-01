# CBM-NW — City Boy Movement North-West Membership

Flutter membership app for **North-West Nigeria** (Kaduna, Kano, Katsina, Jigawa, Kebbi, Sokoto, Zamfara).

**Roles:** **Member** and **Admin** only.

**Branding:** City Boy Movement · green `#39a453` · gold/brown `#976532`

**Repo:** https://github.com/rersheed/cbm-nw  
**Live web (GitHub Pages):** https://rersheed.github.io/cbm-nw/

## Screens

| Flow | Screens |
|------|---------|
| Auth | Splash, Login, Register, OTP, Forgot Password |
| Member | Home (status), 5-step registration, Digital card (download/share stub), Profile |
| Admin | Dashboard cards + breakdowns, Members list + filters/search, Pending approvals, Member detail (VIN/voter card admin-only) |

### Registration steps
1. Personal — name, gender, DOB, phone, email optional, occupation  
2. Location — State → LGA → Ward → Polling Unit  
3. Voter — registered Yes/No; if Yes: VIN + optional voter-card upload stub  
4. Profile photo (camera/upload stub)  
5. Review + consent → Submit → **Pending**

Membership number (on approve): `CBM-NW-{STATE}-{######}`  
QR / card: basic info only — **no VIN / voter card**.

## Stack
- Flutter / Dart + Riverpod + GoRouter
- Hive (offline drafts + sync queue)
- supabase_flutter hybrid (DemoRepository + Supabase probe)
- Schema: `supabase/migrations/001_cbm_nw_schema.sql` + **`002_simplify_member_admin.sql`** (apply 002)

## Supabase
| | |
|--|--|
| URL | `https://awoliraufydoeaoorutm.supabase.co` |
| Ref | `awoliraufydoeaoorutm` |

**Privacy:** Demo-open RLS remains. VIN / voter_card_url must stay admin-only in the app; tighten RLS before production.

## Demo login
1. Splash → Login  
2. Pick **Member** or **Admin** chip (phones prefill)  
3. Password `demo1234` or OTP (any 6 digits)  
4. **Member** `08030000001` (approved sample) · `08030000002` (pending) · **Admin** `08030000005`  
5. Or **Create member account** → register → complete 5-step wizard  

## Build web (GitHub Pages)
```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
flutter build web --base-href /cbm-nw/
rm -rf docs && mkdir -p docs && cp -r build/web/* docs/ && touch docs/.nojekyll
```
