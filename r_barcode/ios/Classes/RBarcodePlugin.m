#import "RBarcodePlugin.h"
#if __has_include(<r_barcode/r_barcode-Swift.h>)
#import <r_barcode/r_barcode-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "r_barcode-Swift.h"
#endif

@implementation RBarcodePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRBarcodePlugin registerWithRegistrar:registrar];
}
@end
