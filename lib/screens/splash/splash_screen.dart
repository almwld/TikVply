import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0, .6, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: .5, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, .7, curve: Curves.easeOutBack)));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.main);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.dark, AppColors.primary, AppColors.secondary]),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 10))]),
                      child: SvgPicture.asset('assets/icons/svg/tikvply_logo.svg'),
                    ),
                    const SizedBox(height: 26),
                    const Text('TikVply', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 7),
                    Text('مشغل الوسائط الذكي', style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: .82))),
                    const SizedBox(height: 42),
                    SizedBox(width: 34, height: 34, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: .8)), strokeWidth: 3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
