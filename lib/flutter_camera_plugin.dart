import 'dart:async';

import 'package:flutter/services.dart';

class FlutterCameraPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_camera_plugin');

  static Future<String> get captureImage async {
    final String imagePath = await _channel.invokeMethod('captureImage');
    return imagePath;
  }

  static Future<String> get pickImage async {
    final String imagePath = await _channel.invokeMethod('pickImage');
    return imagePath;
  }

  static Future<String> get captureVideo async {
    final String videoPath = await _channel.invokeMethod('captureVideo');
    return videoPath;
  }

  static Future<String> get pickVideo async {
    final String videoPath = await _channel.invokeMethod('pickVideo');
    return videoPath;
  }

  static Future<String> getFileName(String path) async {
    final String fileName =
        await _channel.invokeMethod("getFileName", {"path": path});
    return fileName;
  }
  static Future<String> getFileNameWithoutExt(String path) async {
    final String fileName =
        await _channel.invokeMethod("getFileNameWithoutExt", {"path": path});
    return fileName;
  }

  static Future<String> getThumbnail(String path) async {
    final filePath =
        await _channel.invokeMethod("getThumbnail", {"path": path});
    return filePath;
  }
  static Future<String> writeTextToImage(String path, String content) async {
    final filePath =
        await _channel.invokeMethod("writeTextToImage", {"path": path, "content":content});
    return filePath;
  }
}
