import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  static Future<Directory> getAppDirectory() async => getApplicationDocumentsDirectory();
  static Future<Directory> getTempDirectory() async => getTemporaryDirectory();
  static Future<Directory> getDownloadDirectory() async {
    return await getDownloadsDirectory() ?? await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
  }
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) status = await Permission.storage.request();
    return status.isGranted;
  }
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) status = await Permission.camera.request();
    return status.isGranted;
  }
  static Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) status = await Permission.microphone.request();
    return status.isGranted;
  }
  static Future<bool> requestPhotosPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }
  static String getFileExtension(String path) => path.split('.').last.toLowerCase();
  static String getFileName(String path) => path.split('/').last;
  static String getFileNameWithoutExtension(String path) {
    final fileName = getFileName(path);
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? fileName : fileName.substring(0, dotIndex);
  }
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    return await file.exists() ? file.length() : 0;
  }
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  static Future<void> deleteFile(String path) async { final file = File(path); if (await file.exists()) await file.delete(); }
  static Future<void> copyFile(String sourcePath, String destinationPath) async { final file = File(sourcePath); if (await file.exists()) await file.copy(destinationPath); }
  static Future<void> moveFile(String sourcePath, String destinationPath) async { final file = File(sourcePath); if (await file.exists()) await file.rename(destinationPath); }
  static Future<void> createDirectory(String path) async { final directory = Directory(path); if (!await directory.exists()) await directory.create(recursive: true); }
  static bool isVideoFile(String path) => ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(getFileExtension(path));
  static bool isImageFile(String path) => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(getFileExtension(path));
  static bool isAudioFile(String path) => ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'].contains(getFileExtension(path));
}
