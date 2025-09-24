# Valhalla Android – Architecture and Development Guide

This guide explains how the app is structured, how navigation works, how MVVM is implemented end-to-end, how authentication flows through the system, how the Notes CRUD example is built, and how to add a brand‑new module following the same patterns.

Use this document as your single source of truth when extending the app.

## TL;DR – Key Concepts

- Architecture: Clean-ish MVVM using layers: `domain` (entities, repositories, usecases), `data` (datasources, repository impls, mappers), `presentation` (pages, viewmodels, widgets).
- State management: `provider` with `ChangeNotifier` viewmodels; dependency injection in `main.dart` via `MultiProvider`.
- Navigation: Centralized, type-safe routes in `navigation/route_names.dart`, runtime router in `navigation/app_router.dart`, plus `NavigationService` with a global `navigatorKey` for non-`BuildContext` navigation. Role-based access via `navigation/guards/auth_guard.dart` and utilities in `navigation/navigation_manager.dart`.
- Networking: `core/network/dio_client.dart` wraps Dio with interceptors (auth header, error mapping). Errors map to typed exceptions defined in `core/errors/exceptions.dart`.
- Storage: `core/services/storage_service.dart` abstracts SharedPreferences and FlutterSecureStorage with JSON helpers.
- Auth: `features/auth` provides DTOs, repository, and `AuthViewModel` that logs in/out, persists tokens, and routes by role.
- Example CRUD: `features/notes` demonstrates full MVVM with an in-memory datasource and a minimal UI for list/create/update/delete.

---

## Project Layout

Top-level highlights relevant to this guide:

- `lib/main.dart` – App bootstrap: DI wiring, `MaterialApp`, `navigatorKey`, and router.
- `lib/navigation/` – All navigation logic and route names.
- `lib/core/` – Cross-cutting concerns: constants, enums, errors, networking client, services, and shared widgets.
- `lib/features/` – Each feature follows the same MVVM folder split: `data`, `domain`, `presentation` (plus `common` when needed).
- `lib/old/` – Legacy code retained for reference. It’s excluded from analysis and not used by the app.

A feature such as Notes follows this pattern:

- `features/notes/domain/entities/note_entity.dart`
- `features/notes/domain/repositories/notes_repository.dart`
- `features/notes/data/datasources/notes_local_datasource.dart`
- `features/notes/data/repositories/notes_repository_impl.dart`
- `features/notes/presentation/viewmodels/notes_viewmodel.dart`
- `features/notes/presentation/pages/notes_pages.dart`

---

## MVVM in This App

MVVM separates responsibilities:

- Model (Domain/Data): Business data structures and operations.
  - Domain layer defines `Entity` types and `Repository` contracts.
  - Data layer implements repositories by talking to datasources (HTTP, local DB, etc.).
- ViewModel (Presentation): Pure Dart classes extending `ChangeNotifier`; hold UI state, expose actions, orchestrate domain calls. No `BuildContext` stored.
- View (Presentation): Flutter Widgets (Pages) that observe the ViewModel via `Consumer`/`Selector`/`context.watch` and render the UI.

Data flow:

1. UI triggers an intent: user taps a button → View calls a method on the ViewModel.
2. ViewModel updates optimistic state (e.g., `isLoading = true`) and calls the Repository.
3. Repository -> Datasource(s) -> Network/Storage → returns data or throws a typed exception.
4. ViewModel captures the result, updates state, and calls `notifyListeners()`.
5. UI rebuilds with new state.

Contracts to keep in mind:

- View never knows implementation details (no direct HTTP/storage calls).
- ViewModel never imports UI libraries (no Widgets in VM); it can request navigation via `NavigationService` or return signals the View reacts to.
- Repositories are injected (constructor) for testability and decoupling.

---

## Navigation System

Navigation is centralized and role-aware.

Core pieces:

- `navigation/route_names.dart` – All route constants (e.g., `RouteNames.login`, `RouteNames.dashboardAdmin`, `RouteNames.notes`). This avoids string typos across the app.
- `navigation/app_router.dart` – The runtime router used by `MaterialApp.onGenerateRoute`. It resolves a `RouteSettings` into a `MaterialPageRoute` with the correct page widget. Also provides a fallback `NotFound` page.
- `navigation/guards/auth_guard.dart` – Contains guard logic to determine if a user can access a route based on auth state and role.
- `navigation/navigation_manager.dart` – Helper for mapping roles to allowed items/routes and deciding the correct dashboard entry point.
- `core/services/navigation_service.dart` – Holds a global `navigatorKey` and convenience methods (`pushNamed`, `replaceToLogin`, `goToDashboardForRole`, etc.). This allows navigation from places where no `BuildContext` is available (e.g., ViewModels, interceptors).

How routing works at runtime:

1. `main.dart` sets `navigatorKey: NavigationService.instance.navigatorKey` on `MaterialApp` and `onGenerateRoute: AppRouter.onGenerateRoute`.
2. When `Navigator.pushNamed(context, RouteNames.notes)` is called (or the `NavigationService` equivalent), Flutter asks `AppRouter` to build the route widget.
3. `AuthGuard` can be consulted by `AppRouter` or by the caller before navigating to ensure the user is authorized to view the page.
4. If unauthorized, the app redirects to `RouteNames.login` or an `Unauthorized` placeholder.
5. Dashboards are role-based: after login, `NavigationService.goToDashboardForRole(role)` picks the right dashboard route.

Why a custom router (and not only go_router)?

- The current setup demonstrates core Flutter navigation concepts and keeps the learning curve approachable. You can migrate to `go_router` later for URL sync, nested routing, and declarative guards. The abstractions (`RouteNames`, guards, `NavigationService`) make that migration straightforward.

---

## Networking and Error Handling

- `core/network/dio_client.dart` centralizes HTTP configuration using Dio.
  - Adds an `Authorization: Bearer <token>` header when a token exists in secure storage.
  - Maps Dio/HTTP errors to typed exceptions from `core/errors/exceptions.dart`.
  - Provides simple helpers for HTTP verbs.
- `core/errors/exceptions.dart` defines app-specific exceptions (e.g., `UnauthorizedException`, `ServerException`, `NetworkException`). ViewModels catch these and update UI state accordingly.

Benefits:

- One place to customize base URL, timeouts, interceptors, and logging.
- Typed errors make downstream handling predictable and less stringly-typed.

---

## Storage and Security

- `core/services/storage_service.dart` wraps SharedPreferences and `FlutterSecureStorage`.
  - Methods like `saveJson<T>()`, `readJson<T>()` help store small JSON values.
  - Access tokens and other secrets live in secure storage only.
- The Auth repository uses this service to persist the token and current user role.

---

## Authentication Flow

Key files:

- `features/auth/domain/entities/user_entity.dart` – Minimal user model for domain use.
- `features/auth/data/models/user_model.dart` – DTO with `fromJson`/`toJson` and mappers to/from `UserEntity`.
- `features/auth/data/datasources/*` – Remote datasource that performs `login()`/`logout()` calls.
- `features/auth/domain/repositories/auth_repository.dart` – Contract for auth operations: `login`, `logout`, `getCurrentUser`, `isAuthenticated`.
- `features/auth/data/repositories/auth_repository_impl.dart` – Implements the repository, communicating with the datasource and storage service.
- `features/auth/presentation/viewmodels/auth_viewmodel.dart` – Exposes `login`, `logout`, loading/error state, and triggers role-based navigation.

Login sequence:

1. View calls `AuthViewModel.login(email, password)`.
2. VM validates inputs (simple checks can happen here or in a usecase), sets `isLoading=true`.
3. VM calls `authRepository.login(...)`.
4. Repository calls the remote datasource; on success, saves the token in secure storage and the role in storage; returns a `UserEntity`.
5. VM stores the user, sets `isLoading=false`, and calls `NavigationService.goToDashboardForRole(user.role)`.
6. On failure, VM captures the `AppException` type, sets `errorMessage`, `isLoading=false`; the View shows an error.

Logout:

- Invoke `AuthViewModel.logout()`. Repository clears the token and user data; the VM redirects to the login route using `NavigationService.replaceToLogin()`.

Splash (optional):

- A splash page can check `authRepository.isAuthenticated()` and route to the correct dashboard or login accordingly.

---

## Notes Feature – Full CRUD Example

The Notes feature demonstrates the full MVVM pipeline with an in-memory local datasource. Swap the datasource for a REST or SQLite implementation without changing UI code.

- Domain entity: `features/notes/domain/entities/note_entity.dart`
  - Immutable data model (id, title, content, timestamps). Use `copyWith()` to update.
- Repository contract: `features/notes/domain/repositories/notes_repository.dart`
  - `getAll()`, `getById(id)`, `create(note)`, `update(note)`, `delete(id)`.
- Datasource: `features/notes/data/datasources/notes_local_datasource.dart`
  - Keeps an in-memory list and simulates async with `Future`.
- Repository impl: `features/notes/data/repositories/notes_repository_impl.dart`
  - Thin wrapper that forwards to the datasource and may add mapping/validation.
- ViewModel: `features/notes/presentation/viewmodels/notes_viewmodel.dart`
  - Holds list of notes, `isLoading`, `errorMessage`. Methods wrap repository calls, update state, and `notifyListeners()`.
- Pages: `features/notes/presentation/pages/notes_pages.dart`
  - List page displays notes and actions to add/edit/delete.
  - Edit page drives a form; on save, calls VM to create or update and pops when done.

UI patterns illustrated:

- Use `context.watch<NotesViewModel>()` for simple rebuilds, or `Consumer`/`Selector` for finer control.
- Guard async navigation with `if (!context.mounted) return;` before calling `Navigator.pop(context)`.
- Keep view logic dumb; business logic resides in the VM and repository.

---

## How to Add a New Module (Full CRUD)

Below is a repeatable recipe you can apply to build a new feature called “Tasks” as an example. Replace names accordingly.

1) Domain layer

- Create entity: `lib/features/tasks/domain/entities/task_entity.dart`

```dart
class TaskEntity {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
    this.updatedAt,
  });

  TaskEntity copyWith({String? title, bool? done, DateTime? updatedAt}) => TaskEntity(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
```

- Define repository contract: `lib/features/tasks/domain/repositories/tasks_repository.dart`

```dart
abstract class TasksRepository {
  Future<List<TaskEntity>> getAll();
  Future<TaskEntity?> getById(String id);
  Future<TaskEntity> create(TaskEntity task);
  Future<TaskEntity> update(TaskEntity task);
  Future<void> delete(String id);
}
```

2) Data layer

- Choose a datasource type:
  - Local (like Notes) at `lib/features/tasks/data/datasources/tasks_local_datasource.dart`
  - Or remote via `DioClient` at `lib/features/tasks/data/datasources/tasks_remote_datasource.dart`

Example local datasource:

```dart
class TasksLocalDataSource {
  final _items = <TaskEntity>[];

  Future<List<TaskEntity>> getAll() async => List.unmodifiable(_items);
  Future<TaskEntity?> getById(String id) async => _items.where((t) => t.id == id).cast<TaskEntity?>().firstOrNull;
  Future<TaskEntity> create(TaskEntity task) async { _items.add(task); return task; }
  Future<TaskEntity> update(TaskEntity task) async {
    final idx = _items.indexWhere((t) => t.id == task.id);
    if (idx == -1) throw Exception('Task not found');
    _items[idx] = task; return task;
  }
  Future<void> delete(String id) async { _items.removeWhere((t) => t.id == id); }
}
```

- Implement repository: `lib/features/tasks/data/repositories/tasks_repository_impl.dart`

```dart
class TasksRepositoryImpl implements TasksRepository {
  final TasksLocalDataSource local;
  TasksRepositoryImpl(this.local);

  @override Future<List<TaskEntity>> getAll() => local.getAll();
  @override Future<TaskEntity?> getById(String id) => local.getById(id);
  @override Future<TaskEntity> create(TaskEntity task) => local.create(task);
  @override Future<TaskEntity> update(TaskEntity task) => local.update(task);
  @override Future<void> delete(String id) => local.delete(id);
}
```

3) Presentation layer

- Create a ViewModel: `lib/features/tasks/presentation/viewmodels/tasks_viewmodel.dart`

```dart
class TasksViewModel extends ChangeNotifier {
  final TasksRepository repo;
  TasksViewModel(this.repo);

  List<TaskEntity> tasks = [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true; error = null; notifyListeners();
    try { tasks = await repo.getAll(); } catch (e) { error = e.toString(); }
    finally { isLoading = false; notifyListeners(); }
  }

  Future<void> add(TaskEntity t) async { await repo.create(t); await load(); }
  Future<void> toggleDone(TaskEntity t) async { await repo.update(t.copyWith(done: !t.done)); await load(); }
  Future<void> remove(String id) async { await repo.delete(id); await load(); }
}
```

- Create pages: `lib/features/tasks/presentation/pages/tasks_pages.dart` (list and edit pages similar to Notes).

- Register routes:
  - Add to `lib/navigation/route_names.dart`:

```dart
class RouteNames {
  // ...existing
  static const tasks = '/tasks';
  static const taskEdit = '/tasks/edit';
}
```

  - Update `lib/navigation/app_router.dart` switch to return your new pages.
  - If you have role restrictions, extend `auth_guard.dart` and `navigation_manager.dart` accordingly.

- Wire providers in `lib/main.dart`:

```dart
MultiProvider(
  providers: [
    // ...existing
    Provider(create: (_) => TasksLocalDataSource()),
    Provider<TasksRepository>(create: (ctx) => TasksRepositoryImpl(ctx.read<TasksLocalDataSource>())),
    ChangeNotifierProvider(create: (ctx) => TasksViewModel(ctx.read<TasksRepository>())),
  ],
  child: const MyApp(),
)
```

- Add navigation UI (e.g., a button in a dashboard or bottom nav item) to call `Navigator.pushNamed(context, RouteNames.tasks)`.

Validation checklist:

- Can list tasks, add a task, edit/toggle, delete, and see state updates without manual refresh.
- Handles loading and error states gracefully.
- Respects role-based access if applicable.

---

## State Management Patterns

- Keep all mutable UI state inside ViewModels. Examples: loading flags, form data (when not ephemeral), current selection, pagination.
- Prefer immutable domain entities and use `copyWith()` for updates.
- Always call `notifyListeners()` after mutating the VM state.
- For async UI navigation after awaits, guard with `if (!context.mounted) return;`.
- For composition, consider smaller VMs per screen over giant feature-wide VMs.

---

## Quality Gates and Tooling

- Analyzer and formatting: enforce clean code. Legacy `lib/old/**` and `build/**` are excluded from analysis to avoid noise.
- Tests: `test/widget_test.dart` contains a smoke test. Add unit tests for ViewModels and repositories as you extend the app.
- Error boundaries: prefer typed exceptions rather than raw strings; surface human-readable messages in ViewModels/Views.

---

## How to Run and Explore

From a terminal in the project root:

```powershell
flutter pub get
flutter run
```

Run tests:

```powershell
flutter test
```

Where to start reading the code:

1. `lib/main.dart` – DI and app bootstrap.
2. `lib/navigation/app_router.dart` and `lib/navigation/route_names.dart` – routing.
3. `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` – login flow.
4. `lib/features/notes/...` – CRUD example.

---

## Migration to go_router (Optional)

If you decide to move to `go_router`:

- Replace `onGenerateRoute` with a `GoRouter` instance and route table.
- Implement guards with `redirect` callbacks using the same authorization logic as `auth_guard.dart`.
- Keep `RouteNames` (or create enum routes) to avoid string literals sprinkled across the code.
- Keep `NavigationService` only for edge cases; prefer context-based `GoRouter` navigation within Widgets.

The current modular structure allows this migration without changing domain/presentation internals.

---

## FAQ

- Why store tokens in secure storage? To protect credentials; SharedPreferences is plain-text.
- Why not keep `BuildContext` in ViewModels? It tightly couples VMs to widget trees and lifecycle. Use `NavigationService` or emit events the UI consumes.
- Why repository interfaces? They enable swapping datasources (local/mock/remote) and keep ViewModels testable.

---

If something in this guide doesn’t match the current code, defer to the structure and intent here and adjust the code accordingly. This document aims to keep the architecture consistent and teach you how to extend the app confidently.
