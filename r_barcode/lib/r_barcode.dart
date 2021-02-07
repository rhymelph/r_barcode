library r_barcode;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_barcode/r_barcode_exception.dart';
import 'dart:math' as math;

export 'r_barcode_indicator.dart';

part 'r_barcode_format.dart';

part 'r_barcode_camera.dart';

part 'r_barcode_result.dart';

part 'r_barcode_frame.dart';

const _kPluginType = 'com.rhyme_lph/r_barcode';

/// 二维码扫描插件
/// [Email]  rhymelph@gmail.com
/// [Github] http://github.com/rhymelph
///
/// 该类为所有相机的主要插件方法
/// 用于与原生进行通信
///
class RBarcode {
  static const MethodChannel _channel = const MethodChannel(_kPluginType);
  static List<RBarcodeFormat> _globalFormat;

  /// 初始化二维码引擎
  /// [formats] 支持的那些格式的二维码
  /// [isDebug] 是否为debug模式
  /// [isReturnImage]是否需要返回扫描成功后的图片
  static Future<void> initBarcodeEngine({
    List<RBarcodeFormat> formats: RBarcodeFormat.kAll,
    bool isDebug,
    bool isReturnImage: false,
  }) {
    _globalFormat = formats;
    return _channel.invokeMethod('initBarcodeEngine', {
      'formats': formats?.map((e) => e._value)?.toList(),
      'isDebug': isDebug,
      'isReturnImage': isReturnImage,
    });
  }

  /// 获取所有可用的相机
  ///
  /// 返回相机列表 , 用于相机的初始化 [RBarcodeCameraController]
  static Future<List<RBarcodeCameraDescription>>
      availableBarcodeCameras() async {
    try {
      final List<Map<dynamic, dynamic>> cameras = await _channel
          .invokeListMethod<Map<dynamic, dynamic>>('availableCameras');
      return cameras
          ?.map((Map<dynamic, dynamic> camera) => RBarcodeCameraDescription(
                name: camera['name'],
                lensDirection: _parseCameraLensDirection(camera['lensFacing']),
              ))
          ?.toList();
    } on PlatformException catch (e) {
      throw RBarcodeException(e.code, e.message);
    }
  }

  /// 设置需要扫描的二维码类型
  /// [formats] 二维码类型列表，详细见[RBarcodeFormat]
  static Future<void> _setBarcodeFormats(List<RBarcodeFormat> formats) async =>
      await _channel.invokeMethod("setBarcodeFormats",
          {"formats": formats.map((e) => e._value).toList()});

  /// 初始化相机
  /// [cameraName] 相机名字
  /// [resolutionPreset] 相机分辨率
  static Future<Map<String, dynamic>> _initialize(
          String cameraName, String resolutionPreset, bool isDebug) async =>
      await _channel.invokeMapMethod('initialize', <String, dynamic>{
        'cameraName': cameraName,
        'resolutionPreset': resolutionPreset,
        'isDebug': isDebug,
      });

  /// 关闭视图的时候调用
  static Future<void> _disposeTexture(int textureId) async =>
      await _channel.invokeMethod('dispose', {
        'textureId': textureId,
      });

  /// 是否打开闪光灯
  static Future<bool> _isTorchOn() async =>
      await _channel.invokeMethod('isTorchOn');

  /// 设置闪光灯
  /// [isTorchOn] 打开/关闭闪光灯
  static Future<bool> _enableTorch(bool isTorchOn) async =>
      await _channel.invokeMethod('enableTorch', {
        'isTorchOn': isTorchOn,
      });

  /// 停止扫码
  static Future<void> _stopScan() async =>
      await _channel.invokeMethod('stopScan');

  /// 开始扫码
  static Future<void> _startScan() async =>
      await _channel.invokeMethod('startScan');

  /// 请求聚焦
  ///
  /// [x] 对应屏幕的x轴
  static Future<void> _requestFocus(
          double x, double y, double width, double height) async =>
      await _channel.invokeMethod('requestFocus', {
        'x': x,
        'y': y,
        'width': width,
        'height:': height,
      });
}

/// 相机组件
/// [Email]  rhymelph@gmail.com
/// [Github] http://github.com/rhymelph
///
/// 用于在视图上显示组件
class RBarcodeCamera extends StatelessWidget {
  final RBarcodeCameraController controller;

  const RBarcodeCamera(this.controller, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Texture(textureId: controller._textureId)
        : Container(
            color: Colors.black,
          );
  }
}
