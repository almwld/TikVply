class VideoView {
  final String id;
  final String videoId;
  final String oderId;
  final DateTime viewedAt;

  VideoView({
    required this.id,
    required this.videoId,
    required this.oderId,
    required this.viewedAt,
  });

  factory VideoView.fromJson(Map<String, dynamic> json) {
    return VideoView(
      id: json['id'] ?? '',
      videoId: json['video_id'] ?? '',
      oderId: json['user_id'] ?? '',
      viewedAt: json['viewed_at'] != null
          ? DateTime.parse(json['viewed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'user_id': oderId,
      'viewed_at': viewedAt.toIso8601String(),
    };
  }
}
