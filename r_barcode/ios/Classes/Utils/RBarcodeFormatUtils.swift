//
//  RBarcodeFormatUtils.swift
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/6.
//  rhymelph@gmail.com
//
import Foundation
import AVFoundation

struct RBarcodeFormatUtils {
    
    static func transitionFromFlutterCode(formats:Array<String>)->[AVMetadataObject.ObjectType]{
        var resultFormats = [AVMetadataObject.ObjectType]()
        for format in formats {
            switch format {
            case "Codabar":
                resultFormats.append(AVMetadataObject.ObjectType.code39Mod43)
            case "Code39":
                resultFormats.append(AVMetadataObject.ObjectType.code39)
            case "Code93":
                resultFormats.append(AVMetadataObject.ObjectType.code93)
            case "Code128":
                resultFormats.append(AVMetadataObject.ObjectType.code128)
            case "EAN8":
                resultFormats.append(AVMetadataObject.ObjectType.ean8)
            case "EAN13":
                resultFormats.append(AVMetadataObject.ObjectType.ean13)
            case "ITF":
                resultFormats.append(AVMetadataObject.ObjectType.itf14)
            case "UPCA":
                resultFormats.append(AVMetadataObject.ObjectType.upce)
            case "UPCE":
                resultFormats.append(AVMetadataObject.ObjectType.upce)
            case "Aztec":
                resultFormats.append(AVMetadataObject.ObjectType.aztec)
            case "DataMatrix":
                resultFormats.append(AVMetadataObject.ObjectType.dataMatrix)
            case "PDF417":
                resultFormats.append(AVMetadataObject.ObjectType.pdf417)
            case "QRCode":
                resultFormats.append(AVMetadataObject.ObjectType.qr)
            default:
                print("no support \(format) format")
            }
        }
        return resultFormats
    }
    
    static func transitionToFlutterCode(barcodeFormat: AVMetadataObject.ObjectType) -> String {
        switch barcodeFormat {
        case .code39:
            return "Code39"
        case .code93:
            return "Code93"
        case .code128:
            return "Code128"
        case .ean8:
            return "EAN8"
        case .ean13:
            return "EAN13"
        case .itf14:
            return "ITF"
        case .upce:
            return "UPCE"
        case .aztec:
            return "Aztec"
        case .dataMatrix:
            return "DataMatrix"
        case .pdf417:
            return "PDF417"
        case .qr:
            return "QRCode"
        default:
            return ""
        }
        
    }
}
