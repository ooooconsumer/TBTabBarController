//
//  UIView+Extensions.h
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

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extensions)

/**
 * @abstract Calculates and returns the accurate display scale for the current view.
 * @discussion Some iPhone models (especially 5.5" Plus models and the iPhone 12 Mini) have non-integer display scale values 
 * (e.g., ≈2.608x), which can cause issues with pixel-perfect design elements such as lines, separators, and icons. This property
 * resolves this problem by dynamically retrieving the native scale factor of the current screen. It is particularly useful for real devices
 * and ensures that graphics are displayed correctly. In cases where the view does not belong to a window,
 * it uses the native scale of the main screen's window.
 */
@property (assign, nonatomic, readonly) CGFloat tb_displayScale;

/**
 * @abstract Indicates whether the layout direction of the view is left-to-right (LTR).
 * @discussion This property determines the text and layout direction for the view. It returns `YES` when the layout is left-to-right, 
 * which is the standard direction for most languages. For right-to-left (RTL) layouts, it returns `NO`.
 */
@property (assign, nonatomic, readonly) BOOL tb_isLeftToRight;

@end

NS_ASSUME_NONNULL_END
