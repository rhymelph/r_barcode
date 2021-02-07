part of 'r_barcode.dart';

/// 相机对应的相关介绍，通过[RBarcode.availableBarcodeCameras]获取
///
/// [name] 相机名
/// [lensDirection] 相机方向
class RBarcodeCameraDescription {
  RBarcodeCameraDescription({
    this.name,
    this.lensDirection,
  });

  final String name;
  final RBarcodeCameraLensDirection lensDirection;

  @override
  bool operator ==(Object o) {
    return o is RBarcodeCameraDescription &&
        o.name == name &&
        o.lensDirection == lensDirection;
  }

  @override
  int get hashCode {
    return hashValues(name, lensDirection);
  }

  @override
  String toString() {
    return '$runtimeType($name, $lensDirection)';
  }
}

/// 相机方向
/// [RBarcodeCameraLensDirection.front] 前置相机
/// [RBarcodeCameraLensDirection.back] 后置相机
/// [RBarcodeCameraLensDirection.external] 扩展相机
enum RBarcodeCameraLensDirection { front, back, external }

RBarcodeCameraLensDirection _parseCameraLensDirection(String string) {
  switch (string) {
    case 'front':
      return RBarcodeCameraLensDirection.front;
    case 'back':
      return RBarcodeCameraLensDirection.back;
    case 'external':
      return RBarcodeCameraLensDirection.external;
  }
  throw ArgumentError('Unknown CameraLensDirection value');
}

/// Affect the quality of video recording and image capture:
///
/// If a preset is not available on the camera being used a preset of lower quality will be selected automatically.
enum RBarcodeCameraResolutionPreset {
  /// 352x288 on iOS, 240p (320x240) on Android
  low,

  /// 480p (640x480 on iOS, 720x480 on Android)
  medium,

  /// 720p (1280x720)
  high,

  /// 1080p (1920x1080)
  veryHigh,

  /// 2160p (3840x2160)
  ultraHigh,

  /// The highest resolution available.
  max,
}

/// Returns the resolution preset as a String.
String _serializeResolutionPreset(
    RBarcodeCameraResolutionPreset resolutionPreset) {
  switch (resolutionPreset) {
    case RBarcodeCameraResolutionPreset.max:
      return 'max';
    case RBarcodeCameraResolutionPreset.ultraHigh:
      return 'ultraHigh';
    case RBarcodeCameraResolutionPreset.veryHigh:
      return 'veryHigh';
    case RBarcodeCameraResolutionPreset.high:
      return 'high';
    case RBarcodeCameraResolutionPreset.medium:
      return 'medium';
    case RBarcodeCameraResolutionPreset.low:
      return 'low';
  }
  throw ArgumentError('Unknown ResolutionPreset value');
}

/// 二维码扫描对应的相机内容
///
/// [isInitialized] 是否已经初始化
/// [errorDescription] 是否有错误
/// [previewSize] 错误内容
/// [isTorchOn] 是否开启闪光灯
/// [formats] 支持的二维码编码格式
/// [description] 相机对应方向
/// [resolutionPreset] 分辨率
class RBarcodeCameraValue {
  //camera is initialized.
  final bool isInitialized;

  //error info.
  final String errorDescription;

  // preview size.
  final Size previewSize;

  // Is torch open.
  final bool isTorchOn;

  // barcode format.
  final List<RBarcodeFormat> formats;

  // camera description
  final RBarcodeCameraDescription description;

  // camera resolution preset
  final RBarcodeCameraResolutionPreset resolutionPreset;

  final bool isDebug;

  const RBarcodeCameraValue(
      {this.isInitialized,
      this.errorDescription,
      this.previewSize,
      this.formats,
      this.isTorchOn,
      this.description,
      this.resolutionPreset,
      this.isDebug});

  const RBarcodeCameraValue.uninitialized()
      : this(
          isInitialized: false,
          isTorchOn: false,
          isDebug: true,
        );

  double get aspectRatio => previewSize.height / previewSize.width;

  bool get hasError => errorDescription != null;

  RBarcodeCameraValue copyWith({
    bool isInitialized,
    String errorDescription,
    Size previewSize,
    bool isTorchOn,
    List<RBarcodeFormat> formats,
    RBarcodeCameraDescription description,
    RBarcodeCameraResolutionPreset resolutionPreset,
    bool isDebug,
  }) {
    return RBarcodeCameraValue(
      isInitialized: isInitialized ?? this.isInitialized,
      errorDescription: errorDescription ?? this.errorDescription,
      previewSize: previewSize ?? this.previewSize,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      formats: formats ?? this.formats,
      description: description ?? this.description,
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      isDebug: isDebug ?? this.isDebug,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'isInitialized: $isInitialized, '
        'errorDescription: $errorDescription, '
        'previewSize: $previewSize, '
        'isTorchOn: $isTorchOn, '
        'formats: $formats)';
  }
}

/// 二维码扫描相机的控制器
///
class RBarcodeCameraController extends ValueNotifier<RBarcodeCameraValue> {
  RBarcodeCameraController(
    RBarcodeCameraDescription description,
    RBarcodeCameraResolutionPreset resolutionPreset, {
    List<RBarcodeFormat> formats,
    bool isDebug,
  })  : assert(description != null),
        assert(resolutionPreset != null),
        super(RBarcodeCameraValue.uninitialized().copyWith(
          description: description,
          resolutionPreset: resolutionPreset,
          formats: formats,
          isDebug: isDebug ?? true,
        ));

  bool _isDisposed = false; // when the widget dispose will set true
  Completer<void> _creatingCompleter; // when the camera create finish
  int _textureId; // init finish will return id
  StreamSubscription<dynamic> _resultSubscription; //the result subscription
  RBarcodeResult result;
  bool isScanning;

  /// 初始化相机控制器
  Future<void> initialize() async {
    if (_isDisposed) return Future<void>.value();
    _creatingCompleter = Completer();
    try {
      final Map<String, dynamic> reply = await RBarcode._initialize(
          value.description.name,
          _serializeResolutionPreset(value.resolutionPreset),
      value.isDebug);
      _textureId = reply['textureId'];

      await setBarcodeFormats(value.formats ?? RBarcode._globalFormat);

      value = value.copyWith(
          isInitialized: true,
          previewSize: Size(reply['previewWidth'].toDouble(),
              reply['previewHeight'].toDouble()),
          formats: value.formats ?? RBarcode._globalFormat);

      _resultSubscription = EventChannel('${_kPluginType}_$_textureId/event')
          .receiveBroadcastStream()
          .listen(_handleResult);
      isScanning = true;
    } on PlatformException catch (e) {
      //当发生权限问题的异常时会抛出
      throw RBarcodeException(e.code, e.message);
    }
    _creatingCompleter.complete();
    return _creatingCompleter.future;
  }

  /// 是否打开闪光灯
  Future<bool> isTorchOn() async {
    bool isTorchOn = await RBarcode._isTorchOn();
    value = value.copyWith(isTorchOn: isTorchOn);
    return isTorchOn;
  }

  /// 设置闪光灯
  /// [isTorchOn] 打开/关闭闪光灯
  Future<bool> setTorchOn(bool isTorchOn) async {
    bool result = await RBarcode._enableTorch(isTorchOn);
    value = value.copyWith(isTorchOn: result);
    return result;
  }

  /// 开启扫码
  Future<void> startScan() async {
    if (isScanning == false) {
      isScanning = true;
      await RBarcode._startScan();
    }
  }

  /// 停止扫码
  Future<void> stopScan() async {
    if (isScanning == true) {
      isScanning = false;
      await RBarcode._stopScan();
    }
  }

  /// 请求聚焦
  Future<void> requestFocus(
      double x, double y, double width, double height) async {
    await RBarcode._requestFocus(x, y, width, height);
  }

  /// 设置想要的编码格式的二维码
  ///
  /// [formats] 编码格式列表
  Future<void> setBarcodeFormats(List<RBarcodeFormat> formats) async {
    await RBarcode._setBarcodeFormats(formats);
    value = value.copyWith(formats: formats);
    return result;
  }

  //处理返回值
  void _handleResult(event) {
    if (_isDisposed) return;
    this.result = RBarcodeResult.formMap(event);
    notifyListeners();
  }

  // 清除返回值
  void clearResult() {
    this.result = null;
    notifyListeners();
  }

  // 关闭
  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    super.dispose();
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      await RBarcode._disposeTexture(_textureId);
      await _resultSubscription?.cancel();
    }
  }
}
