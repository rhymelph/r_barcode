package com.rhyme.r_barcode

import android.os.Handler
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

class RBarcodeEventChannel(messenger: BinaryMessenger?, eventChannelId: Long) : EventChannel.StreamHandler {
    private var eventSink: EventSink? = null
    private val scanViewType = "com.rhyme_lph/r_barcode"
    private val handle: Handler = Handler()

    init {
        EventChannel(messenger, scanViewType + "_" + eventChannelId + "/event").setStreamHandler(this)
    }

    fun sendMessage(msg: Any) {
        handle.post {
            eventSink?.success(msg)
        }
    }

    fun dispose() {
        eventSink = null
    }

    override fun onListen(arguments: Any?, sink: EventSink?) {
        eventSink = sink

    }

    override fun onCancel(arguments: Any?) {
        eventSink = null

    }
}