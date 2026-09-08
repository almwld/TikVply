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
      const SizedBox(height: 22),
      _action(context, video.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, video.formatLikes(), video.isLiked ? AppColors.secondary : Colors.white, () {
        context.read<VideoProvider>().likeVideo(video.id);
        HapticFeedback.mediumImpact();
      }),
      const SizedBox(height: 18),
      _action(context, video.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, video.isSaved ? 'محفوظ' : 'حفظ', Colors.white, () {
        context.read<VideoProvider>().saveVideo(video.id);
      }),
      const SizedBox(height: 18),
      _action(context, Icons.ios_share_rounded, video.formatShares(), Colors.white, () => _share(context)),
      const SizedBox(height: 18),
      _action(context, Icons.delete_outline_rounded, 'حذف', Colors.white, () => _confirmDelete(context)),
    ]);
  }

  Widget _avatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: const ClipOval(child: ColoredBox(color: AppColors.primary, child: Icon(Icons.video_library_rounded, color: Colors.white, size: 28))),
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: color, size: 34, shadows: const [Shadow(color: Colors.black54, blurRadius: 5)]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
      ]),
    );
  }

  Future<void> _share(BuildContext context) async {
    final provider = context.read<VideoProvider>();
    await provider.shareVideo(video.id);
    final file = File(video.videoUrl);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: video.caption ?? 'فيديو من Vid Horus');
    } else {
      await Share.share(video.caption ?? 'فيديو من Vid Horus');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الفيديو؟'),
        content: const Text('سيتم إزالة الفيديو من مكتبة Vid Horus. لن يتم حذف الملف الأصلي من جهازك.'),
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
