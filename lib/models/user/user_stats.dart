class UserStats {
  final int followersCount;
  final int followingCount;
  final int videosCount;
  final int likesCount;

  UserStats({
    this.followersCount = 0,
    this.followingCount = 0,
    this.videosCount = 0,
    this.likesCount = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      videosCount: json['videos_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers_count': followersCount,
      'following_count': followingCount,
      'videos_count': videosCount,
      'likes_count': likesCount,
    };
  }

  UserStats copyWith({
    int? followersCount,
    int? followingCount,
    int? videosCount,
    int? likesCount,
  }) {
    return UserStats(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      videosCount: videosCount ?? this.videosCount,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  String formatFollowers() {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }

  String formatFollowing() {
    if (followingCount >= 1000000) {
      return '${(followingCount / 1000000).toStringAsFixed(1)}M';
    } else if (followingCount >= 1000) {
      return '${(followingCount / 1000).toStringAsFixed(1)}K';
    }
    return followingCount.toString();
  }

  String formatVideos() {
    if (videosCount >= 1000000) {
      return '${(videosCount / 1000000).toStringAsFixed(1)}M';
    } else if (videosCount >= 1000) {
      return '${(videosCount / 1000).toStringAsFixed(1)}K';
    }
    return videosCount.toString();
  }

  String formatLikes() {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }
}
