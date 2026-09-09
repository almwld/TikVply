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
    _scaleAnimation = Tween<double>(begin: .86, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, .75, curve: Curves.easeOutCubic)));
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.main);
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: AppColors.primary, systemNavigationBarIconBrightness: Brightness.light));
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A8F83), Color(0xFF08756B), Color(0xFF173A37)]),
        ),
        child: Stack(children: [
          Positioned(top: -90, right: -70, child: _glow(250)),
          Positioned(bottom: -120, left: -90, child: _glow(300)),
          Center(child: FadeTransition(opacity: _fadeAnimation, child: ScaleTransition(scale: _scaleAnimation, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 128, height: 128, padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .24), blurRadius: 30, offset: const Offset(0, 14))]),
              child: ClipRRect(borderRadius: BorderRadius.circular(25), child: SvgPicture.asset('assets/icons/svg/tikvply_logo.svg')),
            ),
            const SizedBox(height: 24),
            const Text('TikVply', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: .2, color: Colors.white)),
            const SizedBox(height: 6),
            Text('مشغل الوسائط الذكي', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: .86))),
            const SizedBox(height: 38),
            SizedBox(width: 30, height: 30, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: .88)), strokeWidth: 2.8)),
          ])))),
        ]),
      ),
    );
  }

  Widget _glow(double size) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: .08)));
}
