#import "CameraUtilsPlugin.h"
#import <camera_utils/camera_utils-Swift.h>

@implementation CameraUtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCameraUtilsPlugin registerWithRegistrar:registrar];
}
@end
