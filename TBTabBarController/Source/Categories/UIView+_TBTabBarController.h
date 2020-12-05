//
//  UIView+_TBTabBarController.h
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

NS_ASSUME_NONNULL_BEGIN

@interface UIView (_TBTabBarController)

/**
 * @abstract A display scale.
 * @discussion Some iPhone models (or rather 5,5" Plus models and 12 Mini) have non-integer display scale value (≈@2.608x). This applies only for real devices and not to simulators. So, because of this, some lines, separators, icons and other graphics that requires pixel-perfect design may be displaying wrong. This computed property solves this problem by getting current screen's native scale instead of trait collection's display scale which may be only integer value like @1x, @2x and so on.
 * @note If the current view does not have a window then it uses main screen's window native scale value.
 */
@property (assign, nonatomic, readonly) CGFloat tb_displayScale;

/**
 * @abstract Describes wheter is LTR or RTL layour direction.
 */
@property (assign, nonatomic, readonly) BOOL tb_isLeftToRight;

/**
 * @abstract Retrieves a subview at the given location, if any.
 */
- (nullable __kindof UIView *)tb_subviewAtLocation:(CGPoint)location withCondition:(nullable BOOL (^)(__kindof UIView *subview))condition subviewIndex:(NSUInteger *)subviewIndex skipIndexes:(BOOL)skipIndexes touchSize:(CGFloat)touchSize verticalLayout:(BOOL)verticalLayout;

@end

NS_ASSUME_NONNULL_END
