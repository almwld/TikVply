import 'package:flutter/material.dart';
import '../models/notification/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = <NotificationModel>[];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      // The repository currently has no notification API/data source.
      // Keep the state empty instead of displaying fabricated notifications.
      _notifications = <NotificationModel>[];
      _unreadCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
