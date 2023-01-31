//
//  TBUtils.h
//  TBTabBarController
//
//  Copyright © 2019-2023 Timur Ganiev. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <CoreFoundation/CFBase.h>
#import "UIApplication+Extensions.h"

#ifndef __IPHONE_13_0
#define __IPHONE_13_0 130000
#endif

#define TB_AT_LEAST_IOS13  (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)

// This technique was borrowed from Mike Ash
// https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define TB_UINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define TB_UINT_ROTATE(value, rotation) ((((NSUInteger)value) << rotation) | (((NSUInteger)value) >> (TB_UINT_BIT - rotation)))

NS_ASSUME_NONNULL_BEGIN

#pragma mark - CoreGraphics

extern CGFloat const _TBPixelAccurateScaleAutomatic;

static inline CGFloat _TBPixelAccurateValue(CGFloat value, CGFloat scale, BOOL roundUp) {

    if (scale < 1.0) {
        UIScreen *currentScreen = [UIApplication sharedApplication].currentScreen;
        scale = currentScreen != nil ? currentScreen.nativeScale : 2.0;
    }

    // This solution was borrowed from Texture https://github.com/TextureGroup/Texture

    return roundUp ?
        (ceil((value + FLT_EPSILON) * scale) / scale) :
        (floor((value + FLT_EPSILON) * scale) / scale);
}

static inline CGPoint _TBPixelAccuratePoint(CGPoint point, CGFloat scale, BOOL roundUp) {

    return (CGPoint){
        _TBPixelAccurateValue(point.x, scale, roundUp),
        _TBPixelAccurateValue(point.y, scale, roundUp)
    };
}

static inline CGSize _TBPixelAccurateSize(CGSize size, CGFloat scale, BOOL roundUp) {

    return (CGSize){
        _TBPixelAccurateValue(size.width, scale, roundUp),
        _TBPixelAccurateValue(size.height, scale, roundUp)
    };
}

static inline CGRect _TBPixelAccurateRect(CGRect rect, CGFloat scale, BOOL roundUp) {

    return (CGRect){
        _TBPixelAccuratePoint(rect.origin, scale, roundUp),
        _TBPixelAccurateSize(rect.size, scale, roundUp)
    };
}

#pragma mark - Runtime

extern BOOL _TBSubclassOverridesMethod(Class superclass, Class subclass, SEL selector);

extern void _TBSwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector);

#pragma mark - Calculations

extern NSUInteger _TBAmountOfEvenNumbersInRange(NSRange range);

#pragma mark - Drawing

extern UIImage *_TBDrawFilledRectangleWithSize(CGSize size);

extern UIImage *_TBDrawFilledCircleWithSize(CGSize size, CGFloat scale);

NS_ASSUME_NONNULL_END
