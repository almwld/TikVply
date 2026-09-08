import '../user/user_model.dart';
import 'video_sound.dart';

class VideoModel {
  final String id;
  final String userId;
  final UserModel? user;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final List<String> hashtags;
  final List<String> mentions;
  final String? soundId;
  final VideoSound? sound;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;
  final String duration;
  final String quality;
  final double aspectRatio;
  final VideoPrivacy privacy;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.userId,
    this.user,
    required this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    this.hashtags = const [],
    this.mentions = const [],
    this.soundId,
    this.sound,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.savesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isFollowing = false,
    this.duration = '0:00',
    this.quality = '720p',
    this.aspectRatio = 9 / 16,
    this.privacy = VideoPrivacy.public,
    required this.createdAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      caption: json['caption'],
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'])
          : [],
      mentions: json['mentions'] != null
          ? List<String>.from(json['mentions'])
          : [],
      soundId: json['sound_id'],
      sound: json['sound'] != null ? VideoSound.fromJson(json['sound']) : null,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      savesCount: json['saves_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      isFollowing: json['is_following'] ?? false,
      duration: json['duration'] ?? '0:00',
      quality: json['quality'] ?? '720p',
      aspectRatio: (json['aspect_ratio'] ?? 9 / 16).toDouble(),
      privacy: VideoPrivacy.fromString(json['privacy'] ?? 'public'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'hashtags': hashtags,
      'mentions': mentions,
      'sound_id': soundId,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'views_count': viewsCount,
      'saves_count': savesCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'is_following': isFollowing,
      'duration': duration,
      'quality': quality,
      'aspect_ratio': aspectRatio,
      'privacy': privacy.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VideoModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    List<String>? hashtags,
    List<String>? mentions,
    String? soundId,
    VideoSound? sound,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    int? savesCount,
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
    String? duration,
    String? quality,
    double? aspectRatio,
    VideoPrivacy? privacy,
    DateTime? createdAt,
  }) {
    return VideoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      soundId: soundId ?? this.soundId,
      sound: sound ?? this.sound,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      savesCount: savesCount ?? this.savesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String formatLikes() {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }

  String formatComments() {
    if (commentsCount >= 1000000) {
      return '${(commentsCount / 1000000).toStringAsFixed(1)}M';
    } else if (commentsCount >= 1000) {
      return '${(commentsCount / 1000).toStringAsFixed(1)}K';
    }
    return commentsCount.toString();
  }

  String formatShares() {
    if (sharesCount >= 1000000) {
      return '${(sharesCount / 1000000).toStringAsFixed(1)}M';
    } else if (sharesCount >= 1000) {
      return '${(sharesCount / 1000).toStringAsFixed(1)}K';
    }
    return sharesCount.toString();
  }

  String formatViews() {
    if (viewsCount >= 1000000) {
      return '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}K';
    }
    return viewsCount.toString();
  }
}

enum VideoPrivacy {
  public,
  followers,
  private;

  String get value {
    switch (this) {
      case VideoPrivacy.public:
        return 'public';
      case VideoPrivacy.followers:
        return 'followers';
      case VideoPrivacy.private:
        return 'private';
    }
  }

  static VideoPrivacy fromString(String value) {
    switch (value.toLowerCase()) {
      case 'public':
        return VideoPrivacy.public;
      case 'followers':
        return VideoPrivacy.followers;
      case 'private':
        return VideoPrivacy.private;
      default:
        return VideoPrivacy.public;
    }
  }

  String get displayName {
    switch (this) {
      case VideoPrivacy.public:
        return 'Public';
      case VideoPrivacy.followers:
        return 'Followers';
      case VideoPrivacy.private:
        return 'Private';
    }
  }
}
