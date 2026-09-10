// ignore_for_file: deprecated_member_use
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
    final settings = context.watch<VideoSettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section('المظهر'),
        ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('مظهر التطبيق'), subtitle: Text(_themeLabel(theme.mode)), onTap: () => _showThemePicker(context, theme)),
        _section('تشغيل الفيديو'),
        ListTile(leading: const Icon(Icons.speed), title: const Text('سرعة التشغيل'), subtitle: Text('${settings.playbackSpeed}x')),
        SwitchListTile.adaptive(title: const Text('تشغيل تلقائي'), value: settings.autoplay, onChanged: settings.setAutoplay),
        SwitchListTile.adaptive(title: const Text('التكرار'), value: settings.loop, onChanged: settings.setLoop),
        SwitchListTile.adaptive(title: const Text('كتم الصوت افتراضيًا'), value: settings.muted, onChanged: settings.setMuted),
        SwitchListTile.adaptive(title: const Text('إيماءات التحكم'), value: settings.gesturesEnabled, onChanged: settings.setGesturesEnabled),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: settings.reset, icon: const Icon(Icons.restart_alt), label: const Text('إعادة إعدادات الفيديو')),
      ]),
    );
  }

  Widget _section(String text) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 6), child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)));

  void _showThemePicker(BuildContext context, ThemeProvider theme) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.fromLTRB(20, 4, 20, 10), child: Align(alignment: Alignment.centerRight, child: Text('مظهر التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
      for (final item in AppThemeMode.values)
        RadioListTile<AppThemeMode>(value: item, groupValue: theme.mode, title: Text(_themeLabel(item)), secondary: Icon(_themeIcon(item)), onChanged: (value) { if (value != null) { theme.setMode(value); Navigator.pop(context); } }),
      const SizedBox(height: 8),
    ])));
  }

  IconData _themeIcon(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => Icons.brightness_auto_outlined,
    AppThemeMode.light => Icons.light_mode_outlined,
    AppThemeMode.dark => Icons.dark_mode_outlined,
  };

  String _themeLabel(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => 'النظام',
    AppThemeMode.light => 'فاتح',
    AppThemeMode.dark => 'داكن',
  };
}
