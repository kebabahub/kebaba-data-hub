# KEBABADATAHUB — Mobile App

Native Flutter app (not a WebView) that talks to the same PHP/MySQL backend,
SMEPlug integration, and KatPay integration as kebabadatahub.com.ng — nothing
on the website changed to build this.

## What's real vs. what needs your action

**Built and verified working today** (tested live against the production API,
not just written and assumed correct):
- Full backend API layer at `/api/mobile/*` on the server — auth, wallet
  funding, buying airtime/data, transactions, profile, profile photo upload.
  Every endpoint was hit with real requests during development: register,
  login, a real airtime purchase, a real wallet-funding order, photo upload
  with a malicious-file-upload rejection test, token revocation on logout.
- All app screens, matching the website's colors/fonts/layout token-for-token
  from `assets/css/styles.css`.
- Biometric login gate, share-receipt, deep-link routing, offline transaction
  caching — all wired to real, working code paths.

**Cannot be verified from the server this was built on** — there is no
Flutter SDK, Android/iOS toolchain, or device/emulator on that machine. This
code has never been compiled. Run `flutter pub get` and `flutter analyze` as
your first step on a real dev machine and expect to fix minor issues — plugin
API surfaces shift between versions and I could not compile against the exact
versions pinned in `pubspec.yaml` to confirm they line up.

**Inactive until you provide something:**
- **Push notifications** — needs a Firebase project. Create one at
  console.firebase.google.com, add an Android app (pick a package name, e.g.
  `com.kebabadatahub.app`) and an iOS app (pick a bundle ID), download
  `google-services.json` → `android/app/`, and `GoogleService-Info.plist` →
  `ios/Runner/`. Then uncomment the two Firebase lines in `lib/main.dart`.
  The server-side piece (an endpoint to save the FCM token) is already built
  and tested at `/api/mobile/device-token.php` — the last piece is having
  `send_notification()` in `includes/functions.php` also push via FCM when a
  device token is on file. Ask me to build that once Firebase is set up.
- **Deep linking (universal/app links, not just the custom scheme)** — needs
  `.well-known/assetlinks.json` (Android) and
  `.well-known/apple-app-site-association` (iOS) hosted on the website, which
  need your app's package name / bundle ID and signing certificate
  fingerprint. Ask me to generate both once you have those.
- **App store listings** — needs your own Apple Developer ($99/yr) and Google
  Play Developer ($25 one-time) accounts; I have no access to create these.

## Setup

```bash
flutter pub get
flutter run          # needs a connected device or running emulator
```

## Project structure

```
lib/
  core/           API client, auth state, theme (colors/fonts copied from styles.css)
  models/         User, DataPlan, AppTransaction
  screens/        One file per screen, named to match the website's pages
  services/       Biometric, push, deep link, offline cache
  widgets/        Shared UI pieces (bottom nav, action cards, transaction tile)
```

## Backend API reference

All endpoints live in `public_html/api/mobile/` on the server, alongside (not
replacing) the website's own PHP pages. They reuse the exact same
`includes/services.php`, `includes/katpay.php`, `includes/wallet.php` — the
same SMEPlug and KatPay integration the website uses, unchanged.

| Endpoint | Purpose |
|---|---|
| `POST /auth/login.php` | Email + password → bearer token |
| `POST /auth/register.php` | Create account → bearer token |
| `POST /auth/logout.php` | Revoke the current token |
| `POST /auth/forgot-password.php` | Request a reset code by email or phone |
| `POST /auth/reset-password.php` | Complete a reset with the code |
| `GET /profile.php` / `PUT /profile.php` | Read / update name + phone |
| `POST /profile-photo.php` | Upload a profile photo (JPG/PNG/WEBP, 5MB max) |
| `GET /wallet/balance.php` | Current wallet balance |
| `POST /wallet/fund.php` | Generate a one-time funding account for an amount |
| `GET /wallet/status.php?reference=` | Poll a funding request's status |
| `GET /plans.php?network=` | Data plans for a network |
| `POST /buy/airtime.php` | Buy airtime |
| `POST /buy/data.php` | Buy a data plan |
| `GET /transactions.php?page=` | Paginated transaction history |
| `POST /device-token.php` | Register a device for push (inactive until Firebase is set up) |

Every endpoint requires `Authorization: Bearer <token>` except login/register/
forgot-password/reset-password. Same rate limits as the website (login,
signup, password reset, purchases) — the token-auth layer doesn't bypass any
of the abuse protection already built into the backend.
