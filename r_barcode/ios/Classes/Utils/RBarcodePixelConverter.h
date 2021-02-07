//
//  RBarcodePixelConverter.h
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/7.
//  rhymelph@gmail.com
//
#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>

@interface RBarcodePixelConverter : NSObject

@property(readonly) CVPixelBufferRef volatile latestPixelBuffer;
@property(nonatomic) vImage_Buffer destinationBuffer;
@property(nonatomic) vImage_Buffer conversionBuffer;
@property(readonly, nonatomic) CGSize previewSize;

- (CVPixelBufferRef) convertResult: (CVPixelBufferRef)sourceBuffer;

- (instancetype) initWithSize: (CGFloat)width
                  height:(CGFloat)height;
- (void) dealloc;

@end
