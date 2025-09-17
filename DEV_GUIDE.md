# Developer Guide

This guide explains how to extend and maintain the project: adding widgets, pages, routes, navigation bars, and integrating with the auth + routing system.

---
## 1. Architecture Overview

Core principles:
- Keep existing folder hierarchy (no feature-level top restructure).
- Use `go_router` for navigation (declarative + guarded).
- Use `Provider` (`AuthProvider`, others later) for app state.
- Extract reusable UI building blocks into `lib/widgets/common/` once reused >= 2 times.
- Keep route constants in `lib/utils/routes.dart` and router config in `lib/utils/app_router.dart`.

Key Directories:
- `lib/main.dart` – App entry, sets up `GoRouter` via `AppRouter.createRouter(authProvider)`.
- `lib/utils/` – Routing & constants.
- `lib/providers/` – State (e.g., `auth_provider.dart`).
- `lib/screens/` – Screens grouped by domain (auth, admin, owner, reservation, payment, etc.).
- `lib/widgets/common/` – Shared primitives (`PrimaryButton`, `ProfileHeader`, `ComingSoonSection`).

---
## 2. Adding a New Widget

Decision: Local vs Shared.
- If only used in one screen: place near that screen (e.g., `lib/screens/payment/payment_status_badge.dart`).
- If reused or generic: `lib/widgets/common/`.

Example: Creating a reusable status pill.
```dart
// lib/widgets/common/status_pill.dart
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

class StatusPill extends StatelessWidget {
  final String label; final Color? color; final EdgeInsetsGeometry padding;
  const StatusPill({super.key, required this.label, this.color, this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4)});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: (color ?? AppColors.purple).withOpacity(.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color ?? AppColors.purple),
    ),
    padding: padding,
    child: Text(label, style: TextStyle(fontSize: 12, color: color ?? AppColors.purple, fontWeight: FontWeight.w600)),
  );
}
```
Usage:
```dart
import 'package:valhalla_android/widgets/common/status_pill.dart';
...
const StatusPill(label: 'Pendiente');
```

Checklist:
- [ ] Keep file name lowercase_snake_case.
- [ ] Avoid business logic inside widgets (pass data in).
- [ ] Use constants for magic numbers where reusable.

---
## 3. Adding a New Screen (Page)

1. Create a new Dart file in the appropriate domain folder (e.g., `lib/screens/payment/payment_receipt_page.dart`).
2. Build a `StatelessWidget` or `StatefulWidget` (prefer `StatelessWidget` until state is needed).
3. Add route constant to `AppRoutes`.
4. Register route in `app_router.dart`.
5. Navigate via `context.push()` or `context.go()`.

Example screen:
```dart
// lib/screens/payment/payment_receipt_page.dart
import 'package:flutter/material.dart';

class PaymentReceiptPage extends StatelessWidget {
  const PaymentReceiptPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recibo')),
      body: const Center(child: Text('Detalles del pago')), 
    );
  }
}
```

---
## 4. Adding a New Route (go_router)

`AppRoutes` (constants):
```dart
// lib/utils/routes.dart
class AppRoutes {
  static const paymentReceipt = '/payment-receipt';
  // ... existing constants
}
```

Register in `AppRouter`:
```dart
// lib/utils/app_router.dart
// Inside children: [] of the appropriate parent, e.g. payments group
GoRoute(
  path: AppRoutes.paymentReceipt.replaceFirst('/',''),
  builder: (ctx, st) => const PaymentReceiptPage(),
),
```

Notes:
- Remove leading `/` when specifying the `path` inside a parent group.
- Use `context.go()` if you want to reset stack (e.g., after login/logout); otherwise `context.push()`.
- For guarded admin screens, the existing `redirect` logic already handles role mismatch.

---
## 5. Modifying / Adding a Navbar

### Bottom Navbar (`AppBottomNav`)
File: `lib/widgets/navigation/app_bottom_nav.dart` (review to adjust items). If adding a tab:
1. Add icon + label in bottom nav widget.
2. Update the index switch logic in pages like `HomeAdminPage` / `HomeOwnerPage` to return proper content.
3. Optionally add a new route if the tab should deep link (advanced: convert to `StatefulShellRoute`).

### Top Navbar (`TopNavbar`)
File: `lib/widgets/navigation/top_navbar.dart`.
To modify actions:
- Add or remove `IconButton` entries in `actions: []`.
- Replace logout logic via:
```dart
await context.read<AuthProvider>().logout();
if (context.mounted) context.go(AppRoutes.login);
```

### Creating a Custom Navbar
Place in `lib/widgets/navigation/`:
```dart
class SectionNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String title; final List<Widget> actions; 
  const SectionNavbar({super.key, required this.title, this.actions = const []});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title), centerTitle: true, actions: actions,
  );
}
```

---
## 6. Using the Auth System

Auth Provider: `lib/providers/auth_provider.dart`

Typical login flow:
```dart
final auth = context.read<AuthProvider>();
final ok = await auth.login(email, password);
if (ok && context.mounted) context.go(AppRoutes.homeForRole(auth.user!.roleName));
```

Check auth state (reactive):
```dart
Consumer<AuthProvider>(
  builder: (_, auth, __) {
    if (auth.status == AuthStatus.loading) return const CircularProgressIndicator();
    if (!auth.isLoggedIn) return const Text('No autenticado');
    return Text('Hola ${auth.user!.name}');
  },
);
```

Logout:
```dart
await context.read<AuthProvider>().logout();
if (context.mounted) context.go(AppRoutes.login);
```

Role home resolution:
```dart
final path = AppRoutes.homeForRole(auth.user!.roleName);
context.go(path);
```

---
## 7. Shared Components & Promotion Rules

Promote a widget to `widgets/common/` if:
- It has no business logic.
- Styling or layout is repeated.
- It will appear in multiple domains (auth, admin, owner, etc.).

Naming conventions:
- Files: `primary_button.dart`, not `PrimaryButton.dart`.
- Public API: Keep constructor parameters required when logically necessary; no heavy defaults.

---
## 8. State Management Pattern

Current state solution: `Provider` + `ChangeNotifier`.

Guidelines:
- Keep network + persistence logic inside a `Service` class (`lib/services/*_service.dart`).
- Have `Provider` call service methods and expose derived values + status enums.
- Use `notifyListeners()` only after state changes.
- For performance, use selectors or smaller widgets instead of rebuilding entire trees.

Example minimal provider snippet:
```dart
class CounterProvider extends ChangeNotifier {
  int _value = 0; int get value => _value;
  void increment() { _value++; notifyListeners(); }
}
```
Registering in `main.dart` (already patterns exist):
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CounterProvider()),
  ],
  child: MyApp(router: AppRouter.createRouter(authProvider)),
);
```

---
## 9. Testing & Debug Tips (Suggested)

Basic widget test skeleton (`test/widget_test.dart` adaptation):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('PrimaryButton renders label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PrimaryButton(label: 'OK', onPressed: null))));
    expect(find.text('OK'), findsOneWidget);
  });
}
```

Navigation redirect test idea:
- Mock `AuthProvider` with `isLoggedIn=false` and pump root -> expect login screen.
- Flip to logged-in & call `router.refresh()` -> expect home route.

Troubleshooting:
- If a redirect loops: ensure you’re not returning the same location; confirm path in `publicRoutes` only when appropriate.
- If UI does not update after login: verify `refreshListenable` is passed to router and `notifyListeners()` is called.

---
## 10. Adding a Form (Pattern)

Structure:
- Form widget with its own `GlobalKey<FormState>`.
- Validation inside `validator:` blocks.
- Submit method returns early if invalid.

Snippet:
```dart
final _formKey = GlobalKey<FormState>();
...
Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
    ElevatedButton(onPressed: () {
      if (_formKey.currentState!.validate()) { /* submit */ }
    }, child: const Text('Guardar')),
  ]),
);
```

---
## 11. Performance Considerations
- Prefer const constructors where possible.
- Extract large build branches into separate widgets to reduce rebuild scope.
- Avoid unnecessary `listen:true` provider lookups when only invoking actions (use `read`).

---
## 12. Implementation Checklist

When adding a new screen WITH routing:
- [ ] Create screen file under correct domain folder.
- [ ] Add route constant to `AppRoutes`.
- [ ] Add route entry in `app_router.dart`.
- [ ] If publicly reachable while logged out, add to `publicRoutes`.
- [ ] Navigate using `context.push/go` from invoking widget.
- [ ] Add basic test (optional but recommended).

When adding a shared widget:
- [ ] Place in `widgets/common/`.
- [ ] Keep it stateless unless internal state is required.
- [ ] Document purpose briefly in a header comment.
- [ ] Use project color tokens (`AppColors`).

When touching auth-related flows:
- [ ] Leverage `AuthProvider` methods (no direct service calls in UI).
- [ ] After login/logout always decide between `go` (replace) vs `push` (stack).
- [ ] Confirm role redirect via `homeForRole()`.

---
## 13. FAQ
**Q: How do I force a manual redirect reevaluation?**  
A: Update auth state (e.g., login/logout) — `GoRouter` listens to `AuthProvider`.

**Q: Where do role-based guard changes go?**  
A: Inside the `redirect:` callback in `AppRouter.createRouter`.

**Q: How do I add a bottom nav tab with its own state?**  
A: Simple: extend current index switch. Advanced (persistent state): migrate to `StatefulShellRoute`.

**Q: How to deep link to a nested route?**  
A: Ensure the path is registered; just call `context.go('/home-admin/detail')` or open via deep link on supported platforms.

---
## 14. Future Enhancements (Roadmap Seeds)
- Consider `StatefulShellRoute` for bottom nav index preservation across navigation.
- Introduce typed route helpers or code generation (e.g., `go_router_builder`).
- Wrap service calls with a lightweight repository layer for testability.
- Add error boundary / global snackbar service.

---
**End of Guide** – Keep this file updated when adding architectural patterns.
