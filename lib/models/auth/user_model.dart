class User {
  final int id;
  final String username;
  final int statusId;
  final int roleId;
  final String? email;
  final String roleName;

  User({
    required this.id,
    required this.username,
    required this.statusId,
    required this.roleId,
    this.email,
    required this.roleName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      statusId: json['status_id'] as int,
      roleId: json['role_id'] as int,
      email: json['email'] as String?,
      roleName: (json['Role_name'] ?? json['role_name']) as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'status_id': statusId,
      'role_id': roleId,
      'email': email,
      'Role_name': roleName,
    };
  }
}
