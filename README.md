# valhalla_android

A new Flutter project.

## Architecture Guide

For a detailed explanation of how this app is structured (MVVM, navigation, auth, CRUD), see:

- docs/ARCHITECTURE.md

This document covers how to extend the app with new modules following the same patterns.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Navigation & Refactor Architecture (GoRouter)

The app uses `go_router` for declarative, nested, and guarded navigation (auth + role based). The recent refactor modernized routing and modularized UI without changing the original top-level directory structure.

### Core Pieces
1. `AppRoutes` (`lib/utils/routes.dart`)
   * Path constants only + `homeForRole()` helper.
   * `publicRoutes` list drives the login redirect logic.
2. `AppRouter` (`lib/utils/app_router.dart`)
   * Central `GoRouter` with nested groups (admin, owner, payments, reservations).
   * `redirect` handles:
     - Unauthenticated -> `/` (login) unless already public.
     - Authenticated visiting `/` -> role home (`/home-admin` or `/home-owner`).
     - Admin-only guard for admin-specific paths.
3. `AuthProvider` integration
   * Provided as a `refreshListenable` so route conditions re-evaluate automatically.
4. Role-based home
   * Centralized in `AppRoutes.homeForRole(roleName)` for consistent post-login routing.

### Removed Legacy Artifacts
`NavigationService` and `AuthGate` have been removed after full migration to `go_router`. Always use:
* `context.go(path)` – Replace current location (e.g. after login/logout).
* `context.push(path)` – Push a new screen onto the stack.

### Common Navigation Examples
```dart
// After successful login
context.go(AppRoutes.homeForRole(auth.user!.roleName));

// Drill-in (preserve back stack)
context.push(AppRoutes.paymentHistory);

// Admin change password (nested route)
context.push(AppRoutes.changePasswordProfileAdmin);
```

### Adding a New Screen
1. Add a constant in `AppRoutes`.
2. If publicly reachable when logged out, add it to `publicRoutes`.
3. Register a `GoRoute` in `app_router.dart` under the appropriate parent.
4. Navigate with `context.push()` / `context.go()`.

### Shared UI Components
Located in `lib/widgets/common/`:
* `primary_button.dart` – Standard primary buttons (loading-aware).
* `profile_header.dart` – Large avatar + display name block.
* `coming_soon_section.dart` – Placeholder for unimplemented tabs.

Auth, owner, and admin profile sections now consume these shared primitives for consistency.

### Refactor Summary
Completed:
* Migrated to `go_router` with centralized auth/role redirects.
* Deleted legacy navigation wrappers.
* Componentized admin & owner dashboards and profile sections.
* Modularized auth login view (`LoginForm` + color constants).
* Extracted reusable UI primitives.
* Standardized navigation API usage across all screens.

Potential Future Enhancements:
* Introduce `StatefulShellRoute` to retain state across bottom nav tab switches.
* Add integration tests for guarded routes and deep linking.
* Consolidate spacing/typography into a design tokens file.
* Extract additional domain widgets (payments/reservations rows) for clarity.

### Deep Linking & Web
`go_router` supports deep linking automatically. Keep paths stable and human-readable.

---
This architecture reduces boilerplate, improves testability, and creates a clear path for incremental feature growth.
