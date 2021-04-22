//
//  RBarcodeCameraView.swift
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/6.
//  rhymelph@gmail.com
//

import Foundation
import AVFoundation
import CoreMotion
import libkern
import Accelerate
import Flutter


class RBarcodeCameraView :NSObject,FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate{
    var cameraName:String!
    var resolutionPreset:ResolutionPreset!
    
    var captureSession:AVCaptureSession!
    var captureDevice:AVCaptureDevice!
    var captureVideoInput:AVCaptureInput!
    var metadataOutput:AVCaptureMetadataOutput!
    var captureVideoOutput:AVCaptureVideoDataOutput!
    var previewSize:CGSize!
    var latestPixelBuffer:CMSampleBuffer? = nil
    var latestConverter:RBarcodePixelConverter? = nil
    var dispatchQueue:DispatchQueue = DispatchQueue.global()
    var onFrameAvailable: (() -> Void)?
    var metaTypes:[AVMetadataObject.ObjectType]!
    var metaCallBack:(([AVMetadataObject],NSData?)->Void)?
    var timeInterval:String?
    var isReturnImage:Bool!
    
    @available(iOS 10.0, *)
    init(isReturnImage:Bool,cameraName:String,resolutionPreset:String,metaTypes:[AVMetadataObject.ObjectType]) {
        super.init()
        self.isReturnImage = isReturnImage
        self.cameraName = cameraName
        self.resolutionPreset = RBarcodeCameraConfiguration.getResolutionPresetForString(preset: resolutionPreset)
        self.metaTypes = metaTypes
        self.timeInterval = Date().milliStamp
    }
    
    
    func open() {
        captureSession = AVCaptureSession()
        captureDevice = AVCaptureDevice(uniqueID: cameraName)
        
        captureVideoInput = try? AVCaptureDeviceInput(device: captureDevice)
        if(captureVideoInput == nil){
            return
        }
        captureVideoOutput = AVCaptureVideoDataOutput()
        captureVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:kCVPixelFormatType_32BGRA] as [String:Any]
        captureVideoOutput.alwaysDiscardsLateVideoFrames = true
        captureVideoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "preview buffer"))
        
        let connection:AVCaptureConnection=AVCaptureConnection(inputPorts: captureVideoInput.ports, output: captureVideoOutput)
        
        if(captureDevice.position == AVCaptureDevice.Position.front){
            connection.isVideoMirrored = true
        }
        
        if(connection.isVideoOrientationSupported){
            connection.videoOrientation = AVCaptureVideoOrientation.portrait
        }
        if captureSession.canAddInput(captureVideoInput) {
            captureSession.addInputWithNoConnections(captureVideoInput)
        }
        if captureSession.canAddOutput(captureVideoOutput) {
            captureSession.addOutputWithNoConnections(captureVideoOutput)
        }
        
        metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        }
        let layer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //扫码区域的大小
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        setMetadataObjects(metaTypes: nil)
        captureSession.addConnection(connection)
        self.setCaptureSessionPreset(resolutionsPreset: self.resolutionPreset)
    }
    
    func setMetadataObjects(metaTypes:[AVMetadataObject.ObjectType]?){
        if(metaTypes != nil){
            self.metaTypes = metaTypes
        }
        let availableTypes = metadataOutput.availableMetadataObjectTypes
        var resultAvailableTypes = [AVMetadataObject.ObjectType]()
        for type in self.metaTypes {
            if(availableTypes.contains(type)){
                resultAvailableTypes.append(type)
            }
        }
        metadataOutput.metadataObjectTypes=resultAvailableTypes
    }
    
    @available(iOS 9.0, *)
    func setCaptureSessionPreset(resolutionsPreset:ResolutionPreset) {
        switch resolutionPreset {
        case .max:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.high) {
                captureSession.sessionPreset = AVCaptureSession.Preset.high
                previewSize = CGSize(width: Double(captureDevice.activeFormat.highResolutionStillImageDimensions.width), height: Double(captureDevice.activeFormat.highResolutionStillImageDimensions.height))
                latestConverter = RBarcodePixelConverter.init(size: CGFloat(captureDevice.activeFormat.highResolutionStillImageDimensions.width), height: CGFloat(captureDevice.activeFormat.highResolutionStillImageDimensions.height))
            }
        case .ultraHigh:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd4K3840x2160) {
                captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
                previewSize = CGSize(width: 3840, height: 2160)
                latestConverter = RBarcodePixelConverter.init(size:3840, height:2160)
            }
        case .veryHigh:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080) {
                captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
                previewSize = CGSize(width: 1920, height: 1080)
                latestConverter = RBarcodePixelConverter.init(size:1920, height:1080)
            }
        case .high:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720) {
                captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
                previewSize = CGSize(width: 1280, height: 720)
                latestConverter = RBarcodePixelConverter.init(size:1280 , height:720)
            }
        case .medium:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.medium) {
                captureSession.sessionPreset = AVCaptureSession.Preset.medium
                previewSize = CGSize(width: 640, height: 480)
                latestConverter = RBarcodePixelConverter.init(size:640 , height:480)
            }
        case .low:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.cif352x288) {
                captureSession.sessionPreset = AVCaptureSession.Preset.cif352x288
                previewSize = CGSize(width: 352, height: 288)
                latestConverter = RBarcodePixelConverter.init(size:352 , height:288)
            }
        default:
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.low) {
                captureSession.sessionPreset = AVCaptureSession.Preset.low
                previewSize = CGSize(width: 352, height: 288)
                latestConverter = RBarcodePixelConverter.init(size:352 , height:288)
            }else{
                print("没有找到合适的分辨率，请换台手机重试\nYou can try to change your phone")
                //               @throws NSError(domain: NSCocoaErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey:"No capture session available for current capture session."])
            }
        }
    }
    
    func startScan() {
        if(!captureSession.isRunning){
            captureSession.startRunning()
        }
        
    }
    
    func stopScan(){
        if(captureSession.isRunning){
            captureSession.stopRunning()
        }
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if latestPixelBuffer == nil { return nil}
        
        return latestConverter?.convertResult(CMSampleBufferGetImageBuffer(latestPixelBuffer!))
    }
    
    
    func close(){
        if(captureSession != nil){
            captureSession.stopRunning()
            
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            
            for output in captureSession.outputs {
                captureSession.removeOutput(output)
            }
        }
        
    }
    
    //设置手电筒
    func enableTorch(b:Bool) throws ->Bool{
        try captureDevice!.lockForConfiguration()
        
        if(captureDevice.hasFlash){
            captureDevice.flashMode = b ? AVCaptureDevice.FlashMode.on : AVCaptureDevice.FlashMode.off
            captureDevice.torchMode = b ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
        }
        captureDevice.unlockForConfiguration()
        return b
    }
    
    //获取手电筒状态
    func isTorchOn() throws -> Bool {
        try captureDevice!.lockForConfiguration()
        var isTorchOn:Bool!
        if(captureDevice.hasFlash){
            isTorchOn = captureDevice.flashMode == AVCaptureDevice.FlashMode.on
                && captureDevice.torchMode == AVCaptureDevice.TorchMode.on
        }else{
            isTorchOn = false
        }
        captureDevice!.unlockForConfiguration()
        return isTorchOn
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if(output == captureVideoOutput){
            
            self.latestPixelBuffer = sampleBuffer
            switch UIDevice.current.orientation {
            case .landscapeRight:
                connection.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                connection.videoOrientation = .portrait
            }
            
            if(onFrameAvailable != nil){
                onFrameAvailable?()
            }
        }
    }
    
    func requestFocus(_ x:NSNumber,y:NSNumber,width:NSNumber,height:NSNumber) throws ->Bool{
        if(captureDevice.isFocusPointOfInterestSupported && captureDevice.isFocusModeSupported(.autoFocus)){
            try captureDevice!.lockForConfiguration()
            captureDevice.focusMode = .autoFocus
            captureDevice.focusPointOfInterest=CGPoint(x: x.doubleValue,y: y.doubleValue)
            captureDevice!.unlockForConfiguration()
        }else{
            return false
        }
        return false
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if isReturnImage==true {
            let millisecond = Date().milliStamp
            if Int(millisecond)! - Int(timeInterval!)! > 2000 {
                if(metadataObjects.count>0){
                    timeInterval = millisecond
                    let imageBuffer = CMSampleBufferGetImageBuffer(latestPixelBuffer!)! as CVPixelBuffer
                    CVPixelBufferLockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));
                    
                    let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)!
                    let bytePerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
                    let width  = CVPixelBufferGetWidth(imageBuffer)
                    let height = CVPixelBufferGetHeight(imageBuffer)
                    //               let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    
                    let cgContext = CGContext(data: baseAddress,width: width,height: height,bitsPerComponent: 8,bytesPerRow: bytePerRow,space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
                    let cgImage = cgContext!.makeImage()
                    let image = UIImage(cgImage: cgImage!)
                    metaCallBack?(metadataObjects,image.jpegData(compressionQuality: 0.8)! as NSData)
                }
            }
        }else{
            if metadataObjects.count>0 {
                metaCallBack?(metadataObjects,nil)
            }
        }
    }
}

extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}
