part of 'r_barcode.dart';

/// 扫描成功后的返回值
///
/// [format] 二维码编码类型
/// [text] 二维码中的文本消息
/// [points] 二维码在图片中所在的位置
/// [image] 如果设置了[RBarcode.initBarcodeEngine] 的[isReturnImage] 为true ，则会返回，默认是null
class RBarcodeResult {
  final RBarcodeFormat? format;
  final String? text;
  final List<RBarcodePoint>? points;
  final Uint8List? image;

  const RBarcodeResult({this.image, this.format, this.text, this.points});

  factory RBarcodeResult.formMap(Map? map) {
    return map == null
        ? RBarcodeResult()
        : RBarcodeResult(
      format:
      map['format'] != null ? RBarcodeFormat(map['format']) : null,
      text: map['text'] as String?,
      points: map['points'] != null
          ? (map['points'] as List)
          .map(
            (data) =>
            RBarcodePoint(
              data['x'],
              data['y'],
            ),
      )
          .toList()
          : null,
      image: map['image'],
    );
  }

  @override
  String toString() {
    return 'RScanResult{format: $format, text: $text, points: $points}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RBarcodeResult &&
              runtimeType == other.runtimeType &&
              format == other.format &&
              text == other.text &&
              points == other.points;

  @override
  int get hashCode => format.hashCode ^ text.hashCode ^ points.hashCode;
}

/// 扫描得到的点
/// [x] 点，对应宽度的百分比
/// [y] 点，对应高度的百分比
class RBarcodePoint {
  final double? x;
  final double? y;

  RBarcodePoint(this.x, this.y);

  @override
  String toString() {
    return 'RScanPoint{x: $x , y: $y}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RBarcodePoint &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
