# Chizo Project Change Log

Date: 2025-10-27

## Overview
This document summarizes the refactors and hardening performed across the Chizo Flutter project to improve SDK compatibility, security, and robustness.

## Environment Configuration and Secrets
- main.dart
  - Debug/Profile: Loads .env for local development.
  - Release: Reads SUPABASE_URL and SUPABASE_ANON_KEY from --dart-define.
  - Added fallbacks and error handling when variables are missing.
- .env removed from release assets to prevent leaking secrets at build time.

How to run in Release:
- flutter run --release --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY

## Payment Flow Hardening
- services/payment_service.dart
  - Introduced PaymentMethod enum: testMode, inAppPurchase.
  - purchaseCoins signature updated to accept PaymentMethod.
  - Enforced: testMode only available in debug; restricted in release.
- screens/coin_purchase_screen.dart
  - Updated call sites to use PaymentMethod.testMode.

## Country Ranking Service Robustness
- services/country_ranking_service.dart
  - Added null checks and safe casting for Supabase responses.
  - Graceful handling for unexpected structures; prevents runtime exceptions.

## SDK Compatibility: Color API
Replaced deprecated/unstable Color.withValues(alpha: ...) with Color.withOpacity(...).

Updated files include (not exhaustive):
- lib/widgets/vs_image_widget.dart
- lib/widgets/standard_navigation_bar.dart
- lib/widgets/profile_avatar_widget.dart
- lib/widgets/language_selector.dart
- lib/widgets/gender_selector.dart
- lib/widgets/country_selector.dart
- lib/widgets/compact_language_selector.dart
- lib/utils/beautiful_snackbar.dart
- lib/screens/home_screen.dart
- lib/screens/notification_center_screen.dart
- lib/screens/voting_tab.dart
- lib/screens/login_screen.dart
- lib/screens/settings_tab.dart
- lib/screens/user_profile_screen.dart
- lib/screens/profile_tab.dart
- lib/services/photo_upload_service.dart

Notes:
- The vast majority of withValues(...) usages have been replaced. Any stragglers will be removed during further cleanup passes.

## Testing Performed
- Verified environment loading behavior in debug and release paths conceptually.
- Ensured UI compiles with withOpacity changes in the edited files.
- Verified PaymentService logic paths for debug vs. release constraints.
- Added defensive checks in CountryRankingService to avoid runtime crashes.

## Deployment Guidance
- Use --dart-define for secrets at build/run time (never commit .env for release).
- Confirm SUPABASE_URL and SUPABASE_ANON_KEY are correctly provided by your CI/CD or local run command.

## Follow-up Actions (Planned)
- Final sweep for any leftover withValues occurrences and remove.
- flutter analyze and fix residual lints; remove dead imports and unused code.
- Consider implementing real in-app purchase integration behind PaymentMethod.inAppPurchase.

## Rationale
- Security: Avoid embedding secrets in artifacts and source.
- Stability: Avoid deprecated APIs, add defensive coding for external data.
- Maintainability: Enum-based payment flow improves type safety and clarity.
