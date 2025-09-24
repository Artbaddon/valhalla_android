import 'user_model.dart';

class LoginResponse {
  final String token;
  final UserModel user;
  final String role;

  LoginResponse({required this.token, required this.user, required this.role});

  // Convert from API JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      role: json['Role_name'] ?? '',
    );
  }
}
