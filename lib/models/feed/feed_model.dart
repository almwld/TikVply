import '../video/video_model.dart';

class FeedModel {
  final String id;
  final FeedType type;
  final VideoModel? video;
  final String? adsId;
  final bool isSponsored;
  final DateTime createdAt;

  FeedModel({
    required this.id,
    required this.type,
    this.video,
    this.adsId,
    this.isSponsored = false,
    required this.createdAt,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json['id'] ?? '',
      type: FeedType.fromString(json['type'] ?? 'video'),
      video: json['video'] != null ? VideoModel.fromJson(json['video']) : null,
      adsId: json['ads_id'],
      isSponsored: json['is_sponsored'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'video': video?.toJson(),
      'ads_id': adsId,
      'is_sponsored': isSponsored,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum FeedType {
  video,
  ads,
  suggested;

  String get value {
    switch (this) {
      case FeedType.video:
        return 'video';
      case FeedType.ads:
        return 'ads';
      case FeedType.suggested:
        return 'suggested';
    }
  }

  static FeedType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'video':
        return FeedType.video;
      case 'ads':
        return FeedType.ads;
      case 'suggested':
        return FeedType.suggested;
      default:
        return FeedType.video;
    }
  }
}
