import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_plugin/flutter_camera_plugin.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Camera Plugin Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyApp(),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _assetVideoPath = 'assets/videos/aeologic_logo.mp4';
  String _path = null;
  String _thumbPath = null;
  String _videoPath = null;
  double _headerHeight = 320.0;
  final String _assetImagePath = 'assets/images/ic_no_image.png';
  final String _assetPlayImagePath = 'assets/images/ic_play.png';
  final String _assetLogoImagePath = 'assets/images/ic_flutter_devs_logo.png';

  bool _isVideo = false;
  String _videoName;

  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          _path != null
              ? _isVideo ? _getVideoContainer() : _getImageFromFile()
              : _getImageFromAsset(),
          //_getCameraFab(),
          _getContentContainerLogo(),
        ],
      ),
    );
  }

  Widget _getImageFromFile() {
    return Container(
      padding: EdgeInsets.only(bottom: 30.0),
      child: new Container(
          width: double.infinity,
          height: _headerHeight,
          color: Colors.grey,
          child: Stack(
            children: <Widget>[
              new Image.file(
                File(
                  _path,
                ),
                fit: BoxFit.cover,
                width: double.infinity,
                height: _headerHeight,
              ),
              _buildPathWidget(),
            ],
          )),
    );
  }

  Widget _getImageFromAsset() {
    return Container(
      padding: EdgeInsets.only(bottom: 30.0),
      child: new Container(
          width: double.infinity,
          height: _headerHeight,
          color: Colors.grey,
          child: Stack(
            children: <Widget>[
              new Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Image.asset(
                      _assetImagePath,
                      //fit: BoxFit.fill,
                      width: 48.0,
                      height: 32.0,
                    ),
                    new Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'No Preview Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildPathWidget(),
            ],
          )),
    );
  }

  Widget _getVideoContainer() {
    return Container(
      padding: EdgeInsets.only(bottom: 30.0),
      child: new Container(
          width: double.infinity,
          height: _headerHeight,
          color: Colors.grey,
          child: Stack(
            children: <Widget>[
              _thumbPath != null
                  ? new Opacity(
                      opacity: 0.5,
                      child: new Image.file(
                        File(
                          _thumbPath,
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: _headerHeight,
                      ),
                    )
                  : new Container(),
              new Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new VideoSplashScreen(_path)));
                      },
                      child: new Image.asset(
                        _assetPlayImagePath,
                        width: 72.0,
                        height: 72.0,
                      ),
                    ),
                    new Container(
                      margin: EdgeInsets.only(top: 2.0),
                      child: Text(
                        _videoName != null ? _videoName : "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildPathWidget()
            ],
          )),
    );
  }

  _playVideo(BuildContext context) {
    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoSplashScreen(_path)),
    );*/
  }

  Widget _buildPathWidget() {
    return _path != null
        ? new Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 60.0,
              padding: EdgeInsets.all(20.0),
              color: Color.fromRGBO(00, 00, 00, 0.7),
              child: Text(
                "PATH: $_path",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : new Container();
  }

  Widget _getContentContainerLogo() {
    return Container(
        margin: EdgeInsets.only(top: _headerHeight + 5.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            new Container(
              color: Colors.red,
              padding: EdgeInsets.all(10.0),

              //color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: _captureImage,
                    child:
                        buildButtonControl(Icons.camera_alt, 'Capture Image'),
                  ),
                  InkWell(
                    onTap: _pickImage,
                    child: buildButtonControl(Icons.image, 'Pick Image'),
                  ),
                  InkWell(
                    onTap: () => _takeVideo(true),
                    child: buildButtonControl(Icons.videocam, 'Capture Video'),
                  ),
                  InkWell(
                    onTap: () => _takeVideo(false),
                    child:
                        buildButtonControl(Icons.video_library, 'Pick Video'),
                  ),
                ],
              ),
            ),
            new Center(
              child: Image.asset(
                _assetLogoImagePath,
                width: 160.0,
                height: 160.0,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ));
  }

  Widget buildButtonControl(IconData icon, String label) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLogo() {
    return Container(
      margin: EdgeInsets.only(top: 200.0),
      alignment: Alignment.center,
      child: Center(
        child: Image.asset(
          _assetLogoImagePath,
          width: 160.0,
          height: 160.0,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /* Future _playVideo() async {
    */ /*final videoPath = await Navigator.of(context).pushNamed(CAMERA_SCREEN);


    if (mounted) {
      setState(() {
        _videoPath = videoPath;
        _controller = VideoPlayerController.file(File(_videoPath))
          ..addListener(listener)
          ..setVolume(1.0)
          ..initialize()
          ..setLooping(true)
          ..play();
      });*/ /*
  }*/

  Future _captureImage() async {
    final path = await FlutterCameraPlugin.captureImage;
    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = false;
      });
    }
  }

  Future _pickImage() async {
    final tempPath = await FlutterCameraPlugin.pickImage;
    final path = await FlutterCameraPlugin.writeTextToImage(tempPath, "hasgkjhfgajkghjkgf");
    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = false;
      });
    }
  }

  Future _captureVideo() async {
    final path = await FlutterCameraPlugin.captureVideo;
    final name = await FlutterCameraPlugin.getFileName(path);
    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = true;

        _videoName = name;
      });
    }
  }

  Future _takeVideo(bool isCapture) async {
    setState(() {
      _thumbPath = null;
      _isVideo = false;
      _path = null;
      _videoName = null;
    });

    final path = isCapture
        ? await FlutterCameraPlugin.captureVideo
        : await FlutterCameraPlugin.pickVideo;

    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = true;
      });
      Future<String> name = FlutterCameraPlugin.getFileName(path);
      name.then((fileName) {
        setState(() {
          _videoName = fileName;
          print(fileName);
        });
      });
      Future<String> thumbPath = FlutterCameraPlugin.getThumbnail(path);
      thumbPath.then((path) {
        setState(() {
          _thumbPath = path;
          print(path);
        });
      });
    }
  }
}

class VideoSplashScreen extends StatefulWidget {
  String path;

  VideoSplashScreen(this.path);

  @override
  _VideoSplashScreenState createState() => _VideoSplashScreenState(path);
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  VideoPlayerController playerController;
  VoidCallback listener;
  String path;

  BuildContext context;

  _VideoSplashScreenState(this.path);

  @override
  @override
  void initState() {
    super.initState();

    listener = () {
      setState(() {});
    };
    initializeVideo();
    playerController.play();
  }

  void initializeVideo() {
    playerController = VideoPlayerController.file(File(path))
      ..addListener(listener)
      ..setVolume(1.0)
     ..initialize()
      ..play();
  }

  @override
  void deactivate() {
    if (playerController != null) {
      playerController.setVolume(0.0);
      playerController.removeListener(listener);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (playerController != null) playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
        appBar: new AppBar(
          title: Text('Video Player'),
        ),
        body: Stack(fit: StackFit.expand, children: <Widget>[
          new AspectRatio(
              aspectRatio: 9 / 16,
              child: Container(
                child: (playerController != null
                    ? VideoPlayer(
                        playerController,
                      )
                    : Container()),
              )),
        ]));
  }
}
