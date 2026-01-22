import 'package:equatable/equatable.dart';

/// User model with immutable properties
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  });

  /// Create user from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'])
          : json['last_login_at'] != null
              ? DateTime.tryParse(json['last_login_at'])
              : null,
      isEmailVerified: json['isEmailVerified'] ?? json['is_email_verified'] ?? false,
    );
  }

  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Create a copy with updated fields
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  /// Get display name (name or email)
  String get displayName => name ?? email.split('@').first;

  /// Get initials for avatar
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final parts = name!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        createdAt,
        lastLoginAt,
        isEmailVerified,
      ];

  @override
  String toString() => 'AuthUser(id: $id, email: $email, name: $name)';
}