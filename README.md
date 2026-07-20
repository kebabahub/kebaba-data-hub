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

## Setup (on a machine with Flutter installed)

```bash
flutter pub get
flutter run          # needs a connected device or running emulator
```

## Getting an actual APK / iOS build without a Mac

This project's source lives at `mobile_app/` on the same server as the
website — it is **not** on GitHub yet, and there is no
Flutter/Java/Android/Xcode toolchain on this Linux hosting box to build from
directly (confirmed: no `flutter`, no `java`/`gradle`/`keytool`, no
`xcodebuild` — iOS builds require Xcode on macOS specifically, which cannot
run on Linux under any circumstances). A git repo with 2 commits already
exists locally, a dedicated SSH deploy key has been generated for pushing it
(public key below), and `codemagic.yaml` is included, pre-configured for a
signed Android APK + App Bundle build and an iOS archive build. To actually
produce the files:

A git repo already exists in this folder (2 commits) with a dedicated deploy
key generated and ready — nothing more to install. **What's needed from you
is two things only you can provide: a GitHub repo to push to, and your own
Codemagic/Play/Apple accounts connected in their respective dashboards.**

1. **Create an empty repository on GitHub** (I have no GitHub account and
   can't create one for you) — e.g. `kebabadatahub-mobile`. Don't initialize
   it with a README/license, so the push below doesn't conflict.
2. **Add this deploy key to that repo**: GitHub repo → Settings → Deploy keys
   → Add deploy key → check "Allow write access" → paste:
   ```
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHObjJ9R1RXwGKnr6elQYtjJ4bWCxAFrOVSTOFEUa3ar kebabadatahub-mobile-deploy
   ```
   (This key lives only on this server, scoped to push to this one repo — not
   your personal GitHub account.)
3. **Tell me the repo's SSH URL** (`git@github.com:yourname/kebabadatahub-mobile.git`)
   and I'll push immediately — the remote is already configured to use this
   key for anything under `github.com`.
4. **Sign up at codemagic.io** (free tier) and connect the repo. It'll detect
   `codemagic.yaml` automatically, with two workflows: `android-release`
   (signed APK + AAB) and `ios-archive`.
5. **Android signing** — I cannot generate a real keystore on this server (no
   JDK/`keytool` installed here, and installing a full JDK just to run
   `keytool` isn't worth it for one file). Easiest path: in Codemagic → your
   app → Code signing identities → Android, use Codemagic's **"Generate
   keystore"** button — it creates a real, valid keystore for you directly in
   their UI, no local tooling needed. Name the reference `kebabadatahub_keystore`
   to match `codemagic.yaml`, or update that line to match whatever you name it.
   **Save the generated keystore + passwords somewhere safe outside
   Codemagic too** — if you ever lose it, you can never update the app under
   the same Play Store listing again.
6. **Run the `android-release` workflow** — produces a real signed
   `app-release.apk` and `app-release.aab`, emailed to you automatically.
7. **iOS**: run `ios-archive` — needs your Apple Developer account connected
   in Codemagic (Teams → Code signing identities → iOS), and
   `bundle_identifier` in `codemagic.yaml` updated to match what you register
   in App Store Connect.

Alternatively, if you get access to a machine with Flutter installed, `flutter
build apk --release` / `flutter build appbundle --release` work the same way
locally without Codemagic — iOS still needs an actual Mac with Xcode either way.

## Publishing checklist

**Google Play** (needs a one-time $25 Google Play Developer account):
1. Create the app in [Play Console](https://play.google.com/console).
2. Generate a real signing keystore (`keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`) — keep this file and its password somewhere safe forever; losing it means you can never update the app again under the same listing.
3. Wire the keystore into `android/key.properties` (not committed to git — see `.gitignore`) and `android/app/build.gradle`'s `signingConfigs`, or let Codemagic manage signing for you (Teams → Code signing → Android).
4. Store listing: app name, description, screenshots (from a real device/emulator, not mockups), a 512×512 icon, a feature graphic, privacy policy URL (you already have one live: `https://kebabadatahub.com.ng/privacy.php`).
5. Content rating questionnaire, target audience, data safety form (declare what the app collects — matches what's already in the Privacy Policy: name, email, phone, transaction history).
6. Upload the release `.aab` (Play prefers Android App Bundle over raw APK — `flutter build appbundle --release` instead of `build apk`) and submit for review.

**Apple App Store** (needs a $99/year Apple Developer account):
1. Register the app's Bundle ID in [developer.apple.com](https://developer.apple.com) (must match `bundle_identifier` in `codemagic.yaml` and `ios/Runner.xcodeproj`).
2. Create the app listing in [App Store Connect](https://appstoreconnect.apple.com).
3. Code signing: either let Codemagic handle it automatically (recommended — Teams → Code signing → iOS, connect your Apple Developer account, it generates certificates/profiles for you), or generate a distribution certificate + provisioning profile manually in Xcode.
4. App Store listing: screenshots for each required device size, app icon (1024×1024), description, keywords, support URL, privacy policy URL (same one as above), and answers to Apple's privacy "nutrition label" questions.
5. Apple's review is stricter about account deletion — since the app has login/signup, Apple requires an in-app way to delete your account. **Already built and tested**: `Account → Delete account` in the app, backed by `/api/mobile/delete-account.php` (requires password re-entry, blocks deletion if there's an unresolved wallet balance so money can't get silently stranded).
6. Submit the build produced by the `ios-archive` Codemagic workflow for review via App Store Connect.

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
| `POST /delete-account.php` | Permanently delete the account (password required, blocked if wallet balance > 0) |

Every endpoint requires `Authorization: Bearer <token>` except login/register/
forgot-password/reset-password. Same rate limits as the website (login,
signup, password reset, purchases) — the token-auth layer doesn't bypass any
of the abuse protection already built into the backend.
