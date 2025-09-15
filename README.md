# valhalla_android

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Navigation Architecture

The project uses a lightweight MVVM-inspired structure with a centralized navigation system:

Key elements:

1. `NavigationService` (`lib/services/navigation_service.dart`)
	- Holds a global `navigatorKey` for navigation without a `BuildContext` inside providers or services.
	- Helper methods: `push`, `replaceWith`, `pushAndRemoveUntil`, `pop`.

2. Route definitions (`lib/utils/routes.dart`)
	- Split into public and protected route maps for clarity.
	- `AppRoutes.homeForRole(roleName)` returns the correct home route after login.
	- A single `generateRoute` function builds all pages and wraps protected ones in `AuthGate`.

3. `AuthGate` (`lib/widgets/navigation/auth_gate.dart`)
	- Ensures user is authenticated before showing protected content.
	- Redirects to `AppRoutes.login` if session is missing/expired.

4. `AuthProvider` (`lib/providers/auth_provider.dart`)
	- Manages login state; after successful login the UI navigates via `NavigationService` to role-based home.

5. `main.dart`
	- Registers `navigatorKey` and attaches `AppRoutes.generateRoute`.
	- Uses `initialRoute: AppRoutes.login`; the provider + gate handle post-auth routing.

### Adding a New Protected Screen
1. Create the screen in `lib/screens/<area>/<your_screen>.dart`.
2. Add a route constant in `AppRoutes`.
3. Add an entry in the `_protected` map: `routeName: (_) => const YourScreen(),`.
4. Navigate using: `NavigationService.instance.push(AppRoutes.yourRoute);`.

### Adding a Public Screen
1. Create the screen.
2. Add constant + entry to `_public` map.
3. Navigate the same way via `NavigationService` or a `Navigator` context.

### Role-Based Home Dispatch
Handled by calling:
```dart
final target = AppRoutes.homeForRole(user.roleName);
NavigationService.instance.pushAndRemoveUntil(target);
```

### Why Not GoRouter / Router 2.0 Yet?
The current scale is modest; manual routing keeps dependencies minimal. Migration to `go_router` is straightforward later if deep linking or nested navigation complexity increases.

### Guard Behavior
- While auth status is `loading`, a spinner shows.
- If unauthenticated when visiting a protected route, user is redirected to login and the previous stack is cleared.

---
This structure keeps navigation explicit, testable, and easy to evolve as features grow.
