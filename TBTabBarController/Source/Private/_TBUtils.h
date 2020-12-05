//
//  TBUtils.h
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

#import <UIKit/UIKit.h>

#import <CoreFoundation/CFBase.h>

#ifndef __IPHONE_13_0
#define __IPHONE_13_0 130000
#endif

#define TB_AT_LEAST_IOS13  (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)

// This technique was barrowed from https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define TB_UINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define TB_UINT_ROTATE(value, rotation) ((((NSUInteger)value) << rotation) | (((NSUInteger)value) >> (TB_UINT_BIT - rotation)))

NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIImage

extern UIImage *_TBResizeImageToPreferredSize(UIImage *image, CGSize preferredSize);

#pragma mark - CoreGraphics

extern CGPoint _TBFloorPointWithScale(CGPoint p, CGFloat scale);
extern CGSize _TBFloorSizeWithScale(CGSize s, CGFloat scale);
extern CGRect _TBFloorRectWithScale(CGRect r, CGFloat scale);
extern CGFloat _TBFloorValueWithScale(CGFloat v, CGFloat scale);

#pragma mark - Runtime

extern BOOL _TBSubclassOverridesMethod(Class superclass, Class subclass, SEL selector);

extern void _TBSwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector);

#pragma mark - Calculations

extern NSUInteger _TBAmountOfEvenNumbersInRange(NSRange range);

#pragma mark - Drawing

extern UIImage *_TBDrawFilledRectangleWithSize(CGSize size);

extern UIImage *_TBDrawFilledCircleWithSize(CGSize size, CGFloat scale);

NS_ASSUME_NONNULL_END
