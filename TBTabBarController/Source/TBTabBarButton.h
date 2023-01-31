//
//  TBTabBarButton.h
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

#import <TBTabBarController/TBTabBarItem.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TBTabBarButtonLayoutOrientation) {
    /// Vertical orientation means, that the notification indicator will be placed below the tab icon.
    TBTabBarButtonLayoutOrientationVertical,
    /// Horizontal orientation means, that the notification indicator will be placed to the right (or left) of the tab icon.
    TBTabBarButtonLayoutOrientationHorizontal
};

#pragma mark - Button

/**
 * @abstract A button that displays in a tab bar.
 */
@interface TBTabBarButton : UIControl

/**
 * @abstract An image view that displays a tab icon.
 * @discussion You can use this property to change view's aspect fill value. But do not set an image directly to the view. Instead, use @em `setImage:forState:` method below.
 * If you need to update it's size and/or position, you can override @em `imageViewFrameForBounds:` method below.
 */
@property (strong, nonatomic, readonly) UIImageView *imageView;

/**
 * @abstract A view that displays the notification indicator. Resettable.
 * @discussion You can always change it's size using @em `notificationIndicatorSize` property or by overriding @em `notificationIndicatorViewFrameForBounds:` method below.
 */
@property (strong, nonatomic, null_resettable) __kindof UIView *notificationIndicatorView;

/**
 * @abstract A notification indicator view size. Default value is 5pt.
 */
@property (assign, nonatomic) CGSize notificationIndicatorSize UI_APPEARANCE_SELECTOR;

/**
 * @abstract A notification indicator view insets.
 * Default value is {0, 0, 0, 5} and {0, 0, 3, 0} for horizontal and vertical positions, respectively.
 */
@property (assign, nonatomic) UIEdgeInsets notificationIndicatorInsets UI_APPEARANCE_SELECTOR;

/**
 * @abstract Describes whether a notification indicator is visible or not. Default value is NO.
 */
@property (assign, nonatomic, getter = isNotificationIndicatorVisible) BOOL notificationIndicatorVisible NS_SWIFT_NAME(isNotificationIndicatorVisible);

@property (strong, nonatomic, readonly) __kindof TBTabBarItem *tabBarItem;

- (instancetype)initWithTabBarItem:(__kindof TBTabBarItem *)tabBarItem layoutOrientation:(TBTabBarButtonLayoutOrientation)layoutOrientation NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame primaryAction:(nullable UIAction *)primaryAction NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

/**
 * @abstract Sets a new image as a tab icon for the given state.
 */
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;

/**
 * @abstract Sets the notificator indicator hidden or visible if needed.
 */
- (void)setNotificationIndicatorHidden:(BOOL)hidden animated:(BOOL)animated;

@end

#pragma mark - Subclassing

@interface TBTabBarButton (Subclassing)

- (CGRect)imageViewFrameForBounds:(CGRect)bounds;

- (CGRect)notificationIndicatorViewFrameForBounds:(CGRect)bounds;

/**
 * @abstract The duration of the animation for showing or hiding the notification indicator. Default value is 0.25.
 * @param presenting Whether the notification indicator is showing or hiding.
 */
- (NSTimeInterval)notificationIndicatorAnimationDuration:(BOOL)presenting;

@end

NS_ASSUME_NONNULL_END
