import '../user/user_model.dart';

class LiveComment {
  final String id;
  final String streamId;
  final String userId;
  final UserModel? user;
  final String content;
  final DateTime createdAt;

  LiveComment({
    required this.id,
    required this.streamId,
    required this.userId,
    this.user,
    required this.content,
    required this.createdAt,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: json['id'] ?? '',
      streamId: json['stream_id'] ?? '',
      userId: json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stream_id': streamId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
