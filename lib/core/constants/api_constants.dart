class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.vidhorus.com';

  // API Endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String refreshToken = '$auth/refresh';

  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String userFollow = '/users/follow';
  static const String userUnfollow = '/users/unfollow';
  static const String userFollowers = '/users/followers';
  static const String userFollowing = '/users/following';

  static const String videos = '/videos';
  static const String videoUpload = '$videos/upload';
  static const String videoLike = '$videos/like';
  static const String videoUnlike = '$videos/unlike';
  static const String videoComment = '$videos/comment';
  static const String videoShare = '$videos/share';
  static const String videoReport = '$videos/report';
  static const String videoTrending = '$videos/trending';
  static const String videoForYou = '$videos/for-you';
  static const String videoFollowing = '$videos/following';

  static const String feed = '/feed';
  static const String feedForYou = '$feed/for-you';
  static const String feedTrending = '$feed/trending';
  static const String feedFollowing = '$feed/following';
  static const String feedNearby = '$feed/nearby';

  static const String search = '/search';
  static const String searchUsers = '$search/users';
  static const String searchVideos = '$search/videos';
  static const String searchMusic = '$search/music';
  static const String searchHashtags = '$search/hashtags';

  static const String music = '/music';
  static const String musicLibrary = '$music/library';
  static const String musicTrending = '$music/trending';

  static const String live = '/live';
  static const String liveStart = '$live/start';
  static const String liveEnd = '$live/end';
  static const String liveJoin = '$live/join';

  static const String notifications = '/notifications';
  static const String notificationsRead = '$notifications/read';

  static const String chat = '/chat';
  static const String chatMessages = '$chat/messages';
  static const String chatSend = '$chat/send';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
