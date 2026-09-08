import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadProvider extends ChangeNotifier {
  XFile? _selectedVideo;
  String? _caption;
  List<String> _hashtags = [];
  List<String> _mentions = [];
  String _privacy = 'public';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  XFile? get selectedVideo => _selectedVideo;
  String? get caption => _caption;
  List<String> get hashtags => _hashtags;
  List<String> get mentions => _mentions;
  String get privacy => _privacy;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  void setSelectedVideo(XFile? video) {
    _selectedVideo = video;
    notifyListeners();
  }

  void setCaption(String caption) {
    _caption = caption;
    _extractHashtags(caption);
    _extractMentions(caption);
    notifyListeners();
  }

  void _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    final matches = regex.allMatches(text);
    _hashtags = matches.map((m) => m.group(1)!).toList();
  }

  void _extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(text);
    _mentions = matches.map((m) => m.group(1)!).toList();
  }

  void setPrivacy(String privacy) {
    _privacy = privacy;
    notifyListeners();
  }

  Future<void> uploadVideo() async {
    if (_selectedVideo == null) return;

    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        _uploadProgress = i / 100;
        notifyListeners();
      }

      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedVideo = null;
    _caption = null;
    _hashtags = [];
    _mentions = [];
    _privacy = 'public';
    _isUploading = false;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
