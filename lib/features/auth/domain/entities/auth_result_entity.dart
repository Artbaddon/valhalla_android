import 'user_entity.dart';

/// Authentication result entity containing user data and token information
class AuthResultEntity {
  final UserEntity user;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthResultEntity({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresAt,
  });

  AuthResultEntity copyWith({
    UserEntity? user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthResultEntity(
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResultEntity &&
        other.user == user &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        token.hashCode ^
        refreshToken.hashCode ^
        expiresAt.hashCode;
  }

  @override
  String toString() {
    return 'AuthResultEntity(user: $user, token: $token, refreshToken: $refreshToken, expiresAt: $expiresAt)';
  }
}