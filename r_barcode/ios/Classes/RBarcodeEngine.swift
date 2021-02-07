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
    //静态方法
//    class func hello(){
//        print("Hello")
//    }
}
