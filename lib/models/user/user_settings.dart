class UserSettings {
  final bool isDarkMode;
  final bool isNotificationsEnabled;
  final bool isPrivateAccount;
  final bool isVerifiedAccount;
  final bool allowComments;
  final bool allowDuet;
  final bool allowStitch;
  final String language;
  final String country;
  final String currency;

  UserSettings({
    this.isDarkMode = false,
    this.isNotificationsEnabled = true,
    this.isPrivateAccount = false,
    this.isVerifiedAccount = false,
    this.allowComments = true,
    this.allowDuet = true,
    this.allowStitch = true,
    this.language = 'en',
    this.country = 'US',
    this.currency = 'USD',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isDarkMode: json['is_dark_mode'] ?? false,
      isNotificationsEnabled: json['is_notifications_enabled'] ?? true,
      isPrivateAccount: json['is_private_account'] ?? false,
      isVerifiedAccount: json['is_verified_account'] ?? false,
      allowComments: json['allow_comments'] ?? true,
      allowDuet: json['allow_duet'] ?? true,
      allowStitch: json['allow_stitch'] ?? true,
      language: json['language'] ?? 'en',
      country: json['country'] ?? 'US',
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_dark_mode': isDarkMode,
      'is_notifications_enabled': isNotificationsEnabled,
      'is_private_account': isPrivateAccount,
      'is_verified_account': isVerifiedAccount,
      'allow_comments': allowComments,
      'allow_duet': allowDuet,
      'allow_stitch': allowStitch,
      'language': language,
      'country': country,
      'currency': currency,
    };
  }

  UserSettings copyWith({
    bool? isDarkMode,
    bool? isNotificationsEnabled,
    bool? isPrivateAccount,
    bool? isVerifiedAccount,
    bool? allowComments,
    bool? allowDuet,
    bool? allowStitch,
    String? language,
    String? country,
    String? currency,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isPrivateAccount: isPrivateAccount ?? this.isPrivateAccount,
      isVerifiedAccount: isVerifiedAccount ?? this.isVerifiedAccount,
      allowComments: allowComments ?? this.allowComments,
      allowDuet: allowDuet ?? this.allowDuet,
      allowStitch: allowStitch ?? this.allowStitch,
      language: language ?? this.language,
      country: country ?? this.country,
      currency: currency ?? this.currency,
    );
  }
}
