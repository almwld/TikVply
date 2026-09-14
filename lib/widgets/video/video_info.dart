import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/time_utils.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../screens/profile/profile_screen.dart';

class VideoInfo extends StatelessWidget {
  final VideoModel video;

  const VideoInfo({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final userId = video.user?.id;
            if (userId != null && userId.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserProfileScreen(userId: userId)));
            }
          },
          child: Row(
            children: [
              Flexible(child: Text('@${video.user?.username ?? 'unknown'}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]))),
              if (video.user?.isVerified == true) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: AppColors.primary, size: 16),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<VideoProvider>().followUserForVideo(video.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: video.isFollowing ? AppColors.primary.withValues(alpha: .28) : Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(12)),
                  child: Text(video.isFollowing ? 'متابَع' : 'متابعة', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(video.caption ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
        const SizedBox(height: 8),
        if (video.hashtags.isNotEmpty)
          Wrap(spacing: 4, runSpacing: 4, children: video.hashtags.take(5).map((tag) => Text('#$tag ', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]))).toList()),
        const SizedBox(height: 8),
        if (video.sound != null)
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الصوت: ${video.sound!.title}'))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.music_note, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Flexible(child: Text('${video.sound!.title} - ${video.sound!.artist}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]))),
            ]),
          ),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.visibility, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text('${video.formatViews()} views', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 12),
          Text(TimeUtils.timeAgo(video.createdAt), style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ],
    );
  }
}
