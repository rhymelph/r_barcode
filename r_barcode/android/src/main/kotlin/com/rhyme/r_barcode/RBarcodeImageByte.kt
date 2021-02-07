package com.rhyme.r_barcode

import android.media.Image
import android.os.Build
import androidx.annotation.RequiresApi
import com.rhyme.r_barcode.utils.ImageUtils


class RBarcodeImageByte {

    var yByte: ByteArray? = null
    var uByte: ByteArray? = null
    var vByte: ByteArray? = null
    var yB: Int? = null
    var uB: Int? = null
    var vB: Int? = null

    companion object {
        private var instance: RBarcodeImageByte? = null
            get() {
                if (field == null) {
                    field = RBarcodeImageByte()
                }
                return field
            }

        fun get(): RBarcodeImageByte {
            return instance!!
        }
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getByteFromImage(image: Image) {
        val yPlane = image.planes[0].buffer// 灰图
        val uPlane = image.planes[1].buffer // 颜色
        val vPlane = image.planes[2].buffer // 饱和度
        yB = yPlane!!.remaining()
        uB = uPlane!!.remaining()
        vB = vPlane!!.remaining()
        yByte = ByteArray(yB!!)
        yPlane.get(yByte!!, 0 ,yB!!)

        uByte = ByteArray(uB!!)
        uPlane.get(uByte!!, 0 ,uB!!)

        vByte = ByteArray(vB!!)
        vPlane.get(vByte!!, 0 ,vB!!)
    }


    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getScanByte(): ByteArray {
        return yByte!!
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getRotateImageByte(width: Int, height: Int): ByteArray {
        val byte = ByteArray(width * height * 3 / 2)
        ImageUtils.rotateYUVDegree90(getScanByte(), byte, width, height)
        return byte
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getResultScanByte(isReturnImage: Boolean): ByteArray {
        if (isReturnImage) {
            val byte = ByteArray(yB!! + uB!! + vB!!)
            System.arraycopy(yByte!!, 0, byte, 0, yB!!);
            System.arraycopy(uByte!!, 0, byte, yB!!, uB!!);
            System.arraycopy(vByte!!, 0, byte, yB!! + uB!!, vB!!);
            return byte
        }
        return getScanByte()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getResultRotateImageByte(width: Int, height: Int, isReturnImage: Boolean): ByteArray {
        if (isReturnImage) {
            val byte = ByteArray(width * height * 3 / 2)
            ImageUtils.rotateYUVDegree90(getResultScanByte(isReturnImage), byte, width, height)
            return byte
        }
        return getRotateImageByte(width, height)
    }


}