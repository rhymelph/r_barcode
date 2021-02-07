package com.rhyme.r_barcode.service

import android.app.Service
import android.content.Intent
import android.graphics.Rect
import android.os.*
import com.google.zxing.BarcodeFormat
import com.google.zxing.DecodeHintType
import com.google.zxing.MultiFormatReader
import com.rhyme.r_barcode.utils.RBarcodeFormatUtils
import java.util.*
import kotlin.collections.ArrayList

class RBarcodeService : Service() {
    private val ALL_FORMATS: MutableList<BarcodeFormat> = ArrayList()
    private val mFormats: MutableList<BarcodeFormat>? = mutableListOf()
    private val reader: MultiFormatReader
    private var cropRect: Rect? = null

    /**
     * 初始化所有的编码格式
     */
    init {
        ALL_FORMATS.add(BarcodeFormat.AZTEC)
        ALL_FORMATS.add(BarcodeFormat.CODABAR)
        ALL_FORMATS.add(BarcodeFormat.CODE_39)
        ALL_FORMATS.add(BarcodeFormat.CODE_93)
        ALL_FORMATS.add(BarcodeFormat.CODE_128)
        ALL_FORMATS.add(BarcodeFormat.DATA_MATRIX)
        ALL_FORMATS.add(BarcodeFormat.EAN_8)
        ALL_FORMATS.add(BarcodeFormat.EAN_13)
        ALL_FORMATS.add(BarcodeFormat.ITF)
        ALL_FORMATS.add(BarcodeFormat.MAXICODE)
        ALL_FORMATS.add(BarcodeFormat.PDF_417)
        ALL_FORMATS.add(BarcodeFormat.QR_CODE)
        ALL_FORMATS.add(BarcodeFormat.RSS_14)
        ALL_FORMATS.add(BarcodeFormat.RSS_EXPANDED)
        ALL_FORMATS.add(BarcodeFormat.UPC_A)
        ALL_FORMATS.add(BarcodeFormat.UPC_E)
        ALL_FORMATS.add(BarcodeFormat.UPC_EAN_EXTENSION)

        val hints: MutableMap<DecodeHintType, Any?> = EnumMap<DecodeHintType, Any>(DecodeHintType::class.java)
        hints[DecodeHintType.POSSIBLE_FORMATS] = getFormats()
        reader = MultiFormatReader()
        reader.setHints(hints)
    }
    /**
     * 获取当前设置的编码格式集合
     *
     * @return 编码格式集合,默认为全部编码格式
     */
    private fun getFormats(): Collection<BarcodeFormat?>? {
        return mFormats ?: ALL_FORMATS
    }
    /**
     * 设置编码格式集合
     *
     * @param formats 编码格式集合
     */
    fun setFormats(formats: List<String>) {
        this.mFormats!!.clear()
        this.mFormats.addAll(RBarcodeFormatUtils.transitionFromFlutterCode(formats))
        val hints: MutableMap<DecodeHintType, Any?> = EnumMap<DecodeHintType, Any>(DecodeHintType::class.java)
        hints[DecodeHintType.POSSIBLE_FORMATS] = getFormats()
        reader.setHints(hints)
    }

    private val messenger: Messenger = Messenger(MessengerHandler())

    override fun onBind(intent: Intent?): IBinder? {
        return messenger.binder
    }


    open inner class MessengerHandler : Handler() {

        override fun handleMessage(msg: Message?) {
            super.handleMessage(msg)
            
        }
    }
}



