import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/feed_provider.dart';
import '../../providers/notification_provider.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../media/media_browser_screen.dart';
import '../../widgets/video/video_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaBrowserScreen()));
      return;
    }
    final page = index > 2 ? index - 1 : index;
    setState(() => _currentIndex = page);
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            children: const [FeedScreen(), SearchScreen(), SizedBox.shrink(), NotificationsScreen(), ProfileScreen()],
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: dark ? AppColors.darkBg : Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2), child: SizedBox(height: 48, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(0, Icons.home_rounded, 'الرئيسية'),
        _navItem(1, Icons.search_rounded, 'اكتشف'),
        _centerButton(),
        _navItemWithBadge(3, Icons.notifications_rounded, 'التنبيهات'),
        _navItem(4, Icons.person_rounded, 'الملف'),
      ])))),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return InkWell(borderRadius: BorderRadius.circular(9), onTap: () => _onTabTapped(index), child: AnimatedContainer(duration: const Duration(milliseconds: 140), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1), decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: .08) : null, borderRadius: BorderRadius.circular(9)), child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 19, color: selected ? AppColors.primary : AppColors.textSecondary), Text(label, style: TextStyle(fontSize: 7.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary))])));
  }

  Widget _navItemWithBadge(int index, IconData icon, String label) {
    final count = context.watch<NotificationProvider>().unreadCount;
    final selected = _currentIndex == index;
    return InkWell(borderRadius: BorderRadius.circular(9), onTap: () => _onTabTapped(index), child: AnimatedContainer(duration: const Duration(milliseconds: 140), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1), decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: .08) : null, borderRadius: BorderRadius.circular(9)), child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [Stack(clipBehavior: Clip.none, children: [Icon(icon, size: 19, color: selected ? AppColors.primary : AppColors.textSecondary), if (count > 0) Positioned(right: -6, top: -5, child: Container(constraints: const BoxConstraints(minWidth: 13, minHeight: 13), padding: const EdgeInsets.symmetric(horizontal: 2), alignment: Alignment.center, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle), child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold))))]), Text(label, style: TextStyle(fontSize: 7.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary))])));
  }

  Widget _centerButton() => GestureDetector(onTap: () => _onTabTapped(2), child: Container(width: 38, height: 38, decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .28), blurRadius: 8, offset: const Offset(0, 2))]), child: const Icon(Icons.video_library_rounded, color: Colors.white, size: 20)));
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final PageController _controller;
  bool _following = false;
  @override
  void initState() { super.initState(); _controller = PageController(); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(builder: (context, videos, _) {
      if (videos.isLoading && videos.videos.isEmpty) return const ColoredBox(color: Colors.black, child: Center(child: CircularProgressIndicator()));
      return ColoredBox(color: Colors.black, child: Stack(fit: StackFit.expand, children: [
        if (videos.videos.isEmpty) _emptyState(context, videos) else PageView.builder(controller: _controller, scrollDirection: Axis.vertical, physics: const BouncingScrollPhysics(parent: PageScrollPhysics()), itemCount: videos.videos.length, onPageChanged: videos.setCurrentIndex, itemBuilder: (_, i) => VideoPage(key: ValueKey(videos.videos[i].id), video: videos.videos[i])),
        Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: _topBar(context, videos))),
      ]));
    });
  }

  Widget _topBar(BuildContext context, VideoProvider videos) => SizedBox(height: 68, child: Stack(alignment: Alignment.topCenter, children: [
    PositionedDirectional(start: 10, top: 6, child: _topIconButton(tooltip: 'تحديث فيديوهات الهاتف', icon: videos.isRefreshing ? null : Icons.sync_rounded, onPressed: videos.isRefreshing ? null : videos.refreshDeviceVideos, child: videos.isRefreshing ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : null)),
    PositionedDirectional(end: 10, top: 6, child: _topIconButton(tooltip: 'مكتبة الفيديو', icon: Icons.video_library_rounded, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaBrowserScreen())))),
    Center(child: Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .28), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .10))), child: Row(mainAxisSize: MainAxisSize.min, children: [_tab(context, 'لك', !_following, () => setState(() => _following = false)), const SizedBox(width: 2), _tab(context, 'أتابع', _following, () => setState(() => _following = true))]))),
  ]));

  Widget _topIconButton({required String tooltip, required IconData? icon, required VoidCallback? onPressed, Widget? child}) => Tooltip(message: tooltip, child: Material(color: Colors.black.withValues(alpha: .30), shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: onPressed, child: SizedBox(width: 44, height: 44, child: Center(child: child ?? Icon(icon, color: Colors.white, size: 21))))));

  Widget _tab(BuildContext context, String text, bool selected, VoidCallback onTap) => Semantics(button: true, selected: selected, label: selected ? '$text، محدد' : text, child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 180), curve: Curves.easeOut, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7), decoration: BoxDecoration(color: selected ? Colors.white.withValues(alpha: .14) : Colors.transparent, borderRadius: BorderRadius.circular(18)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(text, style: TextStyle(color: Colors.white, fontSize: 15, height: 1.05, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)), const SizedBox(height: 4), AnimatedContainer(duration: const Duration(milliseconds: 180), width: selected ? 26 : 0, height: 2.5, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)))]))));

  Widget _emptyState(BuildContext context, VideoProvider videos) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.video_library_rounded, color: Colors.white, size: 74), const SizedBox(height: 18), const Text('مكتبة الفيديو فارغة', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('سيبحث التطبيق تلقائيًا عن جميع فيديوهات الهاتف ويعرضها هنا بدون اختيار الملفات واحدًا واحدًا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)), const SizedBox(height: 26), FilledButton.icon(onPressed: videos.refreshDeviceVideos, icon: const Icon(Icons.sync), label: const Text('تحديث مكتبة الهاتف'))])));
}
