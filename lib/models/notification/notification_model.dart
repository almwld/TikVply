import '../user/user_model.dart';

class NotificationModel {
  final String id;
  final String oderId;
  final UserModel? user;
  final NotificationType type;
  final String? videoId;
  final String? commentId;
  final String? streamId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.oderId,
    this.user,
    required this.type,
    this.videoId,
    this.commentId,
    this.streamId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      oderId: json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      type: NotificationType.fromString(json['type'] ?? 'like'),
      videoId: json['video_id'],
      commentId: json['comment_id'],
      streamId: json['stream_id'],
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': oderId,
      'type': type.value,
      'video_id': videoId,
      'comment_id': commentId,
      'stream_id': streamId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    NotificationType? type,
    String? videoId,
    String? commentId,
    String? streamId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      oderId: userId ?? this.oderId,
      user: user ?? this.user,
      type: type ?? this.type,
      videoId: videoId ?? this.videoId,
      commentId: commentId ?? this.commentId,
      streamId: streamId ?? this.streamId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  share,
  live,
  gift,
  system;

  String get value {
    switch (this) {
      case NotificationType.like:
        return 'like';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.mention:
        return 'mention';
      case NotificationType.share:
        return 'share';
      case NotificationType.live:
        return 'live';
      case NotificationType.gift:
        return 'gift';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'share':
        return NotificationType.share;
      case 'live':
        return NotificationType.live;
      case 'gift':
        return NotificationType.gift;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.like;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.like:
        return 'Liked your video';
      case NotificationType.comment:
        return 'Commented on your video';
      case NotificationType.follow:
        return 'Started following you';
      case NotificationType.mention:
        return 'Mentioned you';
      case NotificationType.share:
        return 'Shared your video';
      case NotificationType.live:
        return 'Started a live stream';
      case NotificationType.gift:
        return 'Sent you a gift';
      case NotificationType.system:
        return 'System notification';
    }
  }
}
