import '../../../../core/enums/user_role.dart';

class UserEntity {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String roleName;
  final int statusId;
  final int roleId;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.roleName,
    required this.statusId,
    required this.roleId,
    this.isActive = true,
  });

  UserEntity copyWith({
    String? username,
    String? email,
    UserRole? role,
    String? roleName,
    int? statusId,
    int? roleId,
    bool? isActive,
  }) {
    return UserEntity(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      statusId: statusId ?? this.statusId,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;
  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  // WHY toString? Makes debugging easier - shows readable user info
  @override
  String toString() {
    return 'UserEntity{id: $id, username: $username, email: $email, role: $role}';
  }
}
