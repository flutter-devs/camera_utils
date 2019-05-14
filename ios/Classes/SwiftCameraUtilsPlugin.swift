import Flutter
import UIKit
import AVFoundation
import MobileCoreServices

public class SwiftCameraUtilsPlugin: NSObject, FlutterPlugin {

fileprivate var currentVideoPath = ""
fileprivate var result: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "camera_utils", binaryMessenger: registrar.messenger())
        let instance = SwiftCameraUtilsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    self.result = result
        if (call.method == "captureImage") {
            print("captureImage")
            self.openCamera(false)
        }
        else if (call.method == "pickImage") {
            print("pickImage")
            self.openPhotoLibrary(false)
        }
        else if (call.method == "captureVideo") {
            print("captureVideo")
            self.openCamera(true)
        }
        else if (call.method == "pickVideo") {
            print("pickVideo")
            self.openPhotoLibrary(true)
        }
        else if (call.method == "getFileName") {
            
            let tempPathDict = call.arguments as? Dictionary<String, Any>
            let tempPath = tempPathDict!["path"] as! String
            self.getFileName(tempPath) {
                (filename) in
                self.result!(filename)
            }
            print("getFileName")
        }
        else if (call.method == "getFileNameWithoutExt") {
            print("getFileNameWithoutExt")
        }
        else if (call.method == "getThumbnail") {
            let tempPathDict = call.arguments as? Dictionary<String, Any>
            let tempVideoPath = tempPathDict!["path"] as! String
            let tempImg = self.generateThumbnail(path: URL.init(fileURLWithPath: tempVideoPath))
            self.generateImageUrlStr(tempImg!) {
                (imgPathStr) in
                self.result!(imgPathStr)
            }

            print("getThumbnail")
        }
        else if (call.method == "writeTextToImage") {
            print("writeTextToImage")
        }
        else {
            print("iOS")
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}

extension SwiftCameraUtilsPlugin {
    
    func openCamera(_ isVideo: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = true
            if isVideo {
                imagePicker.mediaTypes = [kUTTypeMovie as String]
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary(_ isVideo: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            if isVideo {
                imagePicker.mediaTypes = [kUTTypeMovie as String]
            }
            imagePicker.allowsEditing = false;
            UIApplication.shared.keyWindow?.rootViewController?.present(imagePicker, animated: true, completion: nil);
        }
    }
    
    //Mark : Get Image Url
    fileprivate func getFileName(_ path: String, callBackHandler: @escaping (_ fileName : String) -> Void) {
        let theFileName = (path as NSString).lastPathComponent
        callBackHandler(theFileName)
    }
    
    //Mark : Get Image Url
    fileprivate func generateImageUrlStr(_ image: UIImage, callBackHandler: @escaping (_ imgPathStr : String) -> Void) {
        var resultData: Data?
        resultData = image.jpegData(compressionQuality: 1.0)
        var imageSize: Double =  Double(resultData!.count) / 1024.0
        var tempImage = image
        
        while (imageSize > 10000) {
            resultData = tempImage.jpegData(compressionQuality: 0.9)
            imageSize = Double(resultData!.count) / 1024.0
            tempImage = UIImage.init(data: resultData!)!
        }
        
        let guid = ProcessInfo.processInfo.globallyUniqueString;
        let tmpFile = String(format: "image_picker_%@.jpg", guid);
        let tmpDirectory = NSTemporaryDirectory();
        let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
        if(FileManager.default.createFile(atPath: tmpPath, contents: resultData, attributes: [:])) {
            callBackHandler(tmpPath)
        }
    }
    
    //Mark : Get Video Url
    fileprivate func generateVideoUrlStr(_ videoData : Data, _ fileName: String, callBackHandler: @escaping (_ videoPathStr : String) -> Void) {
        let guid = ProcessInfo.processInfo.globallyUniqueString;
        let tmpFile = String(format: "%@_%@.mov", fileName, guid);
        let tmpDirectory = NSTemporaryDirectory();
        let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
        if(FileManager.default.createFile(atPath: tmpPath, contents: videoData, attributes: [:])) {
            callBackHandler(tmpPath)
        }
    }
    
    //Mark : Get first frame of video
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

extension SwiftCameraUtilsPlugin: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* Image Picker Controller delegate */
    @objc public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let infoDict : NSDictionary = info as NSDictionary;
        
        //MARK: for image
        if let image: UIImage = (infoDict.object(forKey: "UIImagePickerControllerOriginalImage") as? UIImage) {
            self.generateImageUrlStr(image) {
                (imgPathStr) in
                self.result!(imgPathStr)
            }
        }
            
            //MARK: for video
        else if let videoUrl = infoDict.object(forKey: "UIImagePickerControllerMediaURL") as? NSURL {
            
            let videoData = NSData(contentsOf: videoUrl as URL)! as Data
            let lastPathComponent = videoUrl.lastPathComponent
            let lastPathComponentArr = lastPathComponent?.components(separatedBy: ".")
            let fileName = lastPathComponentArr?.first
            
            self.generateVideoUrlStr(videoData, fileName!) {
                (videoPathStr) in
                self.currentVideoPath = videoPathStr
                self.result!(videoPathStr)
            }
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
