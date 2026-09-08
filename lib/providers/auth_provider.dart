import 'package:flutter/material.dart';
import '../models/user/user_model.dart';
import '../models/user/user_stats.dart';
import '../models/user/user_settings.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserStats _userStats = UserStats();
  UserSettings _userSettings = UserSettings();
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  UserStats get userStats => _userStats;
  UserSettings get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  AuthProvider() {
    _initMockUser();
  }

  void _initMockUser() {
    _currentUser = UserModel(
      id: 'user_001',
      username: 'vidhorus_user',
      email: 'user@vidhorus.com',
      fullName: 'Vid Horus User',
      bio: 'Welcome to Vid Horus! 🎬',
      avatarUrl: 'https://picsum.photos/200',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _userStats = UserStats(
      followersCount: 1234,
      followingCount: 567,
      videosCount: 42,
      likesCount: 8901,
    );
    _isLoggedIn = true;
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String userId) async {
    _userStats = _userStats.copyWith(
      followingCount: _userStats.followingCount + 1,
    );
    notifyListeners();
  }

  Future<void> unfollowUser(String userId) async {
    if (_userStats.followingCount > 0) {
      _userStats = _userStats.copyWith(
        followingCount: _userStats.followingCount - 1,
      );
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
