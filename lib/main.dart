import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/upload_provider.dart';
import 'providers/video_settings_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/feed/feed_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/upload/upload_screen.dart';
import 'screens/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: Colors.black, systemNavigationBarIconBrightness: Brightness.light));
  runApp(const VidHorusApp());
}

class VidHorusApp extends StatelessWidget {
  const VidHorusApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(providers: [ChangeNotifierProvider(create: (_) => ThemeProvider()), ChangeNotifierProvider(create: (_) => AuthProvider()), ChangeNotifierProvider(create: (_) => VideoProvider()), ChangeNotifierProvider(create: (_) => VideoSettingsProvider()), ChangeNotifierProvider(create: (_) => NotificationProvider()), ChangeNotifierProvider(create: (_) => UploadProvider())], child: Consumer<ThemeProvider>(builder: (context, theme, _) => MaterialApp(title: 'TikVply', debugShowCheckedModeBanner: false, theme: AppTheme.lightTheme, darkTheme: DarkTheme.darkTheme, themeMode: theme.themeMode, initialRoute: AppRoutes.splash, onGenerateRoute: (settings) => MaterialPageRoute(settings: settings, builder: (_) => _getPage(settings.name, settings.arguments)))));

  Widget _getPage(String? route, Object? args) {
    switch (route) {
      case AppRoutes.splash: return const SplashScreen();
      case AppRoutes.main:
      case AppRoutes.home: return const MainScreen();
      case AppRoutes.feed: return const FeedScreen();
      case AppRoutes.search: return const SearchScreen();
      case AppRoutes.notifications: return const NotificationsScreen();
      case AppRoutes.profile: return const ProfileScreen();
      case AppRoutes.editProfile: return const EditProfileScreen();
      case AppRoutes.upload: return const UploadScreen();
      case AppRoutes.settings: return const SettingsScreen();
      case AppRoutes.userProfile: return UserProfileScreen(userId: args is String ? args : 'unknown');
      default: return const MainScreen();
    }
  }
}
