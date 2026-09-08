class UserModel {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final bool isVerified;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.isVerified = false,
    this.isPrivate = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      fullName: json['full_name'],
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      coverUrl: json['cover_url'],
      isVerified: json['is_verified'] ?? false,
      isPrivate: json['is_private'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'is_verified': isVerified,
      'is_private': isPrivate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    bool? isVerified,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
