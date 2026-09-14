import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/video_settings_provider.dart';
import '../../widgets/app_bar/tikvply_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final video = context.watch<VideoSettingsProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const TikVplyAppBar(title: 'الإعدادات'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 32),
          children: [
            _header(context),
            _section('المظهر'),
            Card(child: ListTile(
              leading: Icon(theme.isDarkMode ? Icons.dark_mode_outlined : Icons.palette_outlined, color: AppColors.primary),
              title: const Text('مظهر التطبيق'),
              subtitle: Text(_themeLabel(theme.mode)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _themePicker(context, theme),
            )),
            _section('تشغيل الفيديو'),
            Card(child: Column(children: [
              _switch(Icons.play_circle_outline, 'التشغيل التلقائي', 'ابدأ الفيديو تلقائيًا', video.autoplay, video.setAutoplay),
              _switch(Icons.skip_next_rounded, 'الانتقال التلقائي', 'انتقل للفيديو التالي عند انتهاء الحالي', video.autoNext, video.setAutoNext),
              _switch(Icons.volume_off_outlined, 'كتم الصوت افتراضيًا', 'ابدأ الفيديو صامتًا', video.muted, video.setMuted),
              _switch(Icons.repeat_rounded, 'تكرار الفيديو', 'أعد نفس الفيديو عند الانتهاء', video.loop, video.setLoop),
              _switch(Icons.gesture_rounded, 'إيماءات التحكم', 'السحب والتقديم والتحكم بالصوت والسطوع', video.gesturesEnabled, video.setGesturesEnabled),
              _switch(Icons.notifications_active_outlined, 'إشعارات الوسائط', 'التحكم من إشعارات النظام', video.mediaNotifications, video.setMediaNotifications),
              _switch(Icons.brightness_5_outlined, 'إبقاء الشاشة مضاءة', 'أثناء المشاهدة', video.keepScreenAwake, video.setKeepScreenAwake),
              ListTile(leading: const Icon(Icons.speed, color: AppColors.primary), title: const Text('سرعة التشغيل'), subtitle: Text('${video.playbackSpeed}x'), trailing: const Icon(Icons.chevron_left), onTap: () => _speedPicker(context, video)),
              ListTile(leading: const Icon(Icons.fast_forward_rounded, color: AppColors.primary), title: const Text('مقدار التقديم والرجوع'), subtitle: Text('${video.skipSeconds} ثوانٍ'), trailing: const Icon(Icons.chevron_left), onTap: () => _skipPicker(context, video)),
              ListTile(leading: const Icon(Icons.aspect_ratio_outlined, color: AppColors.primary), title: const Text('طريقة العرض'), subtitle: Text(_fitLabel(video.fitMode)), trailing: const Icon(Icons.chevron_left), onTap: () => _fitPicker(context, video)),
            ])),
            _section('المشغل المتقدم'),
            Card(child: const ListTile(
              leading: Icon(Icons.movie_filter_outlined, color: AppColors.primary),
              title: Text('محرك تشغيل واسع الترميزات'),
              subtitle: Text('TikVply يستخدم media_kit/libmpv خلف VideoPlayerController لدعم نطاق أوسع من صيغ وترميزات الفيديو والصوت.'),
            )),
            _section('المكتبة والبيانات'),
            Card(child: Column(children: [
              const ListTile(leading: Icon(Icons.play_circle_outline, color: AppColors.primary), title: Text('استكمال المشاهدة'), subtitle: Text('يحفظ موضع آخر مشاهدة لكل فيديو تلقائيًا.')),
              const ListTile(leading: Icon(Icons.image_outlined, color: AppColors.primary), title: Text('صور الفيديو المصغرة'), subtitle: Text('يتم إنشاء معاينات حقيقية للفيديوهات المحلية وتخزينها مؤقتًا.')),
              const ListTile(leading: Icon(Icons.storage_outlined, color: AppColors.primary), title: Text('مكتبة الهاتف'), subtitle: Text('يُعاد فحص MediaStore عند فتح المكتبة والعودة إليها لضمان ظهور الوسائط الجديدة.')),
            ])),
            _section('التطبيق'),
            Card(child: Column(children: [
              ListTile(leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary), title: const Text('الخصوصية'), trailing: const Icon(Icons.chevron_left), onTap: () => _info(context, 'الخصوصية', 'صلاحية الوسائط تستخدم لعرض ملفات الفيديو التي يسمح بها النظام. حذف العنصر من TikVply لا يحذف الملف الأصلي من الهاتف.')),
              ListTile(leading: const Icon(Icons.info_outline, color: AppColors.primary), title: const Text('حول TikVply'), subtitle: const Text('مشغل فيديو احترافي • الإصدار 1.3.0'), trailing: const Icon(Icons.chevron_left), onTap: () => _info(context, 'TikVply', 'مشغل فيديو لاكتشاف وتشغيل وإدارة الوسائط المحلية.')),
              ListTile(leading: const Icon(Icons.restore_outlined, color: AppColors.primary), title: const Text('إعادة إعدادات المشغل'), onTap: () => _reset(context, video)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext c) => Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 10), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 27)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إعدادات TikVply', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), Text('تحكم فعلي بالمظهر والمشاهدة والأداء', style: TextStyle(color: Colors.grey))]))]));
  Widget _section(String text) => Padding(padding: const EdgeInsets.fromLTRB(8, 18, 8, 7), child: Text(text, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)));
  Widget _switch(IconData icon, String title, String sub, bool value, ValueChanged<bool> fn) => SwitchListTile.adaptive(secondary: Icon(icon, color: AppColors.primary), title: Text(title), subtitle: Text(sub), value: value, onChanged: fn);
  String _themeLabel(AppThemeMode mode) => switch (mode) { AppThemeMode.system => 'حسب الهاتف', AppThemeMode.light => 'فاتح', AppThemeMode.dark => 'داكن' };
  IconData _themeIcon(AppThemeMode mode) => switch (mode) { AppThemeMode.system => Icons.brightness_auto_outlined, AppThemeMode.light => Icons.light_mode_outlined, AppThemeMode.dark => Icons.dark_mode_outlined };

  Future<void> _themePicker(BuildContext c, ThemeProvider t) async => showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('مظهر التطبيق', style: TextStyle(fontWeight: FontWeight.w800))), for (final m in AppThemeMode.values) RadioListTile<AppThemeMode>(value: m, groupValue: t.mode, title: Text(_themeLabel(m)), secondary: Icon(_themeIcon(m)), onChanged: (v) { if (v != null) { t.setMode(v); Navigator.pop(c); } }), const SizedBox(height: 8)])));
  Future<void> _speedPicker(BuildContext c, VideoSettingsProvider v) async => showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('سرعة التشغيل', style: TextStyle(fontWeight: FontWeight.w800))), for (final s in [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.0]) ListTile(title: Text('${s}x'), trailing: v.playbackSpeed == s ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { v.setPlaybackSpeed(s); Navigator.pop(c); }), const SizedBox(height: 8)])));
  Future<void> _skipPicker(BuildContext c, VideoSettingsProvider v) async => showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('مقدار التقديم والرجوع', style: TextStyle(fontWeight: FontWeight.w800))), for (final s in [5, 10, 15, 30, 60]) ListTile(title: Text('$s ثوانٍ'), trailing: v.skipSeconds == s ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { v.setSkipSeconds(s); Navigator.pop(c); }), const SizedBox(height: 8)])));
  void _fitPicker(BuildContext c, VideoSettingsProvider v) { final o = <VideoFitMode, String>{VideoFitMode.cover: 'ملء الشاشة', VideoFitMode.contain: 'احتواء كامل', VideoFitMode.fill: 'تمديد'}; showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('طريقة عرض الفيديو', style: TextStyle(fontWeight: FontWeight.w800))), ...o.entries.map((e) => ListTile(title: Text(e.value), trailing: v.fitMode == e.key ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { v.setFitMode(e.key); Navigator.pop(c); })), const SizedBox(height: 8)]))); }
  String _fitLabel(VideoFitMode m) => switch (m) { VideoFitMode.cover => 'ملء الشاشة', VideoFitMode.contain => 'احتواء كامل', VideoFitMode.fill => 'تمديد' };
  Future<void> _reset(BuildContext c, VideoSettingsProvider v) async { final ok = await showDialog<bool>(context: c, builder: (_) => AlertDialog(title: const Text('إعادة إعدادات المشغل؟'), content: const Text('سيتم إرجاع جميع إعدادات الفيديو إلى القيم الافتراضية.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('إعادة'))])); if (ok == true) { await v.reset(); if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('تمت إعادة الإعدادات'))); } }
  void _info(BuildContext c, String title, String text) => showDialog<void>(context: c, builder: (_) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('حسنًا'))]));
}
