part of 'r_barcode.dart';

class RBarcodeFormat {
  final String _value;

  const RBarcodeFormat(this._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RBarcodeFormat &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  // line format
  static const RBarcodeFormat Codabar = RBarcodeFormat('Codabar');
  static const RBarcodeFormat Code39 = RBarcodeFormat('Code39');
  static const RBarcodeFormat Code93 = RBarcodeFormat('Code93');
  static const RBarcodeFormat Code128 = RBarcodeFormat('Code128');
  static const RBarcodeFormat EAN8 = RBarcodeFormat('EAN8');
  static const RBarcodeFormat EAN13 = RBarcodeFormat('EAN13');
  static const RBarcodeFormat ITF = RBarcodeFormat('ITF');
  static const RBarcodeFormat UPCA = RBarcodeFormat('UPCA');
  static const RBarcodeFormat UPCE = RBarcodeFormat('UPCE');

  // 2d format
  static const RBarcodeFormat Aztec = RBarcodeFormat('Aztec');
  static const RBarcodeFormat DataMatrix = RBarcodeFormat('DataMatrix');
  static const RBarcodeFormat PDF417 = RBarcodeFormat('PDF417');
  static const RBarcodeFormat QRCode = RBarcodeFormat('QRCode');

  static const List<RBarcodeFormat> kAll = const [
    Codabar,
    Code39,
    Code93,
    Code128,
    EAN8,
    ITF,
    UPCA,
    UPCE,
    Aztec,
    DataMatrix,
    PDF417,
    QRCode,
  ];

  static const List<RBarcodeFormat> kLineFormats = const [
    Codabar,
    Code39,
    Code93,
    Code128,
    EAN8,
    ITF,
    UPCA,
    UPCE,
  ];

  static const List<RBarcodeFormat> k2DFormats = const [
    Aztec,
    DataMatrix,
    PDF417,
    QRCode,
  ];

  @override
  String toString() {
    return 'RBarcodeFormat{_value: $_value}';
  }
}
