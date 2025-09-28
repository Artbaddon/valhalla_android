import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/routes.dart';

enum UserRole { admin, security, owner }

class RoleNavigationConfig {
  const RoleNavigationConfig({
    required this.homeRoute,
    required this.allowedRoutes,
    required this.navItems,
    required this.profilePage,
  });

  final String homeRoute;
  final List<String> allowedRoutes;
  final List<NavItem> navItems;
  final String profilePage;
}

class NavItem {
  const NavItem({required this.label, required this.icon, required this.route});

  final String label;
  final IconData icon;
  final String route;
}

enum _NavKey { parking, reservations, payments, visitors, packages }

const Map<_NavKey, NavItem> _navLibrary = {
  _NavKey.parking: NavItem(
    label: 'Parking',
    icon: CupertinoIcons.car,
    route: AppRoutes.parkingHome,
  ),
  _NavKey.reservations: NavItem(
    label: 'Reservations',
    icon: CupertinoIcons.calendar,
    route: AppRoutes.reservationsHome,
  ),
  _NavKey.payments: NavItem(
    label: 'Payments',
    icon: CupertinoIcons.money_dollar,
    route: AppRoutes.paymentsHome,
  ),
  _NavKey.visitors: NavItem(
    label: 'Visitors',
    icon: CupertinoIcons.group,
    route: AppRoutes.visitorsHome,
  ),
  _NavKey.packages: NavItem(
    label: 'Packages',
    icon: CupertinoIcons.cube_box,
    route: AppRoutes.packagesHome,
  ),
};

RoleNavigationConfig _buildConfig(
  UserRole role,
  List<_NavKey> navKeys, {
  List<String> extraAllowed = const [],
}) {
  final homeRoute = AppRoutes.homeForRole(role.name);
  final featureItems = navKeys.map((key) => _navLibrary[key]!).toList(growable: false);
  final navItems = <NavItem>[
    NavItem(
      label: 'Inicio',
      icon: CupertinoIcons.house_fill,
      route: homeRoute,
    ),
    ...featureItems,
    NavItem(
      label: 'Perfil',
      icon: CupertinoIcons.person_2,
      route: AppRoutes.profilePage,
    ),
  ];

  final allowedRoutes = {
    homeRoute,
    AppRoutes.profilePage,
    for (final item in featureItems) item.route,
    ...extraAllowed,
  }.toList(growable: false);

  return RoleNavigationConfig(
    homeRoute: homeRoute,
    profilePage: AppRoutes.profilePage,
    allowedRoutes: allowedRoutes,
    navItems: navItems,
  );
}

final roleNavigation = {
  UserRole.owner: _buildConfig(
    UserRole.owner,
    const [
      _NavKey.parking,
      _NavKey.reservations,
      _NavKey.payments,
      _NavKey.packages,
    ],
    extraAllowed: const [
      AppRoutes.changePassword,
      AppRoutes.reservationsHome,
      AppRoutes.reservationForm,
      AppRoutes.paymentsHome,
      AppRoutes.paymentMethods,
      AppRoutes.paymentMethodForm,
      AppRoutes.paymentHistory,
      AppRoutes.packagesHome,
      AppRoutes.packageForm,
    ],
  ),
  UserRole.admin: _buildConfig(
    UserRole.admin,
    const [
      _NavKey.parking,
      _NavKey.reservations,
      _NavKey.payments,
      _NavKey.visitors,
      _NavKey.packages,
    ],
    extraAllowed: const [
      AppRoutes.changePassword,
      AppRoutes.parkingHome,
      AppRoutes.reservationsHome,
      AppRoutes.reservationForm,
      AppRoutes.paymentsHome,
      AppRoutes.paymentMethods,
      AppRoutes.paymentMethodForm,
      AppRoutes.paymentHistory,
      AppRoutes.visitorsHome,
      AppRoutes.visitorForm,
      AppRoutes.packagesHome,
      AppRoutes.packageForm,
    ],
  ),
  UserRole.security: _buildConfig(
    UserRole.security,
    const [
      _NavKey.parking,
      _NavKey.visitors,
      _NavKey.packages,
    ],
    extraAllowed: const [
      AppRoutes.changePassword,
      AppRoutes.parkingHome,
      AppRoutes.visitorsHome,
      AppRoutes.visitorForm,
      AppRoutes.packagesHome,
      AppRoutes.packageForm,
    ],
  ),
};
