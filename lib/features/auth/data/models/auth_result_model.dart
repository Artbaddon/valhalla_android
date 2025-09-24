import '../../domain/entities/auth_result_entity.dart';
import 'user_model.dart';

class AuthResultModel {
  final UserModel user;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthResultModel({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresAt,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      token: json['token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString(),
      expiresAt: json['expires_at'] != null 
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  AuthResultEntity toEntity() {
    return AuthResultEntity(
      user: user.toEntity(),
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }
}