package com.rhyme.r_barcode

import android.graphics.ImageFormat
import android.graphics.Rect
import android.media.Image
import android.media.ImageReader
import android.os.Build
import android.os.HandlerThread
import android.util.Log
import androidx.annotation.RequiresApi
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import com.rhyme.r_barcode.utils.ImageUtils
import com.rhyme.r_barcode.utils.RBarcodeFormatUtils
import io.flutter.plugin.common.BinaryMessenger
import java.lang.Exception
import java.util.*
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import kotlin.collections.ArrayList


class RBarcodeEngine {

    private var isDebug: Boolean? = true
    private fun log(msg: String) {
        if (isDebug!!) Log.d("RBarCodeEngine", msg)
    }

    private val ALL_FORMATS: MutableList<BarcodeFormat> = ArrayList()
    private val mFormats: MutableList<BarcodeFormat>? = mutableListOf()
    private val reader: MultiFormatReader

    //    private val scanner:ImageScanner
    private var eventChannel: RBarcodeEventChannel? = null
    private var isScan: Boolean = true
    private var cropRect: Rect? = null
    private var isReturnImage: Boolean = false
    private var threadHandler: HandlerThread = HandlerThread("RBarcodeThread")
    private val executor: Executor = Executors.newSingleThreadExecutor()

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
        threadHandler.start()
    }

    /**
     * 初始化解码引擎
     *
     * @param isDebug 是否为debug模式
     * @param formats 要设置的编码集合
     * @param isReturnImage 是否需要返回图片
     */
    fun initBarCodeEngine(isDebug: Boolean, formats: List<String>, isReturnImage: Boolean) {
        this.isDebug = isDebug
        this.isReturnImage = isReturnImage
        this.mFormats!!.clear()
        this.mFormats.addAll(RBarcodeFormatUtils.transitionFromFlutterCode(formats))
//        log(RBarcodeNative.get().stringFromJNI())
    }

    /**
     * 初始化Flutter事件通信工具
     *
     * @param messenger Flutter与原生通信的x信使
     * @param eventId 事件id
     */
    fun initEventChannel(messenger: BinaryMessenger, eventId: Long, isDebug: Boolean) {
        if (eventChannel != null) {
            eventChannel!!.dispose()
        } else {
            eventChannel = RBarcodeEventChannel(messenger, eventId)
        }
        this.isDebug = isDebug
    }

    /**
     * 设置扫码框
     *
     * @param left 左
     * @param top 上
     * @param right 右
     * @param bottom 下
     */
    fun setCropRect(left: Int, top: Int, right: Int, bottom: Int) {
        cropRect = Rect(left, top, right, bottom)
    }


    /**
     * 获取当前设置的编码格式集合
     *
     * @return 编码格式集合,默认为全部编码格式
     */
    private fun getFormats(): Collection<BarcodeFormat?> {
        return mFormats ?: ALL_FORMATS
    }

    private fun isOnlyQrCodeFormat(): Boolean {
        return getFormats().size == 1 && getFormats().contains(BarcodeFormat.QR_CODE)
    }

    /**
     * 设置编码格式集合
     *
     * @param formats 编码格式集合
     */
    fun setFormats(formats: List<String>) {
        log("setFormats ${formats.joinToString(separator = "\n")}")
        this.mFormats!!.clear()
        this.mFormats.addAll(RBarcodeFormatUtils.transitionFromFlutterCode(formats))
        val hints: MutableMap<DecodeHintType, Any?> = EnumMap<DecodeHintType, Any>(DecodeHintType::class.java)
        hints[DecodeHintType.POSSIBLE_FORMATS] = getFormats()
        reader.setHints(hints)
    }


    /**
     * 开始扫码
     */
    fun startScan() {
        isScan = true
    }

    /**
     * 关闭扫码
     */
    fun stopScan() {
        isScan = false
    }

    fun isScanning(): Boolean {
        return isScan
    }

    private var latestAcquireImageTime: Long = System.currentTimeMillis()
    private var latestScanSuccessTime: Long = System.currentTimeMillis()

    /**
     * 获取一帧的图片
     *
     * @param it 图片读取工具
     */
    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getImage(it: ImageReader): Image? {
        if (System.currentTimeMillis() - latestAcquireImageTime > 150L && System.currentTimeMillis() - latestScanSuccessTime > 150L) {
            latestAcquireImageTime = System.currentTimeMillis()
            val image = it.acquireLatestImage() ?: return null
            if (image.format != ImageFormat.YUV_420_888 || !isScan) {
                image.close()
                return null
            }
            return image
        } else {
            return null
        }
    }

//    private lateinit var imageByte: WeakReference<ByteArray>

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    val imageListener: ImageReader.OnImageAvailableListener = ImageReader.OnImageAvailableListener {
        executor.execute {
            val image = getImage(it) ?: return@execute
            val width = image.width
            val height = image.height
            val yBuffer = image.planes[0].buffer// 灰图
            val yLen = yBuffer!!.remaining() // 灰图大小
            val yByte = ByteArray(yLen)
//        var rotateYByte: ByteArray? // y图旋转
            yBuffer.get(yByte, 0, yLen) // y图 byte获取
            yBuffer.clear()

            val uBuffer = image.planes[1].buffer // 颜色
            val uLen = uBuffer!!.remaining() // 颜色图大小
            val uByte = ByteArray(uLen) // 颜色图 byte
            uBuffer.get(uByte, 0, uLen) // 颜色图 byte获取
            uBuffer.clear()

            val vBuffer = image.planes[2].buffer // 饱和度
            val vLen = vBuffer!!.remaining() //饱和度图大小
            val vByte = ByteArray(vLen) //饱和度 byte
            vBuffer.get(vByte, 0, vLen) // 饱和度 byte获取
            vBuffer.clear()
            image.close()
            decodeImageResult(RBarcodeEntity(yByte, uByte, vByte, yLen, uLen, vLen, width, height))
        }
    }


    private fun decodeImageResult(entity: RBarcodeEntity) {
        val firstTime = System.currentTimeMillis()
        var decodeResult: Result? = null
        var isRotate = false
        try {
            decodeResult = decodeImage(entity.y, entity.width, entity.height)
            log("thread:" + Thread.currentThread() + "  decodeImage first:" + (System.currentTimeMillis() - firstTime) + "ms")
            val secondTime = System.currentTimeMillis()
            if (decodeResult == null && !isOnlyQrCodeFormat()) {
                // y图旋转
                val rotateYByte = ByteArray(entity.width * entity.height * 3 / 2)
                ImageUtils.rotateYUVDegree90(entity.y, rotateYByte, entity.width, entity.height)
                decodeResult = decodeImage(rotateYByte, entity.width, entity.height)
                log("thread:" + Thread.currentThread() + "  decodeImage second:" + (System.currentTimeMillis() - secondTime) + "ms")
                isRotate = true
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (decodeResult != null) {
            log("scan image success!!!!!")
            latestScanSuccessTime = System.currentTimeMillis()

            if (isReturnImage) {
                //需要返回原图
                var resultByte: ByteArray? = null
                if (isRotate) {
                    //返回 旋转后的原图
                    val sourceByte = ByteArray(entity.yLen + entity.uLen + entity.vLen)
                    resultByte = ByteArray(entity.width * entity.height * 3 / 2)
                    System.arraycopy(entity.y, 0, sourceByte, 0, entity.yLen)
                    System.arraycopy(entity.u, 0, sourceByte, entity.yLen, entity.uLen)
                    System.arraycopy(entity.v, 0, sourceByte, entity.yLen + entity.uLen, entity.vLen)
                    ImageUtils.rotateYUVDegree90(sourceByte, resultByte, entity.width, entity.height)
                } else {
                    // 返回 未旋转的原图
                    resultByte = ByteArray(entity.yLen + entity.uLen + entity.vLen)
                    System.arraycopy(entity.y, 0, resultByte, 0, entity.yLen)
                    System.arraycopy(entity.u, 0, resultByte, entity.yLen, entity.uLen)
                    System.arraycopy(entity.v, 0, resultByte, entity.yLen + entity.uLen, entity.vLen)
                }

                val byte: ByteArray? = ImageUtils.nv212Flutter(resultByte, entity.width, entity.height, isRotate)
                resultToMap(decodeResult, byte!!, entity.width, entity.height, isRotate)?.let { it1 ->
                    if (!isScan) return@let
                    eventChannel?.sendMessage(it1)
                }
            } else {
                resultToMapNoImage(decodeResult, entity.width, entity.height, isRotate)?.let { it1 ->
                    if (!isScan) return@let
                    eventChannel?.sendMessage(it1)
                }
            }
        }
        log("thread:" + Thread.currentThread() + "  decodeImage time consuming:" + (System.currentTimeMillis() - firstTime) + "ms")

    }

    /**
     * 解析图片
     *
     * @param byte 二维码二值
     * @param width 二维码宽度
     * @param height 二维码高度
     * @return 返回二维码扫描得到的内容
     */
    private fun decodeImage(byte: ByteArray, width: Int, height: Int): Result? {
        var dataWidth = width
        var dataHeight = height
        if (cropRect != null) {
            dataWidth = cropRect!!.right - cropRect!!.left
            dataHeight = cropRect!!.bottom - cropRect!!.top
        }

        var result: Result? = null
        val source = PlanarYUVLuminanceSource(byte,
                width,
                height,
                cropRect?.left ?: 0,
                cropRect?.top ?: 0,
                dataWidth,
                dataHeight,
                false)
        val bitmap = BinaryBitmap(HybridBinarizer(source))
        try {
            result = reader.decodeWithState(bitmap)
        } catch (ex: Exception) {
//            reader.reset()
        }
//        try {
//            result = reader.decodeWithState(BinaryBitmap(HybridBinarizer(source)))
//        } catch (ex: Exception) {
//        } finally {
//            reader.reset()
//        }
//        if (result == null) {
//            val invertedSource = source.invert()
//            try {
//                result = reader.decodeWithState(BinaryBitmap(HybridBinarizer(invertedSource)))
//            } catch (ex: Exception) {
//            } finally {
//                reader.reset()
//            }
//        }
        return result
    }

    /**
     * 返回给Flutter所需要的内容(有图片)
     *
     * @param result 二维码扫描的得到的内容
     * @param image 图片二值
     * @param width 宽度
     * @param height 高度
     * @param isRotate 是否旋转过
     * @return Flutter 所需要的内容
     */
    private fun resultToMap(result: Result?, image: ByteArray, width: Int, height: Int, isRotate: Boolean): Map<String, Any>? {
        if (result == null) return null
        val data: MutableMap<String, Any> = HashMap()
        data["text"] = result.text
        data["format"] = RBarcodeFormatUtils.transitionToFlutterCode(result.barcodeFormat)
        data["image"] = image
        if (result.resultPoints != null) {
            val resultPoints: MutableList<Map<String, Any>> = java.util.ArrayList()
            for (point in result.resultPoints) {
                val pointMap: MutableMap<String, Any> = HashMap()
                if (isRotate) {
                    pointMap["x"] = (height - point.x) / height
                    pointMap["y"] = (width - point.y) / width
                } else {
                    pointMap["y"] = point.x / width
                    pointMap["x"] = (height - point.y) / height
                }
                resultPoints.add(pointMap)
            }
            data["points"] = resultPoints
        }
        return data
    }

    /**
     * 返回给Flutter所需要的内容(无图片)
     *
     * @param result 二维码扫描的得到的内容
     * @param width 宽度
     * @param height 高度
     * @param isRotate 是否旋转过
     * @return Flutter 所需要的内容
     */
    private fun resultToMapNoImage(result: Result?, width: Int, height: Int, isRotate: Boolean): Map<String, Any>? {
        if (result == null) return null
        val data: MutableMap<String, Any> = HashMap()
        data["text"] = result.text
        data["format"] = RBarcodeFormatUtils.transitionToFlutterCode(result.barcodeFormat)
        if (result.resultPoints != null) {
            val resultPoints: MutableList<Map<String, Any>> = java.util.ArrayList()
            for (point in result.resultPoints) {
                val pointMap: MutableMap<String, Any> = HashMap()
                if (isRotate) {
                    pointMap["x"] = point.x / height
                    pointMap["y"] = point.y / width
                } else {
                    pointMap["y"] = point.x / width
                    pointMap["x"] = (height - point.y) / height
                }
                resultPoints.add(pointMap)
            }
            data["points"] = resultPoints
        }
        return data
    }

}