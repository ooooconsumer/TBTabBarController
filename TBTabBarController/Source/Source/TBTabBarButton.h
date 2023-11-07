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

#if SWIFT_PACKAGE
#import "TBTabBarItem.h"
#else
#import <TBTabBarController/TBTabBarItem.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TBTabBarButtonLayoutOrientation) {
    /// Vertical orientation indicates that the notification indicator will be positioned below the tab icon.
    TBTabBarButtonLayoutOrientationVertical,

    /// Horizontal orientation indicates that the notification indicator will be positioned to the right (or left) of the tab icon.
    TBTabBarButtonLayoutOrientationHorizontal
};

#pragma mark - Button

/**
 * @abstract A button displayed within a tab bar.
 * @discussion The `TBTabBarButton` class is a fundamental component of the framework.
 * It represents a customizable button that appears as a tab in the tab bar. This class offers extensive control over the appearance
 * and behavior of individual tab buttons within the tab bar.
 *
 * Key Features:
 * - Icon Display: It provides an `imageView` property for displaying tab icons. You can set and customize tab icons for different control states.
 * - Notification Indicator: It includes a `notificationIndicatorView` for displaying notifications. You can control its size, visibility, and position.
 * - Customization: The class supports extensive customization of the appearance and behavior of tab buttons.
 *
 * @note You should not create instances of this class directly. Instead, it is used internally by `TBTabBarController`
 * to represent individual tab buttons.
 */
@interface TBTabBarButton : UIControl

/**
 * @abstract An image view displaying a tab icon.
 * @discussion Use this property to adjust the view's aspect fill value. Do not set an image directly to the view; 
 * instead, use the `setImage:forState:` method below. You can override the `imageViewFrameForBounds:`
 * method to update its size and/or position.
 */
@property (strong, nonatomic, readonly) UIImageView *imageView;

/**
 * @abstract A view displaying the notification indicator. Resettable.
 * @discussion You can always change its size using the `notificationIndicatorSize` property or by overriding 
 * the `notificationIndicatorViewFrameForBounds:` method below.
 */
@property (strong, nonatomic, null_resettable) __kindof UIView *notificationIndicatorView;

/**
 * @abstract The size of the notification indicator view. The default value is 5pt.
 */
@property (assign, nonatomic) CGSize notificationIndicatorSize UI_APPEARANCE_SELECTOR;

/**
 * @abstract The insets for the notification indicator view. The default value is {0, 0, 0, 5} for horizontal orientation 
 * and {0, 0, 3, 0} for vertical orientation.
 */
@property (assign, nonatomic) UIEdgeInsets notificationIndicatorInsets UI_APPEARANCE_SELECTOR;

/**
 * @abstract Indicates whether the notification indicator is visible. The default value is NO.
 */
@property (assign, nonatomic, getter = isNotificationIndicatorVisible) BOOL notificationIndicatorVisible NS_SWIFT_NAME(isNotificationIndicatorVisible);

/**
 * @abstract The tab bar item associated with the button.
 */
@property (strong, nonatomic, readonly) __kindof TBTabBarItem *tabBarItem;

/**
 * @abstract Initializes a TBTabBarButton with a tab bar item and layout orientation.
 * @param tabBarItem The tab bar item to associate with the button.
 * @param layoutOrientation The layout orientation (vertical or horizontal).
 * @return An initialized TBTabBarButton instance.
 */
- (instancetype)initWithTabBarItem:(__kindof TBTabBarItem *)tabBarItem
                 layoutOrientation:(TBTabBarButtonLayoutOrientation)layoutOrientation NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame primaryAction:(nullable UIAction *)primaryAction NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

/**
 * @abstract Sets a new image as a tab icon for the given state.
 * @param image The image to be set as the tab icon.
 * @param state The control state for which to set the image.
 */
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;

/**
 * @abstract Sets the notification indicator to be hidden or visible if needed.
 * @param hidden Indicates whether the notification indicator should be hidden.
 * @param animated Indicates whether the change should be animated.
 */
- (void)setNotificationIndicatorHidden:(BOOL)hidden animated:(BOOL)animated;

@end

#pragma mark - Subclassing

/**
 * @abstract Subclassing methods for customizing the appearance and behavior of TBTabBarButton.
 * @discussion This extension provides customization points for subclasses of TBTabBarButton to adjust the positioning
 * and animation behavior of its components.
 */
@interface TBTabBarButton (Subclassing)

/**
 * @abstract Provides the frame for the image view within the button.
 * @discussion Subclasses can override this method to customize the position and size of the tab icon within the button.
 * @param bounds The bounds of the button.
 * @return The frame for the image view.
 */
- (CGRect)imageViewFrameForBounds:(CGRect)bounds;

/**
 * @abstract Provides the frame for the notification indicator view within the button.
 * @discussion Subclasses can override this method to customize the position and size of the notification indicator within the button.
 * @param bounds The bounds of the button.
 * @return The frame for the notification indicator view.
 */
- (CGRect)notificationIndicatorViewFrameForBounds:(CGRect)bounds;

/**
 * @abstract Returns the duration of the animation for showing or hiding the notification indicator.
 * @discussion Subclasses can override this method to define the duration of the animation used to show or hide the notification indicator.
 * @param presenting Indicates whether the notification indicator is being shown or hidden.
 * @return The animation duration.
 */
- (NSTimeInterval)notificationIndicatorAnimationDuration:(BOOL)presenting;

@end

NS_ASSUME_NONNULL_END
