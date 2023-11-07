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

// These functions are used internally by the TBTabBarController library and are not meant
// to be used directly by external code. They are provided for internal implementation purposes.

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

/**
 * @abstract A constant representing automatic pixel-accurate scale.
 */
extern CGFloat const _TBPixelAccurateScaleAutomatic;

/**
 * @abstract Rounds the given value to a pixel-accurate value based on the provided scale.
 * @param value The value to round.
 * @param scale The scale to use for rounding.
 * @param roundUp A flag indicating whether to round up or down.
 * @return The rounded pixel-accurate value.
 */
static inline CGFloat _TBPixelAccurateValue(CGFloat value, CGFloat scale, BOOL roundUp) {

    if (scale < 1.0) {
        UIScreen *currentScreen = [UIApplication sharedApplication].currentScreen;
        scale = currentScreen != nil ? currentScreen.nativeScale : 2.0;
    }

    // This solution was borrowed from Texture (https://github.com/TextureGroup/Texture)

    return roundUp ?
        (ceil((value + FLT_EPSILON) * scale) / scale) :
        (floor((value + FLT_EPSILON) * scale) / scale);
}

/**
 * @abstract Rounds the given point to pixel-accurate values based on the provided scale.
 * @param point The point to round.
 * @param scale The scale to use for rounding.
 * @param roundUp A flag indicating whether to round up or down.
 * @return The rounded pixel-accurate point.
 */
static inline CGPoint _TBPixelAccuratePoint(CGPoint point, CGFloat scale, BOOL roundUp) {

    return (CGPoint){
        _TBPixelAccurateValue(point.x, scale, roundUp),
        _TBPixelAccurateValue(point.y, scale, roundUp)
    };
}

/**
 * @abstract Rounds the given size to pixel-accurate values based on the provided scale.
 * @param size The size to round.
 * @param scale The scale to use for rounding.
 * @param roundUp A flag indicating whether to round up or down.
 * @return The rounded pixel-accurate size.
 */
static inline CGSize _TBPixelAccurateSize(CGSize size, CGFloat scale, BOOL roundUp) {

    return (CGSize){
        _TBPixelAccurateValue(size.width, scale, roundUp),
        _TBPixelAccurateValue(size.height, scale, roundUp)
    };
}

/**
 * @abstract Rounds the given rectangle to pixel-accurate values based on the provided scale.
 * @param rect The rectangle to round.
 * @param scale The scale to use for rounding.
 * @param roundUp A flag indicating whether to round up or down.
 * @return The rounded pixel-accurate rectangle.
 */
static inline CGRect _TBPixelAccurateRect(CGRect rect, CGFloat scale, BOOL roundUp) {

    return (CGRect){
        _TBPixelAccuratePoint(rect.origin, scale, roundUp),
        _TBPixelAccurateSize(rect.size, scale, roundUp)
    };
}

#pragma mark - Runtime

/**
 * @abstract Checks whether a subclass overrides a specific method defined in a superclass.
 * @param superclass The superclass that defines the method.
 * @param subclass The subclass to check for method overriding.
 * @param selector The selector of the method to check.
 * @return YES if the subclass overrides the method, otherwise NO.
 */
extern BOOL _TBSubclassOverridesMethod(Class superclass, Class subclass, SEL selector);

/**
 * @abstract Swizzles a method in a class with a custom implementation.
 * @param class The class containing the method to swizzle.
 * @param originalSelector The original method selector to swizzle.
 * @param swizzledSelector The custom method selector to replace the original method.
 */
extern void _TBSwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector);

#pragma mark - Calculations

/**
 * @abstract Calculates the number of even numbers in a given range.
 * @param range The range of numbers to analyze.
 * @return The number of even numbers in the range.
 */
extern NSUInteger _TBAmountOfEvenNumbersInRange(NSRange range);

#pragma mark - Drawing

/**
 * @abstract Draws a filled rectangle with the specified size.
 * @param size The size of the rectangle to draw.
 * @return An image of a filled rectangle with the given size.
 */
extern UIImage *_TBDrawFilledRectangleWithSize(CGSize size);

/**
 * @abstract Draws a filled circle with the specified size and scale.
 * @param size The size of the circle to draw.
 * @param scale The scale to use for drawing.
 * @return An image of a filled circle with the given size and scale.
 */
extern UIImage *_TBDrawFilledCircleWithSize(CGSize size, CGFloat scale);

NS_ASSUME_NONNULL_END
