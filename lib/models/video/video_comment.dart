import '../user/user_model.dart';

class VideoComment {
  final String id;
  final String videoId;
  final String userId;
  final UserModel? user;
  final String content;
  final String? parentId;
  final int likesCount;
  final bool isLiked;
  final int repliesCount;
  final DateTime createdAt;

  VideoComment({
    required this.id,
    required this.videoId,
    required this.userId,
    this.user,
    required this.content,
    this.parentId,
    this.likesCount = 0,
    this.isLiked = false,
    this.repliesCount = 0,
    required this.createdAt,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      id: json['id'] ?? '',
      videoId: json['video_id'] ?? '',
      userId: json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      repliesCount: json['replies_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'replies_count': repliesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VideoComment copyWith({
    String? id,
    String? videoId,
    String? userId,
    UserModel? user,
    String? content,
    String? parentId,
    int? likesCount,
    bool? isLiked,
    int? repliesCount,
    DateTime? createdAt,
  }) {
    return VideoComment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isReply => parentId != null;
}
