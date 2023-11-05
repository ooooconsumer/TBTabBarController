//
//  TBSimpleBar.h
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

typedef NS_ENUM(NSUInteger, TBSimpleBarSeparatorPosition) {
    /// The separator is hidden.
    TBSimpleBarSeparatorPositionHidden,

    /// The separator is positioned to the left.
    TBSimpleBarSeparatorPositionLeft,

    /// The separator is positioned to the right.
    TBSimpleBarSeparatorPositionRight,

    /// The separator is positioned at the top.
    TBSimpleBarSeparatorPositionTop
};

#pragma mark - Bar

/**
 * @abstract A simple custom bar for displaying content with a separator.
 * @discussion The `TBSimpleBar` class is a view designed for displaying content with a separator. 
 * It provides customization options for the separator size, additional content insets, and allows the integration
 * of a custom content view below the separator.
 */
@interface TBSimpleBar : UIView {

@protected

    UIEdgeInsets _additionalContentInsets;

    UIImageView *_separatorImageView;
}

/**
 * @abstract The size of the separator. Default value is 1 pixel.
 */
@property (assign, nonatomic) CGFloat separatorSize;

/**
 * @abstract Additional padding around the content within the bar. Default value is {0, 0, 0, 0}.
 */
@property (assign, nonatomic) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

/**
 * @abstract A custom view that appears below the separator, such as a `UIVisualEffectView` with a blur effect. Default value is nil.
 */
@property (strong, nonatomic, nullable) UIView *contentView;

/**
 * @abstract The separator image. Resettable.
 */
@property (strong, nonatomic, null_resettable) UIImage *separatorImage UI_APPEARANCE_SELECTOR;

/**
 * @abstract The tint color of the separator image. Default value is black with 30% opacity. Resettable.
 */
@property (strong, nonatomic, null_resettable) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract The position of the separator. Default value is TBSimpleBarSeparatorPositionHidden.
 */
@property (assign, nonatomic) TBSimpleBarSeparatorPosition separatorPosition;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
