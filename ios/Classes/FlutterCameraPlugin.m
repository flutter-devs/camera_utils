#import "FlutterCameraPlugin.h"

@implementation FlutterCameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_camera_plugin"
            binaryMessenger:[registrar messenger]];
  FlutterCameraPlugin* instance = [[FlutterCameraPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"captureImage" isEqualToString:call.method]) {
    result([@"Capture Image from iOS");
  } else if ([@"pickImage" isEqualToString:call.method]) {
    result([@"Pick Image from iOS");
  } else if ([@"captureVideo" isEqualToString:call.method]) {
    result([@"Capture Video from iOS");
  } else if ([@"pickVideo" isEqualToString:call.method]) {
    result([@"Pick Video from iOS");
  } else if ([@"getFileName" isEqualToString:call.method]) {
    result([@"File Name from iOS");
  } else if ([@"getFileNameWithoutExt" isEqualToString:call.method]) {
    result([@"File Name Without Ext from iOS");
  } else if ([@"getThumbnail" isEqualToString:call.method]) {
    result([@"Thumbnail from iOS");
  } else if ([@"writeTextToImage" isEqualToString:call.method]) {
    result([@"writeTextToImage from iOS");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
