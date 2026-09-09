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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          _header(context),
          _section(context, 'المظهر'),
          Card(child: ListTile(
            leading: _icon(Icons.palette_outlined),
            title: const Text('مظهر التطبيق'),
            subtitle: Text(_themeLabel(theme.mode)),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => _showThemePicker(context, theme),
          )),

          _section(context, 'تشغيل الفيديو'),
          Card(child: Column(children: [
            _switchTile(context, Icons.play_circle_outline, 'التشغيل التلقائي', 'ابدأ الفيديو تلقائيًا عند فتحه', video.autoplay, video.setAutoplay),
            _switchTile(context, Icons.volume_off_outlined, 'كتم الصوت افتراضيًا', 'ابدأ الفيديو بدون صوت', video.muted, video.setMuted),
            _switchTile(context, Icons.repeat, 'التكرار', 'أعد تشغيل الفيديو عند انتهائه', video.loop, video.setLoop),
            _switchTile(context, Icons.gesture, 'إيماءات التحكم', 'النقر المزدوج والسحب للتحكم', video.gesturesEnabled, video.setGesturesEnabled),
            _switchTile(context, Icons.notifications_active_outlined, 'إشعارات الوسائط', 'أزرار التشغيل من شريط الإشعارات وشاشة القفل', video.mediaNotifications, video.setMediaNotifications),
            _switchTile(context, Icons.brightness_5_outlined, 'إبقاء الشاشة مضاءة', 'لا تطفئ الشاشة أثناء مشاهدة الفيديو', video.keepScreenAwake, video.setKeepScreenAwake),
            ListTile(
              leading: _icon(Icons.speed),
              title: const Text('سرعة التشغيل'),
              subtitle: Text('${video.playbackSpeed}x'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _showSpeed(context, video),
            ),
            ListTile(
              leading: _icon(Icons.aspect_ratio_outlined),
              title: const Text('ملء الشاشة'),
              subtitle: Text(_fitLabel(video.fitMode)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _showFit(context, video),
            ),
          ])),

          _section(context, 'الجودة والأداء'),
          Card(child: Column(children: [
            ListTile(
              leading: _icon(Icons.memory_outlined),
              title: const Text('مشغل الفيديو الأصلي'),
              subtitle: const Text('تسريع عتادي عبر ExoPlayer / AVPlayer'),
              trailing: Icon(Icons.check_circle, color: cs.primary),
            ),
            ListTile(
              leading: _icon(Icons.picture_in_picture_alt_outlined),
              title: const Text('صورة داخل صورة'),
              subtitle: const Text('تابع المشاهدة أثناء استخدام تطبيقات أخرى'),
              trailing: const Icon(Icons.check_circle_outline),
            ),
          ])),

          _section(context, 'التطبيق'),
          Card(child: Column(children: [
            ListTile(
              leading: _icon(Icons.privacy_tip_outlined),
              title: const Text('الخصوصية'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _info(context, 'الخصوصية', 'يتحكم TikVply في المحتوى والإعدادات من داخل التطبيق، ولا يتم تغيير ملفات الفيديو الأصلية عند حذفها من مكتبة التطبيق.'),
            ),
            ListTile(
              leading: _icon(Icons.info_outline),
              title: const Text('حول TikVply'),
              subtitle: const Text('مشغل فيديو اجتماعي حديث'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _info(context, 'TikVply', 'مشغل فيديو حديث لاكتشاف وتشغيل فيديوهات الجهاز والمحتوى المتاح داخل التطبيق.'),
            ),
            ListTile(
              leading: _icon(Icons.restore_outlined),
              title: const Text('إعادة إعدادات المشغل'),
              subtitle: const Text('إرجاع إعدادات الفيديو إلى الوضع الافتراضي'),
              onTap: () => _confirmReset(context, video),
            ),
          ])),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text('TikVply • إعدادات المشغل', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.settings_rounded, color: AppColors.primary)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('إعدادات TikVply', style: Theme.of(context).textTheme.titleLarge),
        Text('تحكم كامل في المظهر وتجربة تشغيل الفيديو', style: Theme.of(context).textTheme.bodySmall),
      ])),
    ]),
  );

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 7),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge),
  );

  Widget _icon(IconData icon) => Icon(icon, color: AppColors.primary);

  Widget _switchTile(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) => SwitchListTile.adaptive(
    secondary: _icon(icon), title: Text(title), subtitle: Text(subtitle), value: value, onChanged: onChanged,
  );

  String _themeLabel(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => 'حسب إعدادات الهاتف',
    AppThemeMode.light => 'الوضع الفاتح',
    AppThemeMode.dark => 'الوضع الليلي',
  };

  void _showThemePicker(BuildContext context, ThemeProvider theme) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 4, 20, 10), child: Align(alignment: Alignment.centerRight, child: Text('مظهر التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        for (final item in AppThemeMode.values)
          RadioListTile<AppThemeMode>(value: item, groupValue: theme.mode, title: Text(_themeLabel(item)), secondary: Icon(_themeIcon(item)), onChanged: (value) { if (value != null) { theme.setMode(value); Navigator.pop(context); } }),
        const SizedBox(height: 8),
      ])),
    );
  }

  IconData _themeIcon(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => Icons.brightness_auto_outlined,
    AppThemeMode.light => Icons.light_mode_outlined,
    AppThemeMode.dark => Icons.dark_mode_outlined,
  };

  void _showSpeed(BuildContext context, VideoSettingsProvider video) {
    const speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('سرعة التشغيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ...speeds.map((speed) => ListTile(title: Text('${speed}x'), trailing: video.playbackSpeed == speed ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { video.setPlaybackSpeed(speed); Navigator.pop(context); })),
        const SizedBox(height: 8),
      ])),
    );
  }

  void _showFit(BuildContext context, VideoSettingsProvider video) {
    final options = <VideoFitMode, String>{VideoFitMode.cover: 'ملء الشاشة (قص الأطراف)', VideoFitMode.contain: 'احتواء كامل (بدون قص)', VideoFitMode.fill: 'تمديد لملء الشاشة'};
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.all(16), child: Text('طريقة عرض الفيديو', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ...options.entries.map((entry) => ListTile(title: Text(entry.value), trailing: video.fitMode == entry.key ? const Icon(Icons.check, color: AppColors.primary) : null, onTap: () { video.setFitMode(entry.key); Navigator.pop(context); })),
      const SizedBox(height: 8),
    ])));
  }

  String _fitLabel(VideoFitMode mode) => switch (mode) { VideoFitMode.cover => 'ملء الشاشة', VideoFitMode.contain => 'احتواء كامل', VideoFitMode.fill => 'تمديد' };

  Future<void> _confirmReset(BuildContext context, VideoSettingsProvider video) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('إعادة الإعدادات؟'), content: const Text('سيتم إرجاع إعدادات تشغيل الفيديو إلى القيم الافتراضية.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إعادة'))]));
    if (ok == true) {
      await video.reset();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إعادة إعدادات المشغل')));
    }
  }

  void _info(BuildContext context, String title, String text) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))]));
}
