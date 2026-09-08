class VideoConstants {
  // Video Constraints
  static const int minVideoDurationSeconds = 3;
  static const int maxShortVideoDurationSeconds = 60;
  static const int maxLongVideoDurationSeconds = 600; // 10 minutes
  static const int defaultVideoDurationSeconds = 15;

  // Video Quality
  static const String quality1080p = '1080p';
  static const String quality720p = '720p';
  static const String quality480p = '480p';
  static const String quality360p = '360p';
  static const String qualityAuto = 'auto';

  // Video Speed
  static const double speedSlow = 0.5;
  static const double speedNormal = 1.0;
  static const double speedFast = 1.5;
  static const double speedFaster = 2.0;

  // Video Format
  static const List<String> supportedFormats = ['mp4', 'mov', 'avi', 'mkv'];
  static const String defaultFormat = 'mp4';

  // Video Aspect Ratio
  static const double portraitAspectRatio = 9 / 16;
  static const double landscapeAspectRatio = 16 / 9;
  static const double squareAspectRatio = 1.0;

  // Compression
  static const int compressionQualityHigh = 90;
  static const int compressionQualityMedium = 70;
  static const int compressionQualityLow = 50;

  // Thumbnail
  static const int thumbnailWidth = 200;
  static const int thumbnailHeight = 356;
  static const int thumbnailQuality = 75;

  // Buffer
  static const Duration bufferDuration = Duration(seconds: 5);
  static const Duration preloadDuration = Duration(seconds: 3);

  // Cache
  static const int maxCachedVideos = 10;
  static const int maxCacheSizeMB = 500;

  // Gesture Thresholds
  static const double swipeThreshold = 50.0;
  static const double doubleTapThreshold = 200.0;
  static const double longPressThreshold = 500.0;

  // Animation Durations
  static const Duration likeAnimationDuration = Duration(milliseconds: 800);
  static const Duration progressAnimationDuration = Duration(milliseconds: 100);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);
}
