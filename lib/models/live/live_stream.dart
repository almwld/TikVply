import '../user/user_model.dart';

class LiveStream {
  final String id;
  final String userId;
  final UserModel? user;
  final String title;
  final String? thumbnailUrl;
  final int viewerCount;
  final int likeCount;
  final int commentCount;
  final bool isLive;
  final DateTime startedAt;
  final DateTime? endedAt;

  LiveStream({
    required this.id,
    required this.userId,
    this.user,
    required this.title,
    this.thumbnailUrl,
    this.viewerCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLive = true,
    required this.startedAt,
    this.endedAt,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      viewerCount: json['viewer_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLive: json['is_live'] ?? true,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'viewer_count': viewerCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_live': isLive,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  LiveStream copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? title,
    String? thumbnailUrl,
    int? viewerCount,
    int? likeCount,
    int? commentCount,
    bool? isLive,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return LiveStream(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      viewerCount: viewerCount ?? this.viewerCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLive: isLive ?? this.isLive,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  String formatViewerCount() {
    if (viewerCount >= 1000000) {
      return '${(viewerCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewerCount >= 1000) {
      return '${(viewerCount / 1000).toStringAsFixed(1)}K';
    }
    return viewerCount.toString();
  }

  Duration get duration {
    DateTime end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  String formatDuration() {
    Duration dur = duration;
    int hours = dur.inHours;
    int minutes = dur.inMinutes.remainder(60);
    int seconds = dur.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
