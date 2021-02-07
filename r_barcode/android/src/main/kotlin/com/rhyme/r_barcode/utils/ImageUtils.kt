package com.rhyme.r_barcode.utils

import android.graphics.*
import android.graphics.Bitmap.CompressFormat
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.lang.ref.WeakReference
import java.net.HttpURLConnection
import java.net.URL
import java.security.SecureRandom
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

object ImageUtils {
    internal fun nv212Flutter(image: ByteArray, width: Int, height: Int, isRotate: Boolean): ByteArray? {
//        val result = ByteArray(width * height * 4)
        return if (isRotate) {
            nv21ToBitmap(image, height, width)
//            RBarcodeNative.get().yUVToARGB(image, height, width, result)
        } else {
            val imageNv21 = ByteArray(width * height * 3 / 2)
            RBarcodeNative.get().nv21ToYUV(image, width, height, imageNv21)
            nv21ToBitmap(imageNv21, width, height)
//            RBarcodeNative.get().yUVToARGB(image, width, height, result)
        }
//        return result
    }

    private fun nv21ToBitmap(nv21: ByteArray, width: Int, height: Int): ByteArray? {
        var bitmap: Bitmap? = null
        try {
            val nv21R:WeakReference<ByteArray> = WeakReference<ByteArray>(ByteArray(width * height * 3 / 2))
            RBarcodeNative.get().yUVToNv21(nv21, width, height, nv21R.get()!!)
            val image = YuvImage(nv21R.get() ,ImageFormat.NV21, width, height, null)
            val stream = ByteArrayOutputStream()
            image.compressToJpeg(Rect(0, 0, width, height), 70, stream)
            val array: ByteArray = stream.toByteArray()
            stream.close()
            return array
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return byteArrayOf()
    }

    internal fun rotateYUVDegree90(data: ByteArray, dst: ByteArray, imageWidth: Int, imageHeight: Int) {
        RBarcodeNative.get().compressYUV(data, imageWidth, imageHeight, dst, imageWidth, imageHeight, 90, false, 0)
    }
//    internal fun rotateYDegree90(data: ByteArray, imageWidth: Int, imageHeight: Int): ByteArray? {
//        if (yuv == null || yuvWidth != imageWidth || yuvHeight != imageHeight) {
//            yuv = ByteArray(imageWidth * imageHeight)
//            yuvWidth = imageWidth
//            yuvHeight = imageHeight
//        }
//        // Rotate the Y luma
//        var i = 0
//        for (x in 0 until imageWidth) {
//            for (y in imageHeight - 1 downTo 0) {
//                yuv!![i] = data[y * imageWidth + x]
//                i++
//            }
//        }
//        return yuv
//    }
//
//    internal fun rotateYUV420Degree90(data: ByteArray, imageWidth: Int, imageHeight: Int): ByteArray? {
//        if (yuv == null || yuvWidth != imageWidth || yuvHeight != imageHeight) {
//            yuv = ByteArray(imageWidth * imageHeight * 3 / 2)
//            yuvWidth = imageWidth
//            yuvHeight = imageHeight
//        }
//        // Rotate the Y luma
//        var i = 0
//        for (x in 0 until imageWidth) {
//            for (y in imageHeight - 1 downTo 0) {
//                yuv!![i] = data[y * imageWidth + x]
//                i++
//            }
//        }
//        // Rotate the U and V color components 
//        i = imageWidth * imageHeight * 3 / 2 - 1
//        var x = imageWidth - 1
//        while (x > 0) {
//            for (y in 0 until imageHeight / 2) {
//                yuv!![i] = data[imageWidth * imageHeight + y * imageWidth + x]
//                i--
//                yuv!![i] = data[imageWidth * imageHeight + y * imageWidth + (x - 1)]
//                i--
//            }
//            x = x - 2
//        }
//        return yuv
//    }
//   

    internal fun loadBitmap(url: String): Bitmap? {
        return try {
            val myUrl = URL(url)
            val bitmap: Bitmap
            if (url.startsWith("https")) {
                val connection = myUrl.openConnection() as HttpsURLConnection
                connection.readTimeout = 6 * 60 * 1000
                connection.connectTimeout = 6 * 60 * 1000
                val tm = arrayOf<TrustManager>(MyX509TrustManager())
                val sslContext = SSLContext.getInstance("TLS")
                sslContext.init(null, tm, SecureRandom())
                // 从上述SSLContext对象中得到SSLSocketFactory对象
                val ssf = sslContext.socketFactory
                connection.sslSocketFactory = ssf
                connection.connect()
                bitmap = BitmapFactory.decodeStream(connection.inputStream)
            } else {
                val connection = myUrl.openConnection() as HttpURLConnection
                connection.readTimeout = 6 * 60 * 1000
                connection.connectTimeout = 6 * 60 * 1000
                connection.connect()
                bitmap = BitmapFactory.decodeStream(connection.inputStream)
            }
            bitmap
        } catch (e: Exception) {
//            RScanLog.d("ImageUtils loadBitmap error");
            null
        }
    }

    private class MyX509TrustManager : X509TrustManager {
        // 检查客户端证书
        @Throws(CertificateException::class)
        override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {
        }

        // 检查服务器端证书
        @Throws(CertificateException::class)
        override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {
        }

        // 返回受信任的X509证书数组
        override fun getAcceptedIssuers(): Array<X509Certificate>? {
            return null
        }
    }
}