//
//  TBUtils.m
//  TBTabBarController
//
//  Copyright (c) 2019-2020 Timur Ganiev
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "_TBUtils.h"

#import <objc/runtime.h>

#pragma mark - CoreGraphics

CGFloat _TBFloorValueWithScale(CGFloat v, CGFloat scale) {
    // This solution was borrowed from Texture https://github.com/TextureGroup/Texture
    return floor((v + FLT_EPSILON) * scale) / scale;
}

CGPoint _TBFloorPointWithScale(CGPoint p, CGFloat scale) {
    
    return (CGPoint){_TBFloorValueWithScale(p.x, scale), _TBFloorValueWithScale(p.y, scale)};
}

CGSize _TBFloorSizeWithScale(CGSize s, CGFloat scale) {
    
    return (CGSize){_TBFloorValueWithScale(s.width, scale), _TBFloorValueWithScale(s.height, scale)};
}

CGRect _TBFloorRectWithScale(CGRect r, CGFloat scale) {
    
    return (CGRect){_TBFloorPointWithScale(r.origin, scale), _TBFloorSizeWithScale(r.size, scale)};
}

#pragma mark - Runtime

BOOL _TBSubclassOverridesMethod(Class superclass, Class subclass, SEL selector) {
    
    return class_getInstanceMethod(superclass, selector) != class_getInstanceMethod(subclass, selector);
}

void _TBSwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL const success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Calculations

NSUInteger _TBAmountOfEvenNumbersInRange(NSRange range) {
    
    return (range.length - range.location + 2 - (range.length % 2)) / 2;
}

#pragma mark - Drawing

UIImage *_TBDrawFilledRectangleWithSize(CGSize size) {
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextAddRect(context, (CGRect){CGPointZero, {size.width, size.height}});
        CGContextFillPath(context);
    }];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

UIImage *_TBDrawFilledCircleWithSize(CGSize size, CGFloat scale) {
    
    CGFloat const pixelSize = 0.0;//1.0 / scale;
    CGFloat const offset = 0.0;//pixelSize / 2.0;
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextAddEllipseInRect(context, (CGRect){{offset, offset}, {size.width - pixelSize, size.height - pixelSize}});
        CGContextFillPath(context);
    }];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
