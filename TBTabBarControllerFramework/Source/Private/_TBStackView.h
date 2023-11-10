//
//  _TBStackView.h
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

typedef NS_ENUM(NSInteger, TBStackedTabsViewAxis) {
    TBStackedTabsViewAxisHorizontal,
    TBStackedTabsViewAxisVertical
};

/**
 * @abstract A private class that represents a custom stack view used for tab bar layout within the `TBTabBarController` framework.
 * @discussion This class is used internally to provide fine-grained control over the positioning and distribution of tab bar items.
 * The use of this custom stack view allows for pixel-accurate positioning and customized distribution rules, which are essential
 * for `TBTabBarController's` specific layout requirements. 
 * Advantages:
 * **Pixel-Accurate Positioning:** The `_TBStackView` is designed to handle pixel-accurate layout, 
 * ensuring that items are positioned precisely, especially for devices with varying screen scales.
 * This level of control is essential for tab bars where pixel-perfect alignment is crucial.
 * **Custom Distribution Rules:** The custom stack view allows the definition of specific distribution rules for pixel distribution. 
 * It provides flexibility in how undistributed pixels are allocated between items, which can be useful for creating custom layouts
 * based on the number of tabs and available space.
 */
@interface _TBStackView : UIView

/**
 * @abstract Initializes a new instance of `TBStackView` with the specified axis.
 * @param axis The axis for the stack view, which can be either horizontal or vertical.
 * @return A new `TBStackView` instance.
 */
- (instancetype)initWithAxis:(TBStackedTabsViewAxis)axis;

/**
 * @abstract The spacing between items in the stack view.
 */
@property (assign, nonatomic) CGFloat spacing;

/**
 * @abstract A flag indicating whether the stack view is in vertical orientation.
 */
@property (assign, nonatomic, readonly, getter = isVertical) BOOL vertical NS_SWIFT_NAME(isVertical);

/**
 * @abstract Marks the stack view as needing layout, triggering a layout update.
 */
- (void)setNeedsLayout;

@end

NS_ASSUME_NONNULL_END
