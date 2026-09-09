import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';

class VideoActions extends StatelessWidget {
  final VideoModel video;

  const VideoActions({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _avatar(),
      const SizedBox(height: 20),
      _action(context, video.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, video.formatLikes(), video.isLiked ? AppColors.secondary : Colors.white, () {
        context.read<VideoProvider>().likeVideo(video.id);
        HapticFeedback.mediumImpact();
      }),
      const SizedBox(height: 17),
      _action(context, video.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, video.isSaved ? 'محفوظ' : 'حفظ', Colors.white, () {
        context.read<VideoProvider>().saveVideo(video.id);
        HapticFeedback.selectionClick();
      }),
      const SizedBox(height: 17),
      _action(context, Icons.ios_share_rounded, video.formatShares(), Colors.white, () => _share(context)),
      const SizedBox(height: 17),
      _action(context, Icons.delete_outline_rounded, 'حذف', Colors.white, () => _confirmDelete(context)),
    ]);
  }

  Widget _avatar() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: const ClipOval(child: ColoredBox(color: AppColors.primary, child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28))),
      );

  Widget _action(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Column(children: [
              Icon(icon, color: color, size: 33, shadows: const [Shadow(color: Colors.black54, blurRadius: 5)]),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
            ]),
          ),
        ),
      );

  Future<void> _share(BuildContext context) async {
    final provider = context.read<VideoProvider>();
    await provider.shareVideo(video.id);
    final file = File(video.videoUrl);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: video.caption ?? 'فيديو من TikVply');
    } else {
      await Share.share(video.caption ?? 'فيديو من TikVply');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الفيديو؟'),
        content: const Text('سيتم إخفاء الفيديو من مكتبة TikVply. لن يتم حذف الملف الأصلي من جهازك.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<VideoProvider>().removeVideo(video.id);
    }
  }
}
