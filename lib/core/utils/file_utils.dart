import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  static Future<Directory> getDownloadDirectory() async {
    return await getDownloadsDirectory() ?? await getExternalStorageDirectory()!;
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestPhotosPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    return status.isGranted || status.isLimited;
  }

  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static String getFileName(String path) {
    return path.split('/').last;
  }

  static String getFileNameWithoutExtension(String path) {
    String fileName = getFileName(path);
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }

  static Future<int> getFileSize(String path) async {
    File file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }

  static Future<void> deleteFile(String path) async {
    File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> copyFile(String sourcePath, String destinationPath) async {
    File sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destinationPath);
    }
  }

  static Future<void> moveFile(String sourcePath, String destinationPath) async {
    File sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.rename(destinationPath);
    }
  }

  static Future<void> createDirectory(String path) async {
    Directory directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  static bool isVideoFile(String path) {
    String extension = getFileExtension(path);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(extension);
  }

  static bool isImageFile(String path) {
    String extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  static bool isAudioFile(String path) {
    String extension = getFileExtension(path);
    return ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'].contains(extension);
  }
}
