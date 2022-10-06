//
//  TBSimpleBar.h
//  TBTabBarController
//
//  Copyright (c) 2019-2023 Timur Ganiev
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
    TBSimpleBarSeparatorPositionHidden,
    TBSimpleBarSeparatorPositionLeft,
    TBSimpleBarSeparatorPositionRight,
    TBSimpleBarSeparatorPositionTop,
};

#pragma mark - Bar

@interface TBSimpleBar : UIView {
    
@protected
    
    UIEdgeInsets _additionalContentInsets;
    
    UIImageView *_separatorImageView;
}

/**
 * @abstract A separator size. Default value is 1px.
 */
@property (assign, nonatomic) CGFloat separatorSize;

/**
 * @abstract An additional area around the content. Default value is {0, 0, 0, 0}.
 */
@property (assign, nonatomic) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

/**
 * @abstract A custom view that is shown below the tabs. Default value is nil.
 * @discussion For example, it can be a @b `UIVisualEffectView` with a blur style effect.
 */
@property (strong, nonatomic, nullable) UIView *contentView;

/**
 * @abstract A separator image. Resettable.
 */
@property (strong, nonatomic, null_resettable) UIImage *separatorImage UI_APPEARANCE_SELECTOR;

/**
 * @abstract A separator image tint color. Default value is black with an opacity of 30%. Resettable.
 */
@property (strong, nonatomic, null_resettable) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract Describes the separator position. Default value is TBSimpleBarSeparatorPositionHidden.
 */
@property (assign, nonatomic) TBSimpleBarSeparatorPosition separatorPosition;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
