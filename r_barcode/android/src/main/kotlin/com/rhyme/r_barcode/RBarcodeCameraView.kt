package com.rhyme.r_barcode

import android.app.Activity
import android.content.Context
import android.graphics.ImageFormat
import android.graphics.SurfaceTexture
import android.hardware.camera2.*
import android.hardware.camera2.params.MeteringRectangle
import android.media.ImageReader
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.util.Size
import android.view.Surface
import androidx.annotation.RequiresApi
import com.rhyme.r_barcode.RBarcodeCameraConfiguration.ResolutionPreset
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry.SurfaceTextureEntry
import java.util.*


@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class RBarcodeCameraView(private val activity: Activity,
                         texture: SurfaceTextureEntry,
                         private val cameraName: String,
                         resolutionPreset: String,
                         private val readerListener: ImageReader.OnImageAvailableListener) {
    private var imageStreamReader: ImageReader
    private val cameraManager: CameraManager = activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private var cameraDevice: CameraDevice? = null
    private var captureRequestBuilder: CaptureRequest.Builder? = null
    private var captureSession: CameraCaptureSession? = null
    private val previewSize: Size
    private val textureEntry: SurfaceTextureEntry = texture
    private val frameThreadHandler = HandlerThread("frame thread")
    private val frameHandler: Handler

    init {
        val preset = ResolutionPreset.valueOf(resolutionPreset)
        previewSize = RBarcodeCameraConfiguration.get().computeBestPreviewSize(cameraName, preset)!!
        imageStreamReader = ImageReader.newInstance(previewSize.width, previewSize.height, ImageFormat.YUV_420_888, 3)
        frameThreadHandler.start()
        frameHandler = Handler(frameThreadHandler.looper)
    }

    /**
     * 开启相机
     */
    fun open(result: MethodChannel.Result) {
        var isReplay = false
        cameraManager.openCamera(cameraName, object : CameraDevice.StateCallback() {
            override fun onOpened(camera: CameraDevice) {
                cameraDevice = camera
                try {
                    startPreview()
                } catch (e: CameraAccessException) {
                    isReplay = true
                    result.error("CameraAccessException", e.message, null)
                    return
                }
                val reply = mutableMapOf<String, Any>()
                reply["textureId"] = textureEntry.id()
                reply["previewWidth"] = previewSize.width
                reply["previewHeight"] = previewSize.height
                isReplay = true
                result.success(reply)
            }

            override fun onDisconnected(camera: CameraDevice) {
                print("相机链接失败")
                camera.close()
            }

            override fun onError(camera: CameraDevice, error: Int) {
                if (!isReplay) {
                    isReplay = true
                    result.error("$error", "Open Camera Error", null)
                }
            }

            override fun onClosed(camera: CameraDevice) {
                super.onClosed(camera)
                print("相机关闭")

            }
        }, null)
    }

    /**
     * 控制闪光灯
     * @param b 打开/关闭闪光灯
     */
    @Throws(CameraAccessException::class)
    fun enableTorch(b: Boolean) {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            cameraManager.setTorchMode(cameraName, b)
//        } else {
        captureRequestBuilder!!.set(
                CaptureRequest.FLASH_MODE, if (b) {
            CaptureRequest.FLASH_MODE_TORCH
        } else {
            CaptureRequest.FLASH_MODE_OFF
        })
//        captureRequestBuilder!!.set(CaptureRequest.CONTROL_AE_MODE, if (b) {
//            CaptureRequest.CONTROL_AE_MODE_ON
//        } else {
//            CaptureRequest.CONTROL_AE_MODE_OFF
//        })
        captureRequestBuilder!!.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
        captureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
//        }
    }


    /**
     * 是否开启闪光灯
     * @return  true 已打开  false 已关闭
     */
    fun isTorchOn(): Boolean {
        return try {
            val flashMode = captureRequestBuilder!!.get(CaptureRequest.FLASH_MODE)
            flashMode != null && flashMode != CaptureRequest.FLASH_MODE_OFF
        } catch (e: NullPointerException) {
            false
        }
    }

    /**
     * 打开预览框
     */
    fun startPreview() {
        createCaptureSession(imageStreamReader.surface)
        imageStreamReader.setOnImageAvailableListener(readerListener, frameHandler)

    }


    /**
     * 停止扫码
     */
    fun stopScan() {
        try {
            captureSession!!.stopRepeating()
        } catch (e: Exception) {

        }
    }

    /**
     * 开始扫码
     */
    fun startScan() {
        try {
            captureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, frameHandler)
        } catch (ex: java.lang.Exception) {
            ex.printStackTrace()
        }
        try {
            captureSession!!.capture(captureRequestBuilder!!.build(), null, frameHandler)
        } catch (ex: java.lang.Exception) {
            ex.printStackTrace()
        }
    }

    /**
     * 创建连接相机的会话
     */
    @Throws(CameraAccessException::class)
    private fun createCaptureSession(
            vararg surfaces: Surface) {
        //关闭上一次的链接
        closeCaptureSession()
        //构建相机请求
        captureRequestBuilder = cameraDevice!!.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)

        //创建flutter的texture
        val surfaceTexture: SurfaceTexture = textureEntry.surfaceTexture()
        //设置默认的大小
        surfaceTexture.setDefaultBufferSize(previewSize.width, previewSize.height)

        //添加视图到预览的相机绑定
        val flutterSurface = Surface(surfaceTexture)
        captureRequestBuilder!!.addTarget(flutterSurface)
        val remainingSurfaces = Arrays.asList(*surfaces)
        for (surface in remainingSurfaces) {
            captureRequestBuilder!!.addTarget(surface)
        }
        val surfaceList: MutableList<Surface> = ArrayList()
        surfaceList.addAll(remainingSurfaces)
        surfaceList.add(flutterSurface)

        cameraDevice!!.createCaptureSession(surfaceList, object : CameraCaptureSession.StateCallback() {
            override fun onConfigured(session: CameraCaptureSession) { //相机预览成功
                if (cameraDevice == null) { //                                rScanMessenger.send(
//              DartMessenger.EventType.ERROR, "The camera was closed during configuration.");
                    return
                }
                captureSession = session
                try {
                    captureRequestBuilder!!.set(
                            CaptureRequest.CONTROL_AF_MODE, CameraMetadata.CONTROL_AF_MODE_CONTINUOUS_PICTURE)
                    captureRequestBuilder!!.set(
                            CaptureRequest.CONTROL_AE_MODE, CameraMetadata.CONTROL_AE_MODE_ON_AUTO_FLASH)
                    captureRequestBuilder!!.set(
                            CaptureRequest.JPEG_ORIENTATION, RBarcodeCameraConfiguration.get().getOrientation(activity, cameraManager, cameraName))
                    captureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
                } catch (e: CameraAccessException) { //相机访问异常
                    e.printStackTrace()
//                        rScanMessenger.send(DartMessenger.EventType.ERROR, e.getMessage());
                }
            }

            override fun onConfigureFailed(cameraCaptureSession: CameraCaptureSession) { //相机预览失败
//                        rScanMessenger.send(
//                                DartMessenger.EventType.ERROR, "Failed to configure camera session.");
            }
        }, null)
    }

    /**
     * 关闭相机会话
     */
    private fun closeCaptureSession() {
        if (captureSession != null) {
            captureSession!!.close()
            captureSession = null
            textureEntry.release()
        }
    }

    /**
     * 关闭相机
     */
    fun close() {
        closeCaptureSession()
        if (cameraDevice != null) {
            cameraDevice!!.close()
            cameraDevice = null
        }
        imageStreamReader.close()
    }


    /**
     * 请求聚焦
     */
    fun requestFocus(rect: MeteringRectangle) {
        val rectangle = arrayOf<MeteringRectangle>(rect)
        // 对焦模式必须设置为auto
        captureRequestBuilder!!.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO)
        //AE 自动曝光
        captureRequestBuilder!!.set(CaptureRequest.CONTROL_AE_REGIONS, rectangle)
        //AF 自动对焦
        captureRequestBuilder!!.set(CaptureRequest.CONTROL_AF_REGIONS, rectangle)

        //触发聚焦
        try {
            captureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, frameHandler)
        } catch (ex: java.lang.Exception) {
            ex.printStackTrace()
        }

        //触发聚焦
        captureRequestBuilder!!.set(CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START)
        try {
            captureSession!!.capture(captureRequestBuilder!!.build(), null, frameHandler)
        } catch (ex: java.lang.Exception) {
            ex.printStackTrace()
        }
    }

}