import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NavigationUtils {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState!;

  static Future<T?> push<T>(Widget page, {bool replace = false}) {
    if (replace) {
      return navigator.pushReplacement<T>(MaterialPageRoute(builder: (_) => page));
    }
    return navigator.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments }) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments }) {
    return navigator.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  static Future<T?> pushAndRemoveUntil<T>(Widget page, String routeName) {
    return navigator.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => route.settings.name == routeName,
    );
  }

  static void pop<T>([T? result]) {
    navigator.pop<T>(result);
  }

  static void popUntil(String routeName) {
    navigator.popUntil((route) => route.settings.name == routeName);
  }

  static Future<T?> showBottomSheet<T>(Widget child, {bool isScrollControlled = true}) {
    return showModalBottomSheet<T>(
      context: navigator.context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    return showDialog<bool>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(navigator.context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<T?> showLoadingDialog<T>() {
    return showDialog<T>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog() {
    Navigator.pop(navigator.context);
  }
}
