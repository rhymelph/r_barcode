/// exception
class RBarcodeException implements Exception {
  RBarcodeException(this.code, this.description);

  String code;
  String? description;

  @override
  String toString() => '$runtimeType($code, $description)';
}
