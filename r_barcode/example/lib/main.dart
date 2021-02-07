import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_barcode/r_barcode.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  RBarcodeCameraController _controller;
  BarcodeScanStatus _scanStatus = BarcodeScanStatus.scan;
  BarcodeScanType _scanType = BarcodeScanType.qrCode;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller?.startScan();
      setState(() {
        _scanStatus = BarcodeScanStatus.scan;
      });
    } else if (state == AppLifecycleState.paused) {
      _controller?.stopScan();
      setState(() {
        _scanStatus = BarcodeScanStatus.stop;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    RBarcode.initBarcodeEngine(isDebug: true, isReturnImage: true)
        .then((value) {
      RBarcode.availableBarcodeCameras().then((value) {
        print('摄像头：${value.toString()}');
        try {
          _controller = RBarcodeCameraController(
              value[0], RBarcodeCameraResolutionPreset.max,
              formats: [RBarcodeFormat.QRCode], isDebug: false)
            ..addListener(_handleResultListener)
            ..initialize().then(_handleInitListener);
        } catch (e) {
          print(e);
        }
      });
    });
  }

  FutureOr _handleInitListener(void value) {
    if (_controller?.value?.isInitialized == true) {
      setState(() {});
    }
  }

  RBarcodeResult _result;

  //处理结果返回
  void _handleResultListener() {
    if (_controller?.result != _result) {
      HapticFeedback.vibrate();
      _handleScanStop();
    }
  }

  //处理编码格式改变
  void _handleScanTypeChange(BarcodeScanType i) {
    if (_scanType == i) return;
    setState(() {
      _scanType = i;
    });
    if (_scanType == BarcodeScanType.barCode) {
      // _controller.setBarcodeFormats([RBarcodeFormat.Code128]);
      _controller?.setBarcodeFormats(RBarcodeFormat.kLineFormats);
//      [RBarcodeFormat.Code39, RBarcodeFormat.Code93, RBarcodeFormat.Codabar]);
//      [RBarcodeFormat.ITF, RBarcodeFormat.DataMatrix, RBarcodeFormat.UPCA]);
    } else {
      _controller?.setBarcodeFormats([RBarcodeFormat.QRCode]);
    }
    HapticFeedback.vibrate();
  }

  //处理暂停扫描
  void _handleScanStop() {
    _controller?.stopScan();
    setState(() {
      _scanStatus = BarcodeScanStatus.stop;
      _result = _controller?.result;
    });
    print(_controller?.result.toString());
  }

  //处理重新进入扫描状态
  void _handleScanStart() {
    HapticFeedback.heavyImpact();
    setState(() {
      _scanStatus = BarcodeScanStatus.scan;
      _result = null;
      _controller?.clearResult();
    });
    _controller?.startScan();
  }

  void _handleFlashToggle() async {
    await _controller?.setTorchOn(!(_controller?.value.isTorchOn ?? false));
    HapticFeedback.heavyImpact();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: _controller != null && (_controller.value.isInitialized ?? false)
          ? Stack(
              children: <Widget>[
                _buildCamera(),
                _buildToolBar(),
                _buildTorchButton(),
                _buildImageButton(),
                if (_result?.image != null) buildFrame(),
                if (_result?.points != null) buildPoints(),
                if (_result?.text != null) buildText(),
              ],
            )
          : Container(
              color: Colors.grey,
              alignment: Alignment.center,
              child: CircularProgressIndicator.adaptive(),
            ),
    );
  }

  Widget buildFrame() => Positioned(
        left: 21,
        top: 60,
        child: Image.memory(
          _controller.result.image,
          width: 200,
          height: 200,
        ),
      );

  Widget buildText() => Positioned(
        left: 0,
        right: 0,
        top: 50,
        child: Container(
          padding: EdgeInsets.all(8),
          color: Colors.black45,
          child: Text(
            _controller.result.text,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );

//  List<Widget> buildPoints() => _controller.result.points
//      .map((s) => Positioned(
//            left: s.x * MediaQuery.of(context).size.width,
//            top: s.y * MediaQuery.of(context).size.height,
//            child: Container(
//              color: Colors.yellowAccent,
//              height: 5,
//              width: 5,
//            ),
//          ))
//      .toList();

  Widget buildPoints() {
    RBarcodePoint min;
    RBarcodePoint max;

    _controller.result.points.forEach((element) {
      if (min == null) {
        min = element;
        max = element;
      } else {
        double minX = math.min(min.x, element.x);
        double minY = math.min(min.y, element.y);
        double maxX = math.max(max.x, element.x);
        double maxY = math.max(max.y, element.y);
        min = RBarcodePoint(minX, minY);
        max = RBarcodePoint(maxX, maxY);
      }
    });
    return Positioned(
        left: (min.x + (max.x - min.x) / 2) * MediaQuery.of(context).size.width,
        top: (min.y + (max.y - min.y) / 2) * MediaQuery.of(context).size.height,
//        top: ((MediaQuery.of(context).size.height -
//            MediaQuery.of(context).size.width /
//                _controller.value.aspectRatio) /
//            2) + ( MediaQuery.of(context).size.width /
//            _controller.value.aspectRatio) * (min.x + (max.x - min.x) / 2),
//        left: (min.x + (max.x - min.x) / 2) * MediaQuery.of(context).size.width,
        child: RBarCodeCircleIndicator());
  }

//  Widget _buildCamera() => Center(
//        child: MaterialBarCodeFrameWidget(
//          scanStatus: _scanStatus,
//          scanType: _scanType,
//          child: AspectRatio(
//            aspectRatio: _controller.value.aspectRatio,
//            child: RBarcodeCamera(_controller),
//          ),
//        ),
//      );

  Widget _buildCamera() => Center(
        child: MaterialBarCodeFrameWidget(
          scanStatus: _scanStatus,
          scanType: _scanType,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
                onTap: () {
                  _controller.requestFocus(1.0, 1.0, 200, 200);
                },
                child: RBarcodeCamera(_controller)),
          ),
        ),
      );

  Widget _buildToolBar() => Positioned(
        left: 0,
        right: 0,
        bottom: 130,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildToolBarButton('二维码', _scanType == BarcodeScanType.qrCode,
                    () => _handleScanTypeChange(BarcodeScanType.qrCode)),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.black,
                ),
                _buildToolBarButton('条形码', _scanType == BarcodeScanType.barCode,
                    () => _handleScanTypeChange(BarcodeScanType.barCode)),
              ],
            ),
          ),
        ),
      );

  Widget _buildImageButton() => Positioned(
      left: 32,
      bottom: 65,
      child: _buildCircleButton(Icons.refresh, false, _handleScanStart));

  Widget _buildTorchButton() => Positioned(
      right: 32,
      bottom: 65,
      child: _buildCircleButton(
          _controller.value.isTorchOn ? Icons.flash_on : Icons.flash_off,
          _controller.value.isTorchOn,
          _handleFlashToggle));

  Widget _buildToolBarButton(String title, bool isSelect, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color:
                      isSelect ? Theme.of(context).primaryColor : Colors.white,
                ),
          ),
        ),
      );

  Widget _buildCircleButton(IconData iconData, isSelect, VoidCallback onTap) =>
      Container(
        decoration:
            BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
        child: IconButton(
          icon: Icon(
            iconData,
          ),
          onPressed: onTap,
          color: isSelect ? Theme.of(context).primaryColor : Colors.white,
        ),
      );
}
