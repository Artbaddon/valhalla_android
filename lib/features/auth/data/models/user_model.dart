import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/enums/user_role.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role; // stored as string in API
  final String roleName;
  final int statusId;
  final int roleId;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.roleName,
    required this.statusId,
    required this.roleId,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['Role_name']?.toString() ?? 'owner',
      roleName: json['Role_name']?.toString() ?? 'Owner',
      statusId: json['status_id']?.toInt() ?? 1,
      roleId: json['role_id']?.toInt() ?? 2,
      isActive: json['isActive'] ?? json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'Role_name': roleName,
      'status_id': statusId,
      'role_id': roleId,
      'isActive': isActive,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      role: UserRole.fromString(role),
      roleName: roleName,
      statusId: statusId,
      roleId: roleId,
      isActive: isActive,
    );
  }
}
