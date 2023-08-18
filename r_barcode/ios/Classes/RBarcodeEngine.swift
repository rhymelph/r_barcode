//
//  File.swift
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/6.
//  rhymelph@gmail.com
//

import Foundation
import AVFoundation

class RBarcodeEngine {
    var isDebug:Bool! = true
    var isReturnImage:Bool! = false
    var isScan:Bool! = false
    var mFormats:Array<AVMetadataObject.ObjectType> = [AVMetadataObject.ObjectType]()
    let kAllFormats:Array<AVMetadataObject.ObjectType> = [
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.dataMatrix,
        //    AVMetadataObject.ObjectType.dogBody,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.ean8,
        //    AVMetadataObject.ObjectType.face,
        //    AVMetadataObject.ObjectType.humanBody,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.qr,
    ]
    
    func initEngine(isDebug:Bool,formats:Array<String>,isReturnImage:Bool) -> Void {
        self.isDebug = isDebug
        self.isReturnImage = isReturnImage
        setBarcodeFormats(formats: formats)
    }
    
    func setBarcodeFormats(formats:Array<String>) {
        mFormats.removeAll()
        mFormats.append(contentsOf: RBarcodeFormatUtils.transitionFromFlutterCode(formats: formats))
    }
    
    func getBarcodeFormats()->[AVMetadataObject.ObjectType]{
        if(mFormats.isEmpty){
            return kAllFormats
        }else{
            return mFormats
        }
    }
    
    func decodeImage(data:Data?)->[[String:Any]]{
        var result = [[String:Any]]()
        if(data == nil){
            return result
        }
        let detectImage = CIImage(data: data!)
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil,options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        let feature = detector?.features(in: detectImage!)
        if(feature?.count == 0){
            return result
        }else{
            for i in (0..<feature!.count){
                let qrCode:CIQRCodeFeature = feature?[i] as! CIQRCodeFeature
                let resultStr = qrCode.messageString
                if(resultStr != nil){
                    let text = resultStr
                    let format = RBarcodeFormatUtils.transitionToFlutterCode(barcodeFormat: .qr)
                    var points = [[String:Any]]()
                    var corners = [CGPoint]()
                    corners.append(qrCode.topLeft)
                    corners.append(qrCode.topRight)
                    corners.append(qrCode.bottomLeft)
                    corners.append(qrCode.bottomRight)
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    
                    for corner in corners {
                        
                        points.append([
                            "x":corner.x/screenWidth,
                            "y":corner.y/screenHeight])
                    }
                    
                    var dataResult = [String:Any]()
                    dataResult["points"] = points
                    dataResult["format"] = format
//                    if data != nil {
//                        dataResult["image"] = FlutterStandardTypedData(bytes: data! as Data)
//                    }
                    if text != nil {
                        dataResult["text"] = text!
                    }
                    result.append(dataResult)
                }
            }
        }
        return result
    }
    //静态方法
    //    class func hello(){
    //        print("Hello")
    //    }
}
