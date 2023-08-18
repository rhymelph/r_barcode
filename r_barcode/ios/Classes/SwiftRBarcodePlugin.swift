import Flutter
import UIKit

public class SwiftRBarcodePlugin: NSObject, FlutterPlugin {
    var textureRegistry:FlutterTextureRegistry!
    var messenger:FlutterBinaryMessenger!
    
    var rBarcodeEngine:RBarcodeEngine!
    var rBarcodeCameraView:RBarcodeCameraView!
    public override init() {
        rBarcodeEngine = RBarcodeEngine()
        
    }
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.rhyme_lph/r_barcode", binaryMessenger: registrar.messenger())
        let instance = SwiftRBarcodePlugin()
        instance.textureRegistry = registrar.textures()
        instance.messenger = registrar.messenger()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let map = call.arguments as? [String:Any]
        switch call.method {
        case "initBarcodeEngine":
            let isDebug = map!["isDebug"] as! Bool
            let formats = map!["formats"] as! Array<String>
            let isReturnImage = map!["isReturnImage"] as! Bool
            rBarcodeEngine.initEngine(isDebug: isDebug, formats: formats, isReturnImage: isReturnImage)
            result(nil)
        case "availableCameras":
            print("availableCameras")
            if #available(iOS 10.0, *) {
                result(RBarcodeCameraConfiguration.getAvailableCameras())
            } else {
                result(FlutterError(code: "100", message: "no support low by IOS 10.0", details: nil))
            }
        case "setBarcodeFormats":
            if(rBarcodeCameraView != nil){
                let formats = map!["formats"] as! Array<String>
                rBarcodeEngine.setBarcodeFormats(formats: formats)
                rBarcodeCameraView.setMetadataObjects(metaTypes: rBarcodeEngine.getBarcodeFormats())
                result(nil)
            }else{
                result(FlutterError(code: "Error", message: "Camera View is null", details: nil))
            }
            
        case "initialize":
            if(rBarcodeCameraView != nil){
                rBarcodeCameraView.close()
            }
            if #available(iOS 10.0, *) {
                self.instantiateCamera(map!,result: result)
            } else {
                result(FlutterError(code: "100", message: "no support low by IOS 10.0", details: nil))
            }
        case "dispose":
            print("dispose")
        case "isTorchOn":
            if(rBarcodeCameraView != nil){
                try? result(rBarcodeCameraView.isTorchOn())
            }else{
                result(FlutterError(code: "Error", message: "Camera View is null", details: nil))
            }
        case "enableTorch":
            if(rBarcodeCameraView != nil){
                let isTorchOn = map!["isTorchOn"] as! Bool
                let resultTorchOn = try? rBarcodeCameraView.enableTorch(b: isTorchOn)
                result(resultTorchOn!)
            }else{
                result(FlutterError(code: "Error", message: "Camera View is null", details: nil))
            }
        case "stopScan":
            if(rBarcodeCameraView != nil){
                rBarcodeCameraView.stopScan()
                result(nil)
            }else{
                result(FlutterError(code: "Error", message: "Camera View is null", details: nil))
            }
            
        case "startScan":
            if(rBarcodeCameraView != nil){
                rBarcodeCameraView.startScan()
                result(nil)
            }else{
                result(FlutterError(code: "Error", message: "Camera View is null", details: nil))
            }
        case "requestFocus":
            if(rBarcodeCameraView != nil){
                let y = map!["y"] as! NSNumber
                let x = map!["x"] as! NSNumber
                let width = map!["width"] as! NSNumber
                let height = map!["height"] as! NSNumber
                try? result(rBarcodeCameraView.requestFocus(x, y: y, width: width, height: height))

            }else{
                result(FlutterError(code: "Error", message: "Camera View is null", details: nil))
            }
        case "decodeImagePath":
            if(rBarcodeEngine != nil){
                let path = map!["path"] as! String
                let data = FileManager.default.contents(atPath: path)
                let decodeResult = rBarcodeEngine.decodeImage(data: data)
                result(decodeResult)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @available(iOS 10.0, *)
    func instantiateCamera(_ map: [String:Any], result: @escaping FlutterResult){
        let cameraName = map["cameraName"] as! String
        let resolutionPreset = map["resolutionPreset"] as! String
        rBarcodeCameraView = RBarcodeCameraView(isReturnImage:rBarcodeEngine.isReturnImage,cameraName: cameraName, resolutionPreset: resolutionPreset,metaTypes:rBarcodeEngine.getBarcodeFormats())
        
        let textureId = textureRegistry.register(rBarcodeCameraView)
        
        rBarcodeCameraView.onFrameAvailable = {
            self.textureRegistry?.textureFrameAvailable(textureId)
        }
        let events:RBarcodeEventChannel = RBarcodeEventChannel(textureId: textureId, messenger: messenger)
        
        rBarcodeCameraView.metaCallBack = { (metadataObjects, data) -> Void in
            let metaObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            let text = metaObject?.stringValue
            let format = RBarcodeFormatUtils.transitionToFlutterCode(barcodeFormat: metaObject!.type)
            var points = [[String:Any]]()
            
            let corners = metaObject?.corners
            for corner in corners! {
                points.append([
                    "x":1-corner.y,
                    "y":corner.x])
            }
            
            var dataResult = [String:Any]()
            dataResult["points"] = points
            dataResult["format"] = format
            if data != nil {
                dataResult["image"] = FlutterStandardTypedData(bytes: data! as Data)
            }
            
            if text != nil {
                dataResult["text"] = text!
            }
            events.sendMessage(msg: dataResult)
        }
        rBarcodeCameraView.open()
        rBarcodeCameraView.startScan()
        result([
            "textureId":textureId,
            "previewWidth":rBarcodeCameraView.previewSize.width,
            "previewHeight":rBarcodeCameraView.previewSize.height
        ])
    }
}
