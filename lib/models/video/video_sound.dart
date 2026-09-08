class VideoSound {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String? coverUrl;
  final int usageCount;
  final int duration;
  final bool isOriginal;
  final String? originalVideoId;
  final DateTime createdAt;

  VideoSound({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    this.coverUrl,
    this.usageCount = 0,
    this.duration = 0,
    this.isOriginal = false,
    this.originalVideoId,
    required this.createdAt,
  });

  factory VideoSound.fromJson(Map<String, dynamic> json) {
    return VideoSound(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      coverUrl: json['cover_url'],
      usageCount: json['usage_count'] ?? 0,
      duration: json['duration'] ?? 0,
      isOriginal: json['is_original'] ?? false,
      originalVideoId: json['original_video_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'usage_count': usageCount,
      'duration': duration,
      'is_original': isOriginal,
      'original_video_id': originalVideoId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VideoSound copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    String? coverUrl,
    int? usageCount,
    int? duration,
    bool? isOriginal,
    String? originalVideoId,
    DateTime? createdAt,
  }) {
    return VideoSound(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      usageCount: usageCount ?? this.usageCount,
      duration: duration ?? this.duration,
      isOriginal: isOriginal ?? this.isOriginal,
      originalVideoId: originalVideoId ?? this.originalVideoId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String formatDuration() {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String formatUsageCount() {
    if (usageCount >= 1000000) {
      return '${(usageCount / 1000000).toStringAsFixed(1)}M';
    } else if (usageCount >= 1000) {
      return '${(usageCount / 1000).toStringAsFixed(1)}K';
    }
    return usageCount.toString();
  }
}
