import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/video_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final video = context.watch<VideoSettingsProvider>();
    return Scaffold(appBar: AppBar(title: const Text('الإعدادات')), body: ListView(padding: const EdgeInsets.fromLTRB(12, 10, 12, 28), children: [
      _header(context),
      _section('المظهر'),
      Card(child: ListTile(leading: const Icon(Icons.palette_outlined, color: AppColors.primary), title: const Text('مظهر التطبيق'), subtitle: Text(_themeLabel(theme.mode)), trailing: const Icon(Icons.chevron_left), onTap: () => _themePicker(context, theme))),
      _section('تشغيل الفيديو'),
      Card(child: Column(children: [
        _switch(Icons.play_circle_outline, 'التشغيل التلقائي', 'تشغيل الفيديو مباشرة', video.autoplay, video.setAutoplay),
        _switch(Icons.volume_off_outlined, 'كتم الصوت افتراضيًا', 'ابدأ الفيديو صامتًا', video.muted, video.setMuted),
        _switch(Icons.repeat_rounded, 'التكرار', 'إعادة الفيديو عند الانتهاء', video.loop, video.setLoop),
        _switch(Icons.gesture_rounded, 'إيماءات التحكم', 'النقر والسحب للتحكم', video.gesturesEnabled, video.setGesturesEnabled),
        _switch(Icons.notifications_active_outlined, 'إشعارات الوسائط', 'التحكم من الإشعارات', video.mediaNotifications, video.setMediaNotifications),
        _switch(Icons.brightness_5_outlined, 'إبقاء الشاشة مضاءة', 'أثناء المشاهدة', video.keepScreenAwake, video.setKeepScreenAwake),
        ListTile(leading: const Icon(Icons.speed, color: AppColors.primary), title: const Text('سرعة التشغيل'), subtitle: Text('${video.playbackSpeed}x'), trailing: const Icon(Icons.chevron_left), onTap: () => _speedPicker(context, video)),
        ListTile(leading: const Icon(Icons.aspect_ratio_outlined, color: AppColors.primary), title: const Text('طريقة العرض'), subtitle: Text(_fitLabel(video.fitMode)), trailing: const Icon(Icons.chevron_left), onTap: () => _fitPicker(context, video)),
      ])),
      _section('الأداء'),
      Card(child: Column(children: [
        const ListTile(leading: Icon(Icons.video_settings_outlined, color: AppColors.primary), title: Text('مشغل الفيديو المستقر'), subtitle: Text('video_player مع مسار Android الأصلي')), 
        const ListTile(leading: Icon(Icons.image_outlined, color: AppColors.primary), title: Text('تحميل الصور المصغرة'), subtitle: Text('ذاكرة مؤقتة للمعاينات المحلية')), 
      ])),
      _section('التطبيق'),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary), title: const Text('الخصوصية'), trailing: const Icon(Icons.chevron_left), onTap: () => _info(context, 'الخصوصية', 'يستخدم TikVply صلاحيات الوسائط لعرض فيديوهات الجهاز. حذف عنصر من مكتبة TikVply لا يحذف الملف الأصلي من الهاتف.')),
        ListTile(leading: const Icon(Icons.info_outline, color: AppColors.primary), title: const Text('حول TikVply'), subtitle: const Text('مشغل فيديو اجتماعي'), trailing: const Icon(Icons.chevron_left), onTap: () => _info(context, 'TikVply', 'الإصدار 1.1.0 • مشغل فيديو لاكتشاف وتشغيل الوسائط.')),
        ListTile(leading: const Icon(Icons.restore_outlined, color: AppColors.primary), title: const Text('إعادة إعدادات المشغل'), onTap: () => _reset(context, video)),
      ])),
    ]));
  }
  Widget _header(BuildContext c) => Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 10), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 27)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('إعدادات TikVply', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), Text('تحكم كامل بالمظهر والمشاهدة', style: TextStyle(color: Colors.grey))]))]));
  Widget _section(String text) => Padding(padding: const EdgeInsets.fromLTRB(8, 18, 8, 7), child: Text(text, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)));
  Widget _switch(IconData icon, String title, String sub, bool value, ValueChanged<bool> fn) => SwitchListTile.adaptive(secondary: Icon(icon, color: AppColors.primary), title: Text(title), subtitle: Text(sub), value: value, onChanged: fn);
  String _themeLabel(AppThemeMode mode) => switch (mode) { AppThemeMode.system => 'حسب الهاتف', AppThemeMode.light => 'فاتح', AppThemeMode.dark => 'داكن' };
  IconData _themeIcon(AppThemeMode mode) => switch (mode) { AppThemeMode.system => Icons.brightness_auto_outlined, AppThemeMode.light => Icons.light_mode_outlined, AppThemeMode.dark => Icons.dark_mode_outlined };
  void _themePicker(BuildContext c, ThemeProvider t) => showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('مظهر التطبيق', style: TextStyle(fontWeight: FontWeight.w800))), for (final m in AppThemeMode.values) RadioListTile<AppThemeMode>(value: m, groupValue: t.mode, title: Text(_themeLabel(m)), secondary: Icon(_themeIcon(m)), onChanged: (v) { if (v != null) { t.setMode(v); Navigator.pop(c); } }), const SizedBox(height: 8)])));
  void _speedPicker(BuildContext c, VideoSettingsProvider v) => showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('سرعة التشغيل', style: TextStyle(fontWeight: FontWeight.w800))), for (final s in [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0]) ListTile(title: Text('${s}x'), trailing: v.playbackSpeed == s ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { v.setPlaybackSpeed(s); Navigator.pop(c); }), const SizedBox(height: 8)])));
  void _fitPicker(BuildContext c, VideoSettingsProvider v) { final o = <VideoFitMode, String>{VideoFitMode.cover: 'ملء الشاشة', VideoFitMode.contain: 'احتواء كامل', VideoFitMode.fill: 'تمديد'}; showModalBottomSheet<void>(context: c, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const ListTile(title: Text('طريقة عرض الفيديو', style: TextStyle(fontWeight: FontWeight.w800))), ...o.entries.map((e) => ListTile(title: Text(e.value), trailing: v.fitMode == e.key ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { v.setFitMode(e.key); Navigator.pop(c); })), const SizedBox(height: 8)]))); }
  String _fitLabel(VideoFitMode m) => switch (m) { VideoFitMode.cover => 'ملء الشاشة', VideoFitMode.contain => 'احتواء كامل', VideoFitMode.fill => 'تمديد' };
  Future<void> _reset(BuildContext c, VideoSettingsProvider v) async { final ok = await showDialog<bool>(context: c, builder: (_) => AlertDialog(title: const Text('إعادة الإعدادات؟'), content: const Text('سيتم إرجاع إعدادات الفيديو إلى القيم الافتراضية.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('إعادة'))])); if (ok == true) { await v.reset(); if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('تمت إعادة الإعدادات'))); } }
  void _info(BuildContext c, String title, String text) => showDialog<void>(context: c, builder: (_) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('حسنًا'))]));
}
