import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video/video_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/video_settings_provider.dart';
import '../../services/video_playback_state_service.dart';
import 'video_actions.dart';
import 'video_info.dart';

class VideoPage extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onCompleted;
  const VideoPage({super.key, required this.video, this.onCompleted});
  @override State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with WidgetsBindingObserver {
  static const _platform = MethodChannel('com.tikvply/player');
  VideoPlayerController? _controller;
  final VideoPlaybackStateService _playbackState = VideoPlaybackStateService();
  Timer? _saveTimer;
  Timer? _hideControlsTimer;
  Timer? _sleepTimer;
  bool _loading = true, _showControls = true, _showLikeAnimation = false, _fullscreen = false, _completionSent = false;
  bool _locked = false, _inPip = false;
  String? _error;
  Offset _likePosition = Offset.zero;
  Offset? _gestureStart;
  double? _gestureStartBrightness, _gestureStartVolume;
  Duration? _aPoint, _bPoint;
  int? _sleepMinutes;
  VideoSettingsProvider get _settings => context.read<VideoSettingsProvider>();
  bool get _isNetwork => widget.video.videoUrl.startsWith('http://') || widget.video.videoUrl.startsWith('https://');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings.addListener(_applySettings);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final previous = _controller;
    _controller = null;
    _saveTimer?.cancel();
    _completionSent = false;
    _aPoint = null;
    _bPoint = null;
    if (previous != null) {
      previous.removeListener(_playerListener);
      await previous.dispose();
    }
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final source = _isNetwork
          ? VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
          : VideoPlayerController.file(File(widget.video.videoUrl));
      _controller = source;
      source.addListener(_playerListener);
      await source.initialize();
      final value = source.value;
      if (!value.isInitialized || value.duration <= Duration.zero || value.size.width <= 0 || value.size.height <= 0) {
        throw StateError('unsupported or invalid video stream');
      }
      await _applySettings();
      final saved = await _playbackState.loadPosition(widget.video.id);
      if (saved != null && saved > Duration.zero && saved < source.value.duration - const Duration(seconds: 2)) {
        await source.seekTo(saved);
      }
      if (!mounted) return;
      setState(() => _loading = false);
      if (_settings.autoplay) await source.play();
      _startPositionPersistence();
      _scheduleControlsHide();
      final provider = context.read<VideoProvider>();
      await provider.updateVideoMetadata(widget.video.id, duration: source.value.duration, aspectRatio: source.value.aspectRatio);
      await provider.incrementViews(widget.video.id);
    } catch (error, stackTrace) {
      debugPrint('TikVply video initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() { _loading = false; _error = _errorText(error); });
    }
  }

  String _errorText(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('permission') || text.contains('access')) return 'لا يمكن الوصول إلى ملف الفيديو. تحقق من إذن الوسائط.';
    if (text.contains('codec') || text.contains('decoder') || text.contains('format') || text.contains('unsupported') || text.contains('invalid')) return 'صيغة أو ترميز هذا الفيديو غير مدعوم بواسطة محرك Android على هذا الجهاز.';
    return 'تعذر تشغيل الفيديو. أعد المحاولة أو انتقل للفيديو التالي.';
  }

  void _playerListener() {
    final c = _controller;
    if (c == null || !mounted || !c.value.isInitialized) return;
    if (c.value.hasError && _error == null) {
      setState(() { _loading = false; _error = c.value.errorDescription ?? 'تعذر تشغيل الفيديو'; });
      return;
    }
    final duration = c.value.duration;
    if (_aPoint != null && _bPoint != null && c.value.position >= _bPoint! - const Duration(milliseconds: 120)) {
      c.seekTo(_aPoint!);
      return;
    }
    if (!_settings.loop && !_completionSent && duration > Duration.zero && c.value.position >= duration - const Duration(milliseconds: 300)) {
      _completionSent = true;
      _playbackState.clearPosition(widget.video.id);
      widget.onCompleted?.call();
    }
  }

  void _startPositionPersistence() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final c = _controller;
      if (c != null && c.value.isInitialized && c.value.isPlaying) _savePlaybackPosition(c.value.position);
    });
  }

  Future<void> _savePlaybackPosition(Duration position) async {
    try {
      final duration = _controller?.value.duration ?? Duration.zero;
      if (position <= Duration.zero || duration <= Duration.zero || position >= duration) return;
      await _playbackState.savePosition(widget.video.id, position);
    } catch (_) {}
  }

  Future<void> _applySettings() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      await c.setLooping(_settings.loop);
      await c.setVolume(_settings.muted ? 0 : 1);
      await c.setPlaybackSpeed(_settings.playbackSpeed);
      if (_settings.keepScreenAwake && c.value.isPlaying) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (e) {
      debugPrint('TikVply video settings failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.resumed && _settings.keepScreenAwake && c?.value.isPlaying == true) {
      WakelockPlus.enable();
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (c != null && c.value.isInitialized) {
        _savePlaybackPosition(c.value.position);
        if (!_inPip) c.pause();
      }
      if (!_inPip) WakelockPlus.disable();
    }
  }

  void _togglePlay() {
    final c = _controller;
    if (_locked || c == null || !c.value.isInitialized) return;
    setState(() => _showControls = true);
    if (c.value.isPlaying) {
      c.pause();
      WakelockPlus.disable();
    } else {
      c.play();
      if (_settings.keepScreenAwake) WakelockPlus.enable();
    }
    _scheduleControlsHide();
  }

  void _handleTap() {
    if (_locked) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _hideControlsTimer?.cancel();
    if (!_showControls || _locked) return;
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onDoubleTap(TapDownDetails details) {
    if (_locked) return;
    final width = MediaQuery.sizeOf(context).width;
    if (details.localPosition.dx < width / 3) {
      _seekBy(-_settings.skipSeconds);
    } else if (details.localPosition.dx > width * 2 / 3) {
      _seekBy(_settings.skipSeconds);
    } else {
      final provider = context.read<VideoProvider>();
      if (!widget.video.isLiked) provider.likeVideo(widget.video.id);
      setState(() { _showLikeAnimation = true; _likePosition = details.localPosition; });
      Future.delayed(const Duration(milliseconds: 650), () { if (mounted) setState(() => _showLikeAnimation = false); });
    }
  }

  void _seekBy(int seconds) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final d = c.value.duration;
    final target = c.value.position + Duration(seconds: seconds);
    c.seekTo(target < Duration.zero ? Duration.zero : target > d ? d : target);
    setState(() => _showControls = true);
    _scheduleControlsHide();
  }

  void _onVerticalDragStart(DragStartDetails details) async {
    if (_locked || !_settings.gesturesEnabled) return;
    _gestureStart = details.localPosition;
    _gestureStartVolume = _controller?.value.volume ?? 1;
    try { _gestureStartBrightness = await ScreenBrightness.instance.application; } catch (_) { _gestureStartBrightness = .5; }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_locked || !_settings.gesturesEnabled || _gestureStart == null) return;
    final height = MediaQuery.sizeOf(context).height;
    final delta = -details.delta.dy / height;
    final start = _gestureStart!;
    if (start.dx < MediaQuery.sizeOf(context).width / 2) {
      final value = ((_gestureStartBrightness ?? .5) + delta).clamp(0.05, 1.0).toDouble();
      ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } else {
      final value = ((_gestureStartVolume ?? 1) + delta).clamp(0.0, 1.0).toDouble();
      _controller?.setVolume(value);
    }
    setState(() => _showControls = true);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _gestureStart = null;
    _gestureStartBrightness = null;
    _gestureStartVolume = null;
    _scheduleControlsHide();
  }

  Future<void> _toggleFullscreen() async {
    _fullscreen = !_fullscreen;
    if (_fullscreen) {
      await SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    if (mounted) setState(() {});
  }

  Future<void> _enterPip() async {
    try {
      final available = await _platform.invokeMethod<bool>('isPipAvailable') ?? false;
      if (!available) {
        _showMessage('وضع صورة داخل صورة غير متاح على هذا الجهاز');
        return;
      }
      _inPip = true;
      await _platform.invokeMethod('enterPip');
      if (_controller?.value.isPlaying != true) await _controller?.play();
    } catch (e) {
      _inPip = false;
      debugPrint('TikVply PiP failed: $e');
      _showMessage('تعذر تشغيل صورة داخل صورة');
    }
  }

  void _toggleLock() {
    _hideControlsTimer?.cancel();
    setState(() { _locked = !_locked; _showControls = true; });
    if (!_locked) _scheduleControlsHide();
  }

  void _setSleepTimer(int? minutes) {
    _sleepTimer?.cancel();
    _sleepMinutes = minutes;
    if (minutes == null) { setState(() {}); return; }
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      _controller?.pause();
      if (mounted) setState(() => _sleepMinutes = null);
      WakelockPlus.disable();
      _showMessage('انتهى مؤقت النوم');
    });
    setState(() {});
  }

  void _toggleABLoop() {
    final position = _controller?.value.position ?? Duration.zero;
    if (_aPoint == null) {
      setState(() { _aPoint = position; _bPoint = null; });
      _showMessage('تم تحديد النقطة A');
    } else if (_bPoint == null && position > _aPoint!) {
      setState(() => _bPoint = position);
      _showMessage('تم تفعيل التكرار A-B');
    } else {
      setState(() { _aPoint = null; _bPoint = null; });
      _showMessage('تم إلغاء التكرار A-B');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _hideControlsTimer?.cancel();
    _sleepTimer?.cancel();
    final c = _controller;
    if (c != null && c.value.isInitialized) _savePlaybackPosition(c.value.position);
    _settings.removeListener(_applySettings);
    WidgetsBinding.instance.removeObserver(this);
    c?.removeListener(_playerListener);
    c?.dispose();
    WakelockPlus.disable();
    if (_fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent,statusBarIconBrightness: Brightness.light,statusBarBrightness: Brightness.dark,systemNavigationBarColor: Colors.black,systemNavigationBarIconBrightness: Brightness.light),
    child: Scaffold(backgroundColor: Colors.black, body: Stack(fit: StackFit.expand, children: [
      if (_loading) const _VideoLoadingShimmer() else if (_error != null) _errorView() else _playerView(),
      if (!_loading && _error == null && !_locked) _overlay(),
      if (_locked) Positioned(top: MediaQuery.paddingOf(context).top + 8, left: 8, child: IconButton(onPressed: _toggleLock, tooltip: 'فتح القفل', icon: const Icon(Icons.lock_rounded, color: Colors.white))),
      if (_showLikeAnimation) _likeAnimation(),
    ])),
  );

  Widget _playerView() {
    final c = _controller!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onDoubleTapDown: _onDoubleTap,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onHorizontalDragEnd: _settings.gesturesEnabled ? (details) { final v = details.primaryVelocity ?? 0; if (v.abs() > 300) _seekBy(v < 0 ? _settings.skipSeconds : -_settings.skipSeconds); } : null,
      child: Center(child: ValueListenableBuilder<VideoPlayerValue>(valueListenable:c,builder:(_,value,__){
        if(!value.isInitialized)return const _VideoLoadingShimmer();
        final aspect=value.aspectRatio>0?value.aspectRatio:9/16;
        final fit=switch(_settings.fitMode){VideoFitMode.cover=>BoxFit.cover,VideoFitMode.contain=>BoxFit.contain,VideoFitMode.fill=>BoxFit.fill};
        return SizedBox.expand(child:FittedBox(fit:fit,clipBehavior:Clip.hardEdge,child:SizedBox(width:value.size.width,height:value.size.width/aspect,child:VideoPlayer(c))));
      })),
    );
  }

  Widget _overlay() => Stack(children: [
    const Positioned(top:0,left:0,right:0,child:IgnorePointer(child:_TopGradient())),
    Positioned(top:MediaQuery.paddingOf(context).top+4,right:4,child:Row(children:[
      IconButton(onPressed:_enterPip,tooltip:'صورة داخل صورة',icon:const Icon(Icons.picture_in_picture_alt_rounded,color:Colors.white)),
      IconButton(onPressed:_toggleFullscreen,tooltip:'ملء الشاشة',icon:Icon(_fullscreen?Icons.fullscreen_exit_rounded:Icons.fullscreen_rounded,color:Colors.white)),
      IconButton(onPressed:_toggleLock,tooltip:'قفل عناصر التحكم',icon:const Icon(Icons.lock_open_rounded,color:Colors.white)),
    ])),
    Positioned(top:MediaQuery.paddingOf(context).top+8,left:8,child:Row(children:[
      _SmallAction(icon:Icons.timer_rounded,label:_sleepMinutes == null ? 'مؤقت' : '${_sleepMinutes}د',onTap:_showSleepMenu),
      const SizedBox(width:6),
      _SmallAction(icon:Icons.repeat_rounded,label:_bPoint == null ? 'A-B' : 'A-B ✓',onTap:_toggleABLoop),
    ])),
    Positioned(left:12,right:78,bottom:92,child:IgnorePointer(child:VideoInfo(video:widget.video))),
    Positioned(right:10,bottom:92,child:VideoActions(video:widget.video)),
    Positioned(left:12,right:12,bottom:MediaQuery.paddingOf(context).bottom+12,child:ValueListenableBuilder<VideoPlayerValue>(valueListenable:_controller!,builder:(_,value,__){
      if(!value.isInitialized||!_showControls)return const SizedBox.shrink();
      return Row(children:[
        IconButton(icon:Icon(value.isPlaying?Icons.pause_rounded:Icons.play_arrow_rounded,color:Colors.white),onPressed:_togglePlay),
        IconButton(icon:const Icon(Icons.replay_10_rounded,color:Colors.white),onPressed:()=>_seekBy(-_settings.skipSeconds)),
        Expanded(child:VideoProgressIndicator(_controller!,allowScrubbing:true,padding:const EdgeInsets.symmetric(horizontal:4),colors:const VideoProgressColors(playedColor:AppColors.primary,bufferedColor:Colors.white38,backgroundColor:Colors.white24))),
        IconButton(icon:const Icon(Icons.forward_10_rounded,color:Colors.white),onPressed:()=>_seekBy(_settings.skipSeconds)),
        IconButton(icon:Icon(value.volume==0?Icons.volume_off_rounded:Icons.volume_up_rounded,color:Colors.white),onPressed:()=>_controller?.setVolume(value.volume==0?1:0)),
      ]);
    }))
  ]);

  void _showSleepMenu() {
    showModalBottomSheet<void>(context: context, backgroundColor: Colors.grey[900], builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const ListTile(title: Text('مؤقت النوم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      for (final minutes in [15, 30, 60, 90]) ListTile(leading: const Icon(Icons.schedule_rounded,color:Colors.white), title: Text('$minutes دقيقة',style:const TextStyle(color:Colors.white)), onTap:(){ Navigator.pop(context); _setSleepTimer(minutes); }),
      ListTile(leading: const Icon(Icons.timer_off_rounded,color:Colors.white), title: const Text('إيقاف المؤقت',style:TextStyle(color:Colors.white)), onTap:(){ Navigator.pop(context); _setSleepTimer(null); }),
    ])));
  }

  Widget _errorView()=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.video_file_rounded,color:Colors.white54,size:64),const SizedBox(height:14),Text(_error!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w700)),const SizedBox(height:18),Wrap(alignment:WrapAlignment.center,spacing:10,children:[FilledButton.icon(onPressed:_initializeVideo,icon:const Icon(Icons.refresh_rounded),label:const Text('إعادة المحاولة')),OutlinedButton.icon(onPressed:widget.onCompleted??()=>Navigator.maybePop(context),icon:const Icon(Icons.skip_next_rounded),label:const Text('الفيديو التالي'))])])));
  Widget _likeAnimation()=>Positioned(left:_likePosition.dx-50,top:_likePosition.dy-50,child:TweenAnimationBuilder<double>(tween:Tween(begin:.35,end:1.15),duration:const Duration(milliseconds:450),curve:Curves.elasticOut,builder:(_,scale,child)=>Transform.scale(scale:scale,child:child),child:const Icon(Icons.favorite_rounded,color:AppColors.secondary,size:100)));
}

class _SmallAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SmallAction({required this.icon,required this.label,required this.onTap});
  @override Widget build(BuildContext context)=>Material(color:Colors.black45,borderRadius:BorderRadius.circular(20),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:onTap,child:Padding(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,color:Colors.white,size:18),const SizedBox(width:4),Text(label,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w700))]))));
}

class _TopGradient extends StatelessWidget { const _TopGradient(); @override Widget build(BuildContext context)=>Container(height:140,decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.black60,Colors.transparent]))); }
class _VideoLoadingShimmer extends StatelessWidget { const _VideoLoadingShimmer(); @override Widget build(BuildContext context)=>Shimmer.fromColors(baseColor:const Color(0xFF101817),highlightColor:const Color(0xFF2B3836),period:const Duration(milliseconds:1150),child:Stack(fit:StackFit.expand,children:[const ColoredBox(color:Color(0xFF171F1E)),Center(child:Container(width:86,height:86,decoration:const BoxDecoration(color:Color(0xFF26302F),shape:BoxShape.circle))),Positioned(left:16,right:88,bottom:104,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:205,height:15,decoration:BoxDecoration(color:Color(0xFF293331),borderRadius:BorderRadius.all(Radius.circular(8)))),SizedBox(height:10),Container(width:145,height:12,decoration:BoxDecoration(color:Color(0xFF293331),borderRadius:BorderRadius.all(Radius.circular(8)))),SizedBox(height:9),Container(width:230,height:9,decoration:BoxDecoration(color:Color(0xFF293331),borderRadius:BorderRadius.all(Radius.circular(6)))])),Positioned(right:14,bottom:128,child:Column(children:[for(var i=0;i<4;i++)Padding(padding:const EdgeInsets.only(bottom:15),child:Container(width:45,height:45,decoration:const BoxDecoration(color:Color(0xFF293331),shape:BoxShape.circle))])),const Positioned(left:14,right:14,bottom:18,child:SizedBox(height:4,child:ColoredBox(color:Color(0xFF293331))))])); }
