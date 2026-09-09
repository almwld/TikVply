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
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _section(context, 'المظهر'),
          SwitchListTile.adaptive(
            secondary: Icon(theme.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: AppColors.primary),
            title: const Text('الوضع الداكن'),
            subtitle: Text(theme.isDarkMode ? 'مفعّل' : 'متوقف'),
            value: theme.isDarkMode,
            onChanged: theme.setDarkMode,
          ),
          _section(context, 'الفيديو'),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.play_circle_outline),
            title: const Text('التشغيل التلقائي'),
            value: video.autoplay,
            onChanged: video.setAutoplay,
          ),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.volume_off_outlined),
            title: const Text('كتم الصوت افتراضيًا'),
            value: video.muted,
            onChanged: video.setMuted,
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('سرعة التشغيل'),
            subtitle: Text('${video.playbackSpeed}x'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSpeed(context, video),
          ),
          ListTile(
            leading: const Icon(Icons.gesture),
            title: const Text('إيماءات التحكم'),
            value: video.gesturesEnabled,
            onTap: () => video.setGesturesEnabled(!video.gesturesEnabled),
            trailing: Switch(value: video.gesturesEnabled, onChanged: video.setGesturesEnabled),
          ),
          _section(context, 'الحساب والتطبيق'),
          ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('الخصوصية'), trailing: const Icon(Icons.chevron_right), onTap: () => _info(context, 'الخصوصية', 'تحكم في بياناتك ومحتواك وإعدادات المشاركة.')),
          ListTile(leading: const Icon(Icons.info_outline), title: const Text('حول TikVply'), trailing: const Icon(Icons.chevron_right), onTap: () => _info(context, 'TikVply', 'منصة فيديو اجتماعية حديثة لمشاركة واكتشاف المحتوى.')),
          ListTile(leading: const Icon(Icons.refresh), title: const Text('إعادة إعدادات الفيديو'), onTap: () { video.reset(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إعادة الإعدادات'))); }),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
    child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 13)),
  );

  void _showSpeed(BuildContext context, VideoSettingsProvider video) {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.all(18), child: Text('سرعة التشغيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) => ListTile(title: Text('${s}x'), trailing: video.playbackSpeed == s ? const Icon(Icons.check) : null, onTap: () { video.setPlaybackSpeed(s); Navigator.pop(context); })),
    ])));
  }

  void _info(BuildContext context, String title, String text) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))]));
}
