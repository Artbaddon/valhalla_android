import '../core/enums/user_role.dart';
import '../core/enums/navigation_item.dart';
import 'route_names.dart';

class NavigationManager {
  static NavigationManager? _instance;

  static NavigationManager get instance =>
      _instance ??= NavigationManager._internal();

  NavigationManager._internal();

  UserRole? _currentUserRole;

  void setUserRole(UserRole role) {
    _currentUserRole = role;
  }

  String getDashboardRoute() {
    switch (_currentUserRole) {
      case UserRole.admin:
        return RouteNames.adminDashboard;
      case UserRole.guard:
        return RouteNames.guardDashboard;
      case UserRole.owner:
        return RouteNames.ownerDashboard;
      default:
        return RouteNames.login; // Fallback to login if role is unknown
    }
  }

  bool canAccesRoute(String route) {
    if (_currentUserRole == null) return false;

    final adminRoutes = {
      RouteNames.profile,
      RouteNames.adminDashboard,
      RouteNames.users,
      RouteNames.reports,
      RouteNames.settings,
      RouteNames.notifications,
      RouteNames.payments,
      RouteNames.reservations,
      RouteNames.parking,
    };

    final guardRoutes = {
      RouteNames.profile,
      RouteNames.guardDashboard,
      RouteNames.monitoring,
      RouteNames.visitors,
      RouteNames.packages,
    };

    final ownerRoutes = {
      RouteNames.profile,
      RouteNames.ownerDashboard,
      RouteNames.payments,
      RouteNames.reservations,
      RouteNames.parking,
      RouteNames.notifications,
      RouteNames.packages,
    };

    switch (_currentUserRole) {
      case UserRole.admin:
        return adminRoutes.contains(route);
      case UserRole.guard:
        return guardRoutes.contains(route);
      case UserRole.owner:
        return ownerRoutes.contains(route);
      default:
        return false;
    }
  }

  List<NavigationItem> getNavigationItems() {
    if (_currentUserRole == null) return [];

    return NavigationItem.values
        .where((item) => item.canAccess(_currentUserRole!))
        .toList();
  }

  String getRouteForNavigationItem(NavigationItem item) {
    switch (item) {
      case NavigationItem.dashboard:
        return getDashboardRoute();
      case NavigationItem.parking:
        return RouteNames.parking;
      case NavigationItem.reservations:
        return RouteNames.reservations;
      case NavigationItem.payments:
        return RouteNames.payments;
      case NavigationItem.visitors:
        return RouteNames.visitors;
      case NavigationItem.package:
        return RouteNames.packages;
      case NavigationItem.profile:
        return RouteNames.profile;
      case NavigationItem.settings:
        return RouteNames.settings;
      case NavigationItem.users:
        return RouteNames.users;
    }
  }
}
