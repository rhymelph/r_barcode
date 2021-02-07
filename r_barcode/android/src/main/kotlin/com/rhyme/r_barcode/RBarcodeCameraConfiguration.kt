package com.rhyme.r_barcode

import android.app.Activity
import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import android.media.CamcorderProfile
import android.os.Build
import android.util.Size
import android.view.Surface
import android.view.WindowManager
import androidx.annotation.RequiresApi
import java.util.*

class RBarcodeCameraConfiguration {

    enum class ResolutionPreset {
        low, medium, high, veryHigh, ultraHigh, max
    }

    companion object {
        private var instance: RBarcodeCameraConfiguration? = null
            get() {
                if (field == null) {
                    field = RBarcodeCameraConfiguration()
                }
                return field
            }

        fun get(): RBarcodeCameraConfiguration {
            return instance!!
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun getOrientation(context: Context, cameraManager: CameraManager, cameraName: String): Int {
        val display = (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay
        val rotation = display.rotation
        var orientation: Int
        val expectPortrait: Boolean
        val characteristics = cameraManager.getCameraCharacteristics(cameraName)
        val lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING)
        if (lensFacing == CameraMetadata.LENS_FACING_BACK) { //后置摄像头
            when (rotation) {
                Surface.ROTATION_0 -> {
                    orientation = 90
                    expectPortrait = true
                }
                Surface.ROTATION_90 -> {
                    orientation = 0
                    expectPortrait = false
                }
                Surface.ROTATION_180 -> {
                    orientation = 270
                    expectPortrait = true
                }
                Surface.ROTATION_270 -> {
                    orientation = 180
                    expectPortrait = false
                }
                else -> {
                    orientation = 90
                    expectPortrait = true
                }
            }
        } else {
            when (rotation) {
                Surface.ROTATION_0 -> {
                    orientation = 270
                    expectPortrait = true
                }
                Surface.ROTATION_90 -> {
                    orientation = 180
                    expectPortrait = false
                }
                Surface.ROTATION_180 -> {
                    orientation = 0
                    expectPortrait = true
                }
                Surface.ROTATION_270 -> {
                    orientation = 90
                    expectPortrait = false
                }
                else -> {
                    orientation = 270
                    expectPortrait = true
                }
            }
        }
        val isPortrait = display.height > display.width
        if (isPortrait != expectPortrait) {
            orientation = (orientation + 270) % 360
        }
        return orientation
    }

    //获取可用的摄像头
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun getAvailableCameras(activity: Activity): List<Map<String, Any>>? {
        val cameraManager = activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val cameraNames = cameraManager.cameraIdList
        val cameras: MutableList<Map<String, Any>> = ArrayList()
        for (cameraName in cameraNames) {
            val details = HashMap<String, Any>()
            val characteristics = cameraManager.getCameraCharacteristics(cameraName)
            details["name"] = cameraName
            when (characteristics.get(CameraCharacteristics.LENS_FACING)) {
                CameraMetadata.LENS_FACING_FRONT -> details["lensFacing"] = "front"
                CameraMetadata.LENS_FACING_BACK -> details["lensFacing"] = "back"
                CameraMetadata.LENS_FACING_EXTERNAL -> details["lensFacing"] = "external"
            }
            cameras.add(details)
        }
        return cameras
    }

    //获取最佳可用的摄像机配置文件以进行分辨率预设
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getBestAvailableCamcorderProfileForResolutionPreset(
            cameraName: String, preset: ResolutionPreset): CamcorderProfile? {
        val cameraId = cameraName.toInt()
        return when (preset) {
            ResolutionPreset.max -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_HIGH)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_HIGH)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_2160P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.ultraHigh -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_2160P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.veryHigh -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.high -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.medium -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.low -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            else -> if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
            } else {
                throw IllegalArgumentException(
                        "No capture session available for current capture session.")
            }
        }
    }

    // 获取预览相机的尺寸
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    internal fun computeBestPreviewSize(cameraName: String, preset: ResolutionPreset): Size? {
//        var mPreset: ResolutionPreset = preset
//        if (preset.ordinal > ResolutionPreset.high.ordinal) {
//            mPreset = ResolutionPreset.high
//        }
        val profile: CamcorderProfile = getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset)!!
        return Size(profile.videoFrameWidth, profile.videoFrameHeight)
    }
}