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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const VidHorusApp());
}

class VidHorusApp extends StatelessWidget {
  const VidHorusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => VideoSettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Vid Horus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: DarkTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => _getPage(settings.name),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  Widget _getPage(String? routeName) {
    switch (routeName) {
      case AppRoutes.splash:
        return const SplashScreen();
      case AppRoutes.main:
      default:
        return const MainScreen();
    }
  }
}
