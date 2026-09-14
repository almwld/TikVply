import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TikVplyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  const TikVplyAppBar({super.key, required this.title, this.actions, this.showBack = true, this.leading});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light),
      child: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        leading: leading ?? (showBack && canPop ? IconButton(tooltip: 'رجوع', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).maybePop()) : null),
        actions: actions,
      ),
    );
  }
}
