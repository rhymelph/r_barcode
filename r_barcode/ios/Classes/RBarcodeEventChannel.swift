//
//  RBarcodeEventChannel.swift
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/7.
//  rhymelph@gmail.com
//

import Foundation


class RBarcodeEventChannel: NSObject , FlutterStreamHandler {
    var events: FlutterEventSink?
    
    init(textureId:Int64,messenger:FlutterBinaryMessenger) {
        super.init()
        let eventChannel = FlutterEventChannel(name: "com.rhyme_lph/r_barcode_\(textureId)/event", binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
    }
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        events = nil
        return nil
    }
    
    func sendMessage(msg:Any?) {
        events?(msg)
    }
    
}
