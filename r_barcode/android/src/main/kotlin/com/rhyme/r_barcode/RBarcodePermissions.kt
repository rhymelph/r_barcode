package com.rhyme.r_barcode

import android.Manifest.permission
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener

class RBarcodePermissions {
    interface PermissionsRegistry {
        fun addListener(handler: RequestPermissionsResultListener?)
    }

    interface ResultCallback {
        fun onResult(errorCode: String?, errorDescription: String?)
    }

    private var ongoing = false
    fun requestPermissions(
            activity: Activity,
            permissionsRegistry: PermissionsRegistry,
            callback: ResultCallback) {
        if (ongoing) {
            callback.onResult("cameraPermission", "Camera permission request ongoing")
        }
        if (!hasCameraPermission(activity)) {
            permissionsRegistry.addListener(
                    RBarcodeRequestPermissionsListener(object : ResultCallback {
                        override fun onResult(errorCode: String?, errorDescription: String?) {
                            ongoing = false
                            callback.onResult(errorCode, errorDescription)
                        }
                    }))
            ongoing = true
            ActivityCompat.requestPermissions(
                    activity, arrayOf(permission.CAMERA),
                    CAMERA_REQUEST_ID)
        } else { // Permissions already exist. Call the callback with success.
            callback.onResult(null, null)
        }
    }

    private fun hasCameraPermission(activity: Activity): Boolean {
        return (ContextCompat.checkSelfPermission(activity, permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED)
    }

    private class RBarcodeRequestPermissionsListener internal constructor(val callback: ResultCallback) : RequestPermissionsResultListener {
        override fun onRequestPermissionsResult(id: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
            if (id == CAMERA_REQUEST_ID) {
                if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    callback.onResult("RBarcodePermission", "MediaRecorderCamera permission not granted")
                } else {
                    callback.onResult(null, null)
                }
                return true
            }
            return false
        }

    }

    companion object {
        private const val CAMERA_REQUEST_ID = 9796
    }
}