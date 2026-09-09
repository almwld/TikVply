import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/feed_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/video_settings_provider.dart';
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
  void dispose() { _pageController.dispose(); super.dispose(); }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaBrowserScreen()));
      return;
    }
    final page = index > 2 ? index - 1 : index;
    setState(() => _currentIndex = page);
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: const [FeedScreen(), SearchScreen(), SizedBox.shrink(), NotificationsScreen(), ProfileScreen()],
    ),
    bottomNavigationBar: _buildBottomNavBar(),
  );

  Widget _buildBottomNavBar() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkBg : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 16, offset: const Offset(0, -5))],
      ),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _navItem(0, Icons.home_rounded, 'الرئيسية'),
          _navItem(1, Icons.search_rounded, 'اكتشف'),
          _centerButton(),
          _navItemWithBadge(3, Icons.notifications_rounded, 'التنبيهات'),
          _navItem(4, Icons.person_rounded, 'الملف'),
        ]),
      )),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: .10) : null, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 25, color: selected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _navItemWithBadge(int index, IconData icon, String label) {
    final count = context.watch<NotificationProvider>().unreadCount;
    final selected = _currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: .10) : null, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(icon, size: 25, color: selected ? AppColors.primary : AppColors.textSecondary),
            if (count > 0) Positioned(right: -8, top: -6, child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            )),
          ]),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _centerButton() => GestureDetector(
    onTap: () => _onTabTapped(2),
    child: Container(width: 54, height: 54, decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .38), blurRadius: 14, offset: const Offset(0, 5))]), child: const Icon(Icons.video_library_rounded, color: Colors.white, size: 29)),
  );
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
  Widget build(BuildContext context) => Consumer<VideoProvider>(
    builder: (context, videos, _) {
      if (videos.isLoading && videos.videos.isEmpty) return const ColoredBox(color: Colors.black, child: Center(child: CircularProgressIndicator()));
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          if (videos.videos.isEmpty) _emptyState(context, videos) else PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(parent: PageScrollPhysics()),
            itemCount: videos.videos.length,
            onPageChanged: videos.setCurrentIndex,
            itemBuilder: (_, index) => VideoPage(key: ValueKey(videos.videos[index].id), video: videos.videos[index]),
          ),
          Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: _topBar(context, videos))),
        ]),
      );
    },
  );

  Widget _topBar(BuildContext context, VideoProvider videos) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
    child: Row(children: [
      IconButton(onPressed: videos.isRefreshing ? null : videos.refreshDeviceVideos, icon: videos.isRefreshing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.sync_rounded, color: Colors.white)),
      const Spacer(),
      _tab(context, 'لك', !_following, () => setState(() => _following = false)),
      const SizedBox(width: 22),
      _tab(context, 'أتابع', _following, () => setState(() => _following = true)),
      const Spacer(),
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaBrowserScreen())), icon: const Icon(Icons.video_library_rounded, color: Colors.white)),
    ]),
  );

  Widget _tab(BuildContext context, String text, bool selected, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Column(children: [
    Text(text, style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
    const SizedBox(height: 5),
    AnimatedContainer(duration: const Duration(milliseconds: 180), width: selected ? 32 : 0, height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
  ]));

  Widget _emptyState(BuildContext context, VideoProvider videos) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.video_library_rounded, color: Colors.white, size: 74),
      const SizedBox(height: 18),
      const Text('مكتبة الفيديو فارغة', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('سيبحث التطبيق تلقائيًا عن جميع فيديوهات الهاتف ويعرضها هنا بدون اختيار الملفات واحدًا واحدًا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
      const SizedBox(height: 26),
      FilledButton.icon(onPressed: videos.refreshDeviceVideos, icon: const Icon(Icons.sync), label: const Text('تحديث مكتبة الهاتف')),
    ],
  ));
}

class _VideoSettingsSheet extends StatelessWidget {
  const _VideoSettingsSheet();
  @override
  Widget build(BuildContext context) => Consumer<VideoSettingsProvider>(
    builder: (context, settings, _) => SafeArea(child: Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4)))),
        const SizedBox(height: 16),
        const Text('إعدادات تشغيل الفيديو', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _sectionTitle('سرعة التشغيل'),
        Wrap(spacing: 8, children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) => ChoiceChip(label: Text('${speed}x'), selected: settings.playbackSpeed == speed, onSelected: (_) => settings.setPlaybackSpeed(speed))).toList()),
        const SizedBox(height: 18),
        _sectionTitle('طريقة ملء الشاشة'),
        SegmentedButton<VideoFitMode>(segments: const [ButtonSegment(value: VideoFitMode.cover, label: Text('ملء'), icon: Icon(Icons.fullscreen)), ButtonSegment(value: VideoFitMode.contain, label: Text('احتواء'), icon: Icon(Icons.fit_screen)), ButtonSegment(value: VideoFitMode.fill, label: Text('تمديد'), icon: Icon(Icons.aspect_ratio))], selected: {settings.fitMode}, onSelectionChanged: (v) => settings.setFitMode(v.first)),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('تشغيل تلقائي'), subtitle: const Text('ابدأ الفيديو عند ظهوره'), value: settings.autoplay, onChanged: settings.setAutoplay),
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('التكرار'), subtitle: const Text('إعادة الفيديو تلقائيًا'), value: settings.loop, onChanged: settings.setLoop),
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('كتم الصوت افتراضيًا'), value: settings.muted, onChanged: settings.setMuted),
        SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('إيماءات التحكم'), subtitle: const Text('النقر، الضغط المطول والسحب'), value: settings.gesturesEnabled, onChanged: settings.setGesturesEnabled),
        Align(alignment: AlignmentDirectional.centerEnd, child: TextButton.icon(onPressed: settings.reset, icon: const Icon(Icons.restart_alt), label: const Text('إعادة الإعدادات'))),
      ])),
    )),
  );
  Widget _sectionTitle(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)));
}
