class User {
  final int id;
  final String username;
  final int statusId;
  final int roleId;
  final String email;
  final String roleName;

  User({
    required this.id,
    required this.username,
    required this.statusId,
    required this.roleId,
    required this.email,
    required this.roleName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      statusId: json['status_id'],
      roleId: json['role_id'],
      email: json['email'],
      roleName: json['Role_name'],
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
