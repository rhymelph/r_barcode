//
//  RBarcodePixelConverter.m
//  r_barcode
//
//  Created by 李鹏辉 on 2020/6/7.
//  rhymelph@gmail.com
//

#import <Foundation/Foundation.h>
#import "RBarcodePixelConverter.h"
#import <libkern/OSAtomic.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>

@implementation RBarcodePixelConverter

- (instancetype)initWithSize:(CGFloat)width height:(CGFloat)height {
    
    _previewSize = CGSizeMake(width,height);
    
    vImageBuffer_Init(&_destinationBuffer, _previewSize.width, _previewSize.height, 32,
                      kvImageNoFlags);
    vImageBuffer_Init(&_conversionBuffer, _previewSize.width, _previewSize.height, 32,
                      kvImageNoFlags);
    return self;
}

- (CVPixelBufferRef) convertResult: (CVPixelBufferRef)sourceBuffer {
    
    CFRetain(sourceBuffer);
    CVPixelBufferRef old = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(old, sourceBuffer, (void **)&_latestPixelBuffer)) {
        old = _latestPixelBuffer;
    }
    if (old != nil) {
        CFRelease(old);
    }
    
    CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
        pixelBuffer = _latestPixelBuffer;
    }
    return pixelBuffer;
}

- (void) dealloc {
    if(_latestPixelBuffer){
        CFRelease(_latestPixelBuffer);
    }
}

@end
