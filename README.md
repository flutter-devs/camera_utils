For help getting started with Flutter, view our online
[documentation](https://flutter.io/).


[![Pub](https://img.shields.io/badge/Pub-0.1.7-orange.svg?style=flat-square)](https://pub.dartlang.org/packages/camera_utils)



# camera_utils

Flutter plugin for capturing and picking image and videos and getting thumbnail from videos on the Android & iOS devices.

### Implementation in Flutter

Simply add a dependency to you pubspec.yaml for camera_utils.

Then import the package in your dart file with

```dart
import 'package:camera_utils/camera_utils.dart';
```

### Screenshots

<img height="480px" src="https://github.com/flutter-devs/camera_utils/blob/master/assets/screenshots/screenshot1.jpg"> <img height="480px" src="https://github.com/flutter-devs/camera_utils/blob/master/assets/screenshots/screenshot2.jpg"> <img height="480px" src="https://github.com/flutter-devs/camera_utils/blob/master/assets/screenshots/screenshot3.jpg">


### Usages

1. Capture Image

    ```dart
    // Capture image
    final path = await CameraUtils.captureImage;
    ```
2. Pick Image

     ```dart
     // Pick image
    final path = await CameraUtils.pickImage;
    ```
3. Capture Video

    ```dart
    // Capture video
    final path = await CameraUtils.captureVideo;
    ```
4. Pick Video

    ```dart
    // Pick video
    final path = await CameraUtils.pickVideo;
    ```
5. Thumbnail from Video

    ```dart
    // Pass the path and get thumbnail from video
    Future<String> thumbPath = CameraUtils.getThumbnail(path);
      thumbPath.then((path) {
        setState(() {
          _thumbPath = path;
          print(path);
        });
      });
    ```
