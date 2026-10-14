import 'user_model.dart';

/// Top-level envelope for authentication responses (Register, Login, Refresh)
class AuthResponseModel {
  final bool success;
  final String message;
  final AuthData data;
  final String? path;

  AuthResponseModel({
    required this.success,
    required this.message,
    required this.data,
    this.path,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: AuthData.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : (json['data'] is Map
                ? Map<String, dynamic>.from(json['data'] as Map)
                : <String, dynamic>{}),
      ),
      path: json['path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
      'path': path,
    };
  }
}

/// Authentication payload containing user info and JWT session tokens
class AuthData {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  final String? refreshExpiresAt;

  AuthData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.refreshExpiresAt,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: UserModel.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : (json['user'] is Map
                ? Map<String, dynamic>.from(json['user'] as Map)
                : <String, dynamic>{}),
      ),
      accessToken: json['accessToken']?.toString() ?? json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      expiresIn: json['expiresIn']?.toString() ?? '',
      refreshExpiresAt: json['refreshExpiresAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'refreshExpiresAt': refreshExpiresAt,
    };
  }
}
