part of 'r_barcode.dart';

/// 扫描状态
/// [BarcodeScanStatus.scan]    扫描中
/// [BarcodeScanStatus.loading] 加载中
/// [BarcodeScanStatus.stop]    扫描停止
enum BarcodeScanStatus {
  scan,
  loading,
  stop,
}

/// 扫描类型
/// [BarcodeScanType.qrCode]  二维码
/// [BarcodeScanType.barCode] 条形码
enum BarcodeScanType {
  qrCode,
  barCode,
}
// Tweens used by circular progress indicator
final Animatable<double> _kStrokeHeadTween = CurveTween(
  curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<double> _kStrokeTailTween = CurveTween(
  curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<int> _kStepTween = StepTween(begin: 0, end: 5);

final Animatable<double> _kRotationTween = CurveTween(curve: const SawTooth(5));

/// 谷歌Material风格的扫描框
///
/// Google Material Design Scam Frame.
/// [scanStatus] You can find in [BarcodeScanStatus]
/// [scanType] You can find in [BarcodeScanType]
class MaterialBarCodeFrameWidget extends StatefulWidget {
  final Widget child;
  final BarcodeScanStatus scanStatus;
  final BarcodeScanType scanType;

  const MaterialBarCodeFrameWidget(
      {Key key, this.child, this.scanStatus, this.scanType})
      : super(key: key);

  @override
  _MaterialBarCodeFrameWidgetState createState() =>
      _MaterialBarCodeFrameWidgetState();
}

class _MaterialBarCodeFrameWidgetState extends State<MaterialBarCodeFrameWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;

  final Animatable<double> _startExpandColor = CurveTween(
    curve: const Interval(0.0, 0.3, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(5),
  ));

  final Animatable<double> _expandAnimation = CurveTween(
    curve: const Interval(0.3, 1.0, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(5),
  ));

  BarcodeScanStatus _scanType;
  BarcodeScanStatus _widgetScanType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addListener(() {
        if (_widgetScanType != _scanType) {
          setState(() {
            _scanType = _widgetScanType;
          });
        }
      });
    _controller.repeat();
    _scanType = widget.scanStatus;
    _widgetScanType = widget.scanStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return buildFrame(
          child,
          _expandAnimation.evaluate(_controller),
          _startExpandColor.evaluate(_controller),
          _kStrokeHeadTween.evaluate(_controller),
          _kStrokeTailTween.evaluate(_controller),
          _kStepTween.evaluate(_controller),
          _kRotationTween.evaluate(_controller),
        );
      },
      child: widget.child,
    );
  }

  Widget buildFrame(
      Widget child,
      double expandValue,
      double startColorExpandValue,
      double headValue,
      double tailValue,
      int stepValue,
      double rotationValue) {
    return CustomPaint(
      willChange: true,
      foregroundPainter: MaterialBarCodeFrame(
        expandProgress: expandValue,
        status: _scanType,
        expandStartColor: startColorExpandValue,
//        height: MediaQuery.of(context).size.width - 80,
        height: getHeight(),
        padding: getPadding(),
        headValue: headValue,
        // remaining arguments are ignored if widget.value is not null
        tailValue: tailValue,
        stepValue: stepValue,
        rotationValue: rotationValue,
      ),
      child: child,
    );
  }

  double getHeight() {
    switch (widget.scanType) {
      case BarcodeScanType.qrCode:
        return MediaQuery.of(context).size.width - 160;
      case BarcodeScanType.barCode:
        return 120;
    }
    return 0;
  }

  double getPadding() {
    switch (widget.scanType) {
      case BarcodeScanType.qrCode:
        return 80;
      case BarcodeScanType.barCode:
        return 40;
    }
    return 0;
  }

  @override
  void didUpdateWidget(MaterialBarCodeFrameWidget oldWidget) {
    _widgetScanType = widget.scanStatus;
    if (widget.scanStatus == BarcodeScanStatus.stop) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}

/// 谷歌Material风格的扫描框画笔
///
class MaterialBarCodeFrame extends CustomPainter {
  final double padding;
  final double height;

  final Radius radius;

  final BarcodeScanStatus status;

  MaterialBarCodeFrame(
      {this.expandProgress: 0.4,
      this.padding: 40,
      this.height: 150,
      this.strokeWidth: 4,
      this.minStrokeWidth: 2,
      this.radius: const Radius.circular(8),
      this.expandStartColor,
      this.headValue,
      this.tailValue,
      this.rotationValue,
      this.stepValue,
      this.status: BarcodeScanStatus.loading})
      : arcStart = _startAngle +
            tailValue * 3 / 2 * math.pi +
            rotationValue * math.pi * 1.7 -
            stepValue * 0.8 * math.pi,
        arcSweep = math.max(
            headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi,
            _epsilon);

  //画框
  Paint _mPaint;

  //画扩展
  Paint _expandPaint;
  Paint _mMaskPaint;
  final double strokeWidth;
  final double minStrokeWidth;
  final double expandProgress;
  final double expandStartColor;

  //画进度
  Paint _mProgressPaint;
  final double headValue;
  final double tailValue;
  final int stepValue;
  final double rotationValue;
  final double arcStart;
  final double arcSweep;
  static const double _startAngle = -math.pi / 2.0;
  static const double _epsilon = .5;

  void initPaint() {
    _mPaint = Paint()
      ..color = Color(0xFF666666)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _expandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _mProgressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _mMaskPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_mPaint == null || _expandPaint == null) initPaint();
    double screenWidth = size.width;
    double screenHeight = size.height;
    double top = screenHeight / 2 - height / 2 - strokeWidth;
    double bottom = screenHeight / 2 + height / 2 + strokeWidth;
    double left = padding;
    double right = screenWidth - padding - strokeWidth;

    //基本背景
    if (status != BarcodeScanStatus.stop) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, screenWidth, top + strokeWidth / 2), _mMaskPaint);
      canvas.drawRect(
          Rect.fromLTWH(0, top + strokeWidth / 2, left, screenHeight),
          _mMaskPaint);
      canvas.drawRect(
          Rect.fromLTWH(left, bottom - strokeWidth / 2, screenWidth - left,
              bottom - strokeWidth / 2),
          _mMaskPaint);
      canvas.drawRect(
          Rect.fromLTWH(right, top + strokeWidth / 2, padding + strokeWidth,
              height + strokeWidth),
          _mMaskPaint);
      canvas.drawRRect(
          RRect.fromLTRBR(left, top, right, bottom, radius), _mPaint);
    }

    //扩展动画
    void drawExpandIndicator() {
      _expandPaint.strokeWidth = minStrokeWidth +
          (strokeWidth - minStrokeWidth) * (1 - expandProgress);
      if (expandStartColor != 0) {
        _expandPaint.color = Colors.white.withOpacity(expandStartColor);
      }
      if (expandProgress != 0) {
        _expandPaint.color = Colors.white.withOpacity(1 - expandProgress);
      }
      canvas.drawRRect(
          RRect.fromLTRBR(
              left - padding * expandProgress,
              top - padding * expandProgress,
              right + padding * expandProgress,
              bottom + padding * expandProgress,
              radius),
          _expandPaint);
    }

    //圆角进度
    void drawProgressIndicator() {
      canvas.clipPath(Path()
        ..addArc(Offset.zero & size, arcStart, arcSweep)
        ..lineTo(screenWidth / 2, screenHeight / 2)
        ..close());
      canvas.drawRRect(
          RRect.fromLTRBR(left, top, right, bottom, radius), _mProgressPaint);
    }

    if (status == BarcodeScanStatus.loading) {
      drawProgressIndicator();
    } else if (status == BarcodeScanStatus.scan) {
      drawExpandIndicator();
    }
  }

  @override
  bool shouldRepaint(MaterialBarCodeFrame oldDelegate) =>
      expandProgress != oldDelegate.expandProgress ||
      padding != oldDelegate.padding ||
      height != oldDelegate.height ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius ||
      headValue != oldDelegate.headValue ||
      tailValue != oldDelegate.tailValue ||
      stepValue != oldDelegate.stepValue ||
      rotationValue != oldDelegate.rotationValue ||
      status != oldDelegate.status;
}

/// 支付宝风格的扫描框
///
class AlipayFrameWidget extends StatefulWidget {
  final Widget child;
  final BarcodeScanStatus scanStatus;

  const AlipayFrameWidget({Key key, this.child, this.scanStatus})
      : super(key: key);

  @override
  _AlipayFrameWidgetState createState() => _AlipayFrameWidgetState();
}

class _AlipayFrameWidgetState extends State<AlipayFrameWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  final Animatable<double> _startColorAnim = CurveTween(
    curve: const Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(5),
  ));
  final Animatable<double> _moveAnim = CurveTween(
    curve: const Interval(0.2, 0.8, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(5),
  ));

  final Animatable<double> _endColorAnim = CurveTween(
    curve: const Interval(0.8, 1.0, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(5),
  ));

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 20));
    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: _buildWidget,
      child: widget.child,
    );
  }

  Widget _buildWidget(BuildContext context, Widget child) {
    return CustomPaint(
      foregroundPainter: AlipayFrame(
        indicatorColor: Theme.of(context).primaryColor,
        progress: _moveAnim.evaluate(_controller),
        colorProgress: _endColorAnim.evaluate(_controller) == 0
            ? (1 - _startColorAnim.evaluate(_controller))
            : _endColorAnim.evaluate(_controller),
        status: widget.scanStatus,
      ),
      child: child,
    );
  }

  @override
  void didUpdateWidget(AlipayFrameWidget oldWidget) {
    if (widget.scanStatus == BarcodeScanStatus.stop) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
    super.didUpdateWidget(oldWidget);
  }
}

class AlipayFrame extends CustomPainter {
  final Size indicatorSize;
  final Size moveSize;
  final Color indicatorColor;
  final double progress;
  final double colorProgress;
  Paint _mPaint;
  Paint _mBPaint;
  final BarcodeScanStatus status;

  AlipayFrame({
    this.indicatorSize: const Size(250, 2),
    this.moveSize: const Size(250, 300),
    this.progress: 0.2,
    this.colorProgress: 0.2,
    this.indicatorColor: Colors.green,
    this.status,
  });

  void initPaint() {
    _mPaint = Paint()
      ..color = indicatorColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _mBPaint = Paint()
      ..color = indicatorColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_mPaint == null || _mBPaint == null) initPaint();
    double topPadding = ((size.height - moveSize.height) / 2) +
        progress * (moveSize.height - indicatorSize.height);
    double topParentPadding = ((size.height - moveSize.height) / 2);
    double leftPadding = (size.width - moveSize.width) / 2;

    void drawProgressIndicator() {
      if (progress != 0) {
        _mBPaint.shader = LinearGradient(colors: [
          indicatorColor.withOpacity(0.3 * (1 - colorProgress)),
          indicatorColor.withOpacity(1 - colorProgress),
          indicatorColor.withOpacity(0.3 * (1 - colorProgress)),
        ], stops: [
          0,
          (0.5 + progress > 1 ? ((0.5 + progress) - 1) : (0.5 + progress)),
          1.0
        ]).createShader(Offset(leftPadding, topPadding) & moveSize);
      } else {
        _mBPaint.shader = LinearGradient(colors: [
          indicatorColor.withOpacity(0.3 * (1 - colorProgress)),
          indicatorColor.withOpacity(1 - colorProgress),
          indicatorColor.withOpacity(0.3 * (1 - colorProgress)),
        ], stops: [
          0,
          0.5,
          1.0
        ]).createShader(Offset(leftPadding, topPadding) & moveSize);
      }
//      canvas.drawRect(Offset(leftPadding,topPadding)&moveSize, _mPaint);
    }

    void drawScanIndicator() {
      //画线
      Rect indicatorRect = Offset(leftPadding, topPadding) & indicatorSize;
      _mPaint.shader = LinearGradient(colors: [
        indicatorColor.withOpacity(0.3 * (1 - colorProgress)),
        indicatorColor.withOpacity(1 - colorProgress),
        indicatorColor.withOpacity(0.3 * (1 - colorProgress)),
      ], stops: [
        0,
        0.5,
        1.0
      ]).createShader(indicatorRect);
      canvas.drawRect(indicatorRect, _mPaint);

      //画跟随的矩形
      _mBPaint.shader = RadialGradient(center: Alignment.topCenter, colors: [
        indicatorColor.withOpacity(1 - colorProgress),
        indicatorColor.withOpacity(0.0 * (1 - colorProgress)),
      ]).createShader(Offset(leftPadding, topPadding) & moveSize);
      canvas.clipRect(Offset(leftPadding, topParentPadding) &
          Size(size.width, moveSize.height * progress));
    }

    if (status == BarcodeScanStatus.loading) {
      drawProgressIndicator();
    } else if (status == BarcodeScanStatus.scan) {
      drawScanIndicator();
    }

    if (status != BarcodeScanStatus.stop) {
      double space = 30;
      for (int i = 0; i <= space; i++) {
        canvas.drawLine(
            Offset(leftPadding + i * moveSize.width / space, topParentPadding),
            Offset(leftPadding + i * moveSize.width / space,
                topParentPadding + moveSize.height),
            _mBPaint);
        canvas.drawLine(
            Offset(leftPadding, topParentPadding + i * moveSize.height / space),
            Offset(leftPadding + moveSize.width,
                topParentPadding + i * moveSize.height / space),
            _mBPaint);
      }
    }
  }

  @override
  bool shouldRepaint(AlipayFrame oldDelegate) =>
      indicatorSize != oldDelegate.indicatorSize ||
      moveSize != oldDelegate.moveSize ||
      progress != oldDelegate.progress ||
      indicatorColor != oldDelegate.indicatorColor ||
      colorProgress != oldDelegate.colorProgress ||
      status != oldDelegate.status;
}
