package com.rhyme.r_barcode.utils

class RBarcodeNative {
    companion object {
        private var instance: RBarcodeNative? = null
            get() {
                if (field == null) {
                    field = RBarcodeNative()
                }
                return field
            }

        fun get(): RBarcodeNative {
            return instance!!
        }
    }

    init {
        System.loadLibrary("native-r_barcode")
    }

//    external fun stringFromJNI(): String
    //压缩
    external fun compressYUV(src: ByteArray, width: Int, height: Int, dst: ByteArray, dstWidth: Int, dstHeight: Int, degree: Int, isMirror: Boolean, mode: Int)
    //裁剪
    external fun cropYUV(src: ByteArray, width: Int, height: Int, dst: ByteArray, dstWidth: Int, dstHeight: Int, left: Int, top: Int)
    //镜像
    external fun mirrorYUV(src: ByteArray, width: Int, height: Int, dst: ByteArray)
    //缩放
    external fun scaleYUV(src: ByteArray, width: Int, height: Int, dst: ByteArray, dstWidth: Int, dstHeight: Int,mode: Int)
    //旋转
    external fun rotateYUV(src: ByteArray, width: Int, height: Int, dst: ByteArray, degree: Int)
    //nv21转YUV
    external fun nv21ToYUV(src: ByteArray, width: Int, height: Int, dst: ByteArray)
    //YUV转nv21
    external fun yUVToNv21(src: ByteArray, width: Int, height: Int, dst: ByteArray)
    //YUV转ARGB
    external fun yUVToARGB(src:ByteArray, width: Int,height: Int,dst: ByteArray)
    
    external fun yUVFromImage(yb:ByteArray,ub:ByteArray,vb:ByteArray,yLength:Int,uLength:Int,vLength:Int):ByteArray
}