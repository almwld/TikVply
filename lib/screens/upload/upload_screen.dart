import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/feed_provider.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة فيديوهات محلية')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.video_library_rounded, size: 58, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('مكتبتك المحلية', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'اختر فيديو واحدًا أو عدة فيديوهات من جهازك. سيتم حفظ المسارات محليًا وتشغيلها مباشرة بدون رفع أو خادم.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isLoading ? null : () async {
                  await provider.importVideos();
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add_to_photos_rounded),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('اختيار فيديوهات')), 
              ),
            ),
            const SizedBox(height: 12),
            const Text('الملف الأصلي يبقى في جهازك؛ التطبيق لا يحذفه.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
