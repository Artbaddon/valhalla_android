import 'package:flutter/cupertino.dart';
import './user_role.dart';

enum NavigationItem {
  dashboard,
  parking,
  reservations,
  payments,
  visitors,
  package,
  profile,
  settings,
  users;

  String get title {
    switch (this) {
      case NavigationItem.dashboard:
        return 'Dashboard';
      case NavigationItem.parking:
        return 'Parking';
      case NavigationItem.reservations:
        return 'Reservations';
      case NavigationItem.payments:
        return 'Payments';
      case NavigationItem.visitors:
        return 'Visitors';
      case NavigationItem.package:
        return 'Packages';
      case NavigationItem.profile:
        return 'Profile';
      case NavigationItem.settings:
        return 'Settings';
      case NavigationItem.users:
        return 'Users';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationItem.dashboard:
        return CupertinoIcons.home;
      case NavigationItem.parking:
        return CupertinoIcons.car;
      case NavigationItem.reservations:
        return CupertinoIcons.calendar;
      case NavigationItem.payments:
        return CupertinoIcons.money_dollar_circle;
      case NavigationItem.visitors:
        return CupertinoIcons.group;
      case NavigationItem.package:
        return CupertinoIcons.cube_box;
      case NavigationItem.profile:
        return CupertinoIcons.person;
      case NavigationItem.settings:
        return CupertinoIcons.settings;
      case NavigationItem.users:
        return CupertinoIcons.group;
    }
  }

  List<UserRole> get allowedRoles {
    switch (this) {
      case NavigationItem.dashboard:
        return [UserRole.admin, UserRole.guard, UserRole.owner];
      case NavigationItem.parking:
        return [UserRole.admin, UserRole.owner, UserRole.guard];
      case NavigationItem.reservations:
        return [UserRole.admin, UserRole.owner];
      case NavigationItem.payments:
        return [UserRole.admin, UserRole.owner];
      case NavigationItem.visitors:
        return [UserRole.admin, UserRole.guard];
      case NavigationItem.package:
        return [UserRole.admin, UserRole.guard, UserRole.owner];
      case NavigationItem.profile:
        return [UserRole.admin, UserRole.guard, UserRole.owner];
      case NavigationItem.settings:
        return [UserRole.admin];
      case NavigationItem.users:
        return [UserRole.admin];
    }
  }

  bool canAccess(UserRole role) {
    return allowedRoles.contains(role);
  }
}
