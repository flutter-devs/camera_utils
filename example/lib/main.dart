import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:camera_utils/camera_utils.dart';

import 'dart:io';

import 'package:flutter/material.dart';

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
  String _path = null;
  String _thumbPath = null;
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
                    new Image.asset(
                      _assetPlayImagePath,
                      width: 72.0,
                      height: 72.0,
                    ),
                    new Container(
                      margin: EdgeInsets.only(top: 2.0),
                      child: Text(
                        _videoName != null ? _videoName : '',
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
                'PATH: $_path',
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

  Future _captureImage() async {
    final path = await CameraUtils.captureImage;
    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = false;
      });
    }
  }

  Future _pickImage() async {
    final path = await CameraUtils.pickImage;
    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = false;
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
        ? await CameraUtils.captureVideo
        : await CameraUtils.pickVideo;

    if (path != null) {
      setState(() {
        _path = path;
        _isVideo = true;
      });
      Future<String> name = CameraUtils.getFileName(path);
      name.then((fileName) {
        setState(() {
          _videoName = fileName;
          print(fileName);
        });
      });
      Future<String> thumbPath = CameraUtils.getThumbnail(path);
      thumbPath.then((path) {
        setState(() {
          _thumbPath = path;
          print(path);
        });
      });
    }
  }
}
