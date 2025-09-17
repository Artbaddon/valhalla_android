# Changelog

## Unreleased (Navigation & UI Refactor)
### Added
- Integrated `go_router` with centralized auth + role-based redirects (`AppRouter`).
- Shared UI components: `PrimaryButton`, `ProfileHeader`, `ComingSoonSection`.
- Modularized `LoginPage` into `LoginForm` + `auth_colors.dart`.
- Componentized admin & owner home screens (dashboard, profile sections).

### Changed
- Replaced all `Navigator.pushNamed` usages with `context.go` / `context.push`.
- Consolidated profile/action buttons into shared widgets.
- Slimmed `routes.dart` to constants and helpers only.

### Removed
- Deprecated `NavigationService` and `AuthGate` after full migration.
- Local duplicate placeholder/profile button implementations.
- Obsolete owner `coming_soon_section.dart` re-export file.

### Documentation
- Updated `README.md` with migration status, shared components, and architectural guidelines.

### Next (Potential)
- Introduce `StatefulShellRoute` for persistent bottom nav state.
- Add integration tests for route guards and deep linking.
- Centralize design tokens (spacing, typography, radii) in a theme system.
- Extract additional domain-specific widgets (payment/reservation rows) if reused.

---
This refactor focuses on clarity, consistency, and future scalability without disrupting the existing directory structure.
