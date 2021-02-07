package com.rhyme.r_barcode

import android.app.Activity
import android.content.Context
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.params.MeteringRectangle
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import io.flutter.view.TextureRegistry
import io.flutter.view.TextureRegistry.SurfaceTextureEntry

/** RBarcodePlugin */
public class RBarcodePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private var textureRegistry: TextureRegistry? = null
    private var messenger: BinaryMessenger? = null
    private var permissionsRegistry: RBarcodePermissions.PermissionsRegistry? = null

    private var rBarcodeCameraView: RBarcodeCameraView? = null
    private var rBarcodePermissions: RBarcodePermissions? = null
    private var rBarcodeEngine: RBarcodeEngine? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("rbarcode", "onAttachedToEngine")

        textureRegistry = flutterPluginBinding.textureRegistry
        messenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(messenger, pluginName)
        channel.setMethodCallHandler(this)

    }

    companion object {
        private const val pluginName: String = "com.rhyme_lph/r_barcode"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = RBarcodePlugin()
            val permissionsRegistry: RBarcodePermissions.PermissionsRegistry = object : RBarcodePermissions.PermissionsRegistry {
                override fun addListener(handler: RequestPermissionsResultListener?) {
                    registrar.addRequestPermissionsResultListener(handler)
                }
            }
            plugin.textureRegistry = registrar.textures()
            plugin.messenger = registrar.messenger()

            plugin.activity = registrar.activity()
            plugin.permissionsRegistry = permissionsRegistry
            val channel = MethodChannel(registrar.messenger(), pluginName)
            channel.setMethodCallHandler(plugin)
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initBarcodeEngine" -> {
                rBarcodeEngine = RBarcodeEngine()
                rBarcodeEngine!!.initBarCodeEngine(
                        call.argument<Boolean>("isDebug") ?: true,
                        call.argument<List<String>>("formats") ?: listOf(),
                        call.argument<Boolean>("isReturnImage") ?: false)
                result.success(null)
            }
            "availableCameras" -> {
                result.success(RBarcodeCameraConfiguration.get().getAvailableCameras(activity))
            }
            "initialize" -> {
                if (rBarcodeCameraView != null) {
                    rBarcodeCameraView!!.close()
                }
                if (rBarcodePermissions == null) {
                    rBarcodePermissions = RBarcodePermissions()
                }
                rBarcodePermissions!!.requestPermissions(
                        activity,
                        permissionsRegistry!!,
                        object : RBarcodePermissions.ResultCallback {
                            override fun onResult(errorCode: String?, errorDescription: String?) {
                                if (errorCode == null) {
                                    try {
                                        instantiateCamera(call, result)
                                    } catch (e: Exception) {
                                        handleException(e, result)
                                    }
                                } else {
                                    result.error(errorCode, errorDescription, null)
                                }
                            }
                        }
                )
            }
            "isTorchOn" -> {
                if (rBarcodeCameraView != null) {
                    result.success(rBarcodeCameraView!!.isTorchOn())
                } else {
                    result.error("Error", "Camera View is null", null)
                }
            }
            "enableTorch" -> {
                if (rBarcodeCameraView != null) {
                    val isTorchOn = call.argument<Boolean>("isTorchOn") ?: false
                    rBarcodeCameraView!!.enableTorch(isTorchOn)
                    result.success(rBarcodeCameraView!!.isTorchOn())
                } else {
                    result.error("Error", "Camera View is null", null)
                }
            }
            "dispose" -> {
                if (rBarcodeCameraView != null) {
                    rBarcodeCameraView!!.close()
                    result.success(null)
                } else {
                    result.error("Error", "Camera View is null", null)
                }

            }
            "setBarcodeFormats" -> {
                if (rBarcodeEngine != null) {
                    val formats = call.argument<List<String>>("formats") ?: arrayListOf()
                    rBarcodeEngine!!.setFormats(formats)
                    result.success(null)
                } else {
                    result.error("Error", "Camera View is null", null)
                }
            }
            "stopScan" -> {
                if (rBarcodeCameraView != null) {
                    rBarcodeCameraView!!.stopScan()
                    rBarcodeEngine!!.stopScan()
                    result.success(null)
                } else {
                    result.error("Error", "Camera View is null", null)
                }
            }
            "startScan" -> {
                if (rBarcodeCameraView != null) {
                    rBarcodeCameraView!!.startScan()
                    rBarcodeEngine!!.startScan()
                    result.success(null)
                } else {
                    result.error("Error", "Camera View is null", null)
                }
            }
            "setCropRect" -> {
                if (rBarcodeCameraView != null) {
                    rBarcodeEngine!!.setCropRect(call.argument<Int>("left")
                            ?: 0, call.argument<Int>("top") ?: 0,
                            call.argument<Int>("right") ?: 0, call.argument<Int>("bottom") ?: 0)
                    result.success(null)
                } else {
                    result.error("Error", "Camera View is null", null)
                }
            }
            "requestFocus" -> {
                if (rBarcodeCameraView != null) {
                    val windowManager: WindowManager = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                    val outMetrics: DisplayMetrics = DisplayMetrics()
                    windowManager.defaultDisplay.getMetrics(outMetrics)
                    val width = outMetrics.widthPixels
                    val height = outMetrics.heightPixels
                    val meteringWidth = 100
                    val meteringHeight = 100
                    val rect = MeteringRectangle((width - meteringWidth) / 2, (height - meteringHeight) / 2, meteringWidth, meteringHeight, 100)
                    rBarcodeCameraView!!.requestFocus(rect)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    //初始化相机
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun instantiateCamera(call: MethodCall, result: Result) {
//        if (BuildConfig.DEBUG && textureRegistry == null || rBarcodeEngine == null || rBarcodeCameraView != null || messenger != null) {
//            error("Assertion failed")
//        }

        val cameraName = call.argument<String>("cameraName")
        val resolutionPreset = call.argument<String>("resolutionPreset")
        val isDebug = call.argument<Boolean>("isDebug") ?: true
        val flutterSurfaceTexture: SurfaceTextureEntry = textureRegistry!!.createSurfaceTexture()
        rBarcodeEngine!!.initEventChannel(messenger!!, flutterSurfaceTexture.id(), isDebug)
        rBarcodeCameraView = RBarcodeCameraView(activity, flutterSurfaceTexture, cameraName!!, resolutionPreset!!, rBarcodeEngine!!.imageListener)
        rBarcodeCameraView!!.open(result)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("rbarcode", "onDetachedFromEngine")

        channel.setMethodCallHandler(null)

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d("rbarcode", "onReattachedToActivityForConfigChanges")
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("rbarcode", "onAttachedToActivity")
        activity = binding.activity
        permissionsRegistry = object : RBarcodePermissions.PermissionsRegistry {
            override fun addListener(handler: RequestPermissionsResultListener?) {
                binding.addRequestPermissionsResultListener(handler!!)
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d("rbarcode", "onDetachedFromActivityForConfigChanges")
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        channel.setMethodCallHandler(null)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            rBarcodeCameraView!!.stopScan()
        }
        Log.d("rbarcode", "onDetachedFromActivity")
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun handleException(exception: java.lang.Exception, result: Result) {
        if (exception is CameraAccessException) {
            result.error("CameraAccess", exception.message, null)
        }
        throw (exception as RuntimeException)
    }
}
