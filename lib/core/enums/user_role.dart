enum Module { packages, visitors, payments, reservations, parking }

enum UserRole {
  admin,
  guard,
  owner;

  static UserRole fromString(String role) {
    print('Converting role string to UserRole enum: $role');
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'guard':
        return UserRole.guard;
      case 'owner':
        return UserRole.owner;
      default:
        throw Exception('Unknown user role: $role');
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.guard:
        return 'Security Guard';
      case UserRole.owner:
        return 'Client';
    }
  }

  bool get canCreate {
    switch (this) {
      case UserRole.admin:
        return true; // ✅ Admin can create everything
      case UserRole.guard:
        return true; // ✅ Guard can create reports
      case UserRole.owner:
        return false; // ❌ Owner can't create anything
    }
  }

  bool get canEdit {
    switch (this) {
      case UserRole.admin:
        return true; // ✅ Admin can edit everything
      case UserRole.guard:
        return false; // ❌ Guard can't edit (only create reports)
      case UserRole.owner:
        return false; // ❌ Owner can't edit anything
    }
  }

  bool get canDelete {
    switch (this) {
      case UserRole.admin:
        return true; // ✅ Only admin can delete
      case UserRole.guard:
        return false; // ❌
      case UserRole.owner:
        return false; // ❌
    }
  }

  bool get canView {
    return true; // ✅ Everyone can view (but different amounts of data)
  }

  bool get canMonitor {
    switch (this) {
      case UserRole.admin:
        return true; // ✅ Admin monitors everything
      case UserRole.guard:
        return true; // ✅ Guard monitors security
      case UserRole.owner:
        return false; // ❌ Owner just views their own stuff
    }
  }
}
