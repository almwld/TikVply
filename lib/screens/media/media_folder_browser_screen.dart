import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../models/video/video_model.dart';
import '../../services/video_thumbnail_service.dart';
import '../../widgets/app_bar/tikvply_app_bar.dart';
import '../../widgets/video/mx_video_page.dart';

/// MediaStore-backed folder browser. AssetPathEntity maps to real Android
/// MediaStore buckets and exposes nested paths where the platform provides them.
class MediaFolderBrowserScreen extends StatefulWidget {
  const MediaFolderBrowserScreen({super.key});

  @override
  State<MediaFolderBrowserScreen> createState() => _MediaFolderBrowserScreenState();
}

class _MediaFolderBrowserScreenState extends State<MediaFolderBrowserScreen> {
  List<AssetPathEntity> _rootFolders = const [];
  List<AssetPathEntity> _folderStack = [];
  List<AssetPathEntity> _subfolders = const [];
  List<AssetEntity> _assets = const [];
  AssetPathEntity? _allVideosPath;
  bool _loading = true;
  bool _loadingFolder = false;
  String? _error;

  AssetPathEntity? get _currentFolder =>
      _folderStack.isEmpty ? null : _folderStack.last;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth && !permission.hasAccess) {
        throw StateError('يحتاج التطبيق إلى إذن الوصول إلى فيديوهات الهاتف');
      }
      final folders = await PhotoManager.getAssetPathList(
        onlyAll: false,
        hasAll: false,
        type: RequestType.video,
      );
      final allPaths = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.video,
      );
      if (!mounted) return;
      setState(() {
        _rootFolders = folders;
        _allVideosPath = allPaths.isEmpty ? null : allPaths.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openFolder(AssetPathEntity folder) async {
    setState(() {
      _loadingFolder = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _readAssets(folder),
        folder.getSubPathList().catchError((_) => <AssetPathEntity>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _folderStack = [..._folderStack, folder];
        _assets = results[0] as List<AssetEntity>;
        _subfolders = results[1] as List<AssetPathEntity>;
        _loadingFolder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingFolder = false;
      });
    }
  }

  Future<void> _openAllVideos() async {
    final path = _allVideosPath;
    if (path == null) return;
    setState(() {
      _loadingFolder = true;
      _error = null;
    });
    try {
      final assets = await _readAssets(path);
      if (!mounted) return;
      setState(() {
        _folderStack = [path];
        _assets = assets;
        _subfolders = const [];
        _loadingFolder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loadingFolder = false;
      });
    }
  }

  Future<List<AssetEntity>> _readAssets(AssetPathEntity folder) async {
    const pageSize = 100;
    final output = <AssetEntity>[];
    var page = 0;
    while (true) {
      final batch = await folder.getAssetListPaged(page: page, size: pageSize);
      if (batch.isEmpty) break;
      output.addAll(batch);
      if (batch.length < pageSize) break;
      page++;
    }
    return output;
  }

  void _goBack() {
    if (_folderStack.isEmpty) return;
    if (_folderStack.length == 1) {
      setState(() {
        _folderStack = [];
        _assets = const [];
        _subfolders = const [];
      });
      return;
    }
    final parent = _folderStack[_folderStack.length - 2];
    _folderStack = _folderStack.sublist(0, _folderStack.length - 1);
    _openFolder(parent);
  }

  VideoModel _toVideo(AssetEntity asset, String path) {
    final seconds = asset.duration;
    final duration = Duration(seconds: seconds);
    final label = seconds >= 3600
        ? '${seconds ~/ 3600}:${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}'
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return VideoModel(
      id: 'asset_${asset.id}',
      userId: 'local_user',
      videoUrl: path,
      caption: asset.title,
      duration: label,
      quality: 'محلي',
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folder = _currentFolder;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TikVplyAppBar(
          title: folder?.name ?? 'مجلدات الفيديو',
          actions: [
            IconButton(
              tooltip: 'تحديث المجلدات',
              onPressed: _loading ? null : _loadFolders,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorView()
                : folder == null
                    ? _rootView()
                    : _folderView(),
      ),
    );
  }

  Widget _rootView() => RefreshIndicator(
        onRefresh: _loadFolders,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
          ),
          itemCount: _rootFolders.length + (_allVideosPath == null ? 0 : 1),
          itemBuilder: (_, index) {
            if (_allVideosPath != null && index == 0) {
              return _folderTile(
                name: 'كل الفيديوهات',
                subtitle: 'عرض المكتبة كاملة',
                icon: Icons.video_library_rounded,
                onTap: _openAllVideos,
              );
            }
            final folderIndex = index - (_allVideosPath == null ? 0 : 1);
            final item = _rootFolders[folderIndex];
            return FutureBuilder<int>(
              future: item.assetCountAsync,
              builder: (_, snapshot) => _folderTile(
                name: item.name,
                subtitle: '${snapshot.data ?? 0} فيديو',
                icon: Icons.folder_rounded,
                onTap: () => _openFolder(item),
              ),
            );
          },
        ),
      );

  Widget _folderView() {
    if (_loadingFolder) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        ListTile(
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          title: Text(_folderStack.map((item) => item.name).join('  /  '),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${_assets.length} فيديو'),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (_subfolders.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: _subfolders.length,
                    itemBuilder: (_, index) {
                      final child = _subfolders[index];
                      return FutureBuilder<int>(
                        future: child.assetCountAsync,
                        builder: (_, snapshot) => _folderTile(
                          name: child.name,
                          subtitle: '${snapshot.data ?? 0} فيديو',
                          icon: Icons.folder_rounded,
                          onTap: () => _openFolder(child),
                        ),
                      );
                    },
                  ),
                ),
              if (_assets.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(6),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: .72,
                    ),
                    itemCount: _assets.length,
                    itemBuilder: (_, index) => _AssetVideoTile(
                      key: ValueKey(_assets[index].id),
                      asset: _assets[index],
                      onTap: (path) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MxVideoPage(video: _toVideo(_assets[index], path)),
                        ));
                      },
                    ),
                  ),
                ),
              if (_assets.isEmpty && _subfolders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('لا توجد فيديوهات في هذا المجلد')),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _folderTile({
    required String name,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded),
              ],
            ),
          ),
        ),
      );

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_off_outlined, size: 54),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadFolders,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
}

class _AssetVideoTile extends StatefulWidget {
  final AssetEntity asset;
  final ValueChanged<String> onTap;

  const _AssetVideoTile({super.key, required this.asset, required this.onTap});

  @override
  State<_AssetVideoTile> createState() => _AssetVideoTileState();
}

class _AssetVideoTileState extends State<_AssetVideoTile> {
  late final Future<String?> _pathFuture;
  Future<String?> _thumbnail(String path) async {
    final cached = await VideoThumbnailService.instance.getThumbnailPath(path);
    return cached;
  }

  @override
  void initState() {
    super.initState();
    _pathFuture = _resolvePath();
  }

  Future<String?> _resolvePath() async {
    final file = await widget.asset.file ?? await widget.asset.originFile;
    if (file == null || !await file.exists()) return null;
    return file.path;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
        future: _pathFuture,
        builder: (_, pathSnapshot) {
          final path = pathSnapshot.data;
          if (pathSnapshot.connectionState == ConnectionState.waiting) {
            return const ColoredBox(
              color: Color(0xFF101820),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          if (path == null) {
            return const ColoredBox(
              color: Color(0xFF101820),
              child: Center(child: Icon(Icons.video_file_outlined, color: Colors.white70)),
            );
          }
          return FutureBuilder<String?>(
            future: _thumbnail(path),
            builder: (_, thumbnailSnapshot) => InkWell(
              onTap: () => widget.onTap(path),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbnailSnapshot.data != null)
                    Image.file(File(thumbnailSnapshot.data!), fit: BoxFit.cover,
                        cacheWidth: 360, filterQuality: FilterQuality.low)
                  else
                    const ColoredBox(color: Color(0xFF101820)),
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 32),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Text(widget.asset.title ?? 'فيديو',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
