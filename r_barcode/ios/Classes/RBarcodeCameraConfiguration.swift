//
//  RBarcodeCameraConfiguration.swift
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/6.
//  rhymelph@gmail.com
//

import Foundation
import AVFoundation

enum ResolutionPreset{
    case veryLow
    case low
    case medium
    case high
    case veryHigh
    case ultraHigh
    case max
}

@available(iOS 10.0, *)
class RBarcodeCameraConfiguration {
    
    class func getAvailableCameras()->Array<[String:Any]>{
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        
        let devices = discoverySession.devices
        var reply:Array<[String:Any]> = Array()
        
        for device in devices {
            var lensFacing:String!
            switch device.position {
            case .back:
                lensFacing = "back"
            case .front:
                lensFacing = "front"
            case .unspecified:
                lensFacing = "external"
            @unknown default:
                fatalError()
            }
            reply.append(["name":device.uniqueID,"lensFacing":lensFacing!])
        }
        return reply
    }
    
    class func  getResolutionPresetForString(preset:String) -> ResolutionPreset?{
        switch preset {
        case "veryLow":
            return .veryLow
        case "low":
            return .low
        case "medium":
            return .medium
        case "high":
            return .high
        case "veryHigh":
            return .veryHigh
        case "ultraHigh":
            return .ultraHigh
        case "max":
            return .max
        default:
            return nil
        }
    }
}
