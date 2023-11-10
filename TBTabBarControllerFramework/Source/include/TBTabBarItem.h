//
//  TBTabBarItem.h
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

#pragma mark - Item

/**
 * @abstract An item in a tab bar, similar to UITabBarItem.
 * @discussion The `TBTabBarItem` class represents an item within a tab bar. It provides information and customization 
 * options for a specific tab, including its title, icon, and notification indicator.
 */
@interface TBTabBarItem : NSObject <NSCopying>

/**
 * @abstract Indicates whether the item should be enabled or disabled. The default value is YES.
 */
@property (assign, nonatomic, getter = isEnabled) BOOL enabled NS_SWIFT_NAME(isEnabled);

/**
 * @abstract Indicates whether a notification indicator should be displayed next to the tab icon. The default value is NO.
 */
@property (assign, nonatomic) BOOL showsNotificationIndicator;

/**
 * @abstract The title of the tab, which does not appear by default.
 */
@property (copy, nonatomic, nullable) NSString *title;

/**
 * @abstract The tab's icon image.
 */
@property (strong, nonatomic) UIImage *image;

/**
 * @abstract The tab's icon image when it is selected.
 */
@property (strong, nonatomic, nullable) UIImage *selectedImage;

/**
 * @abstract The image for the notification indicator that appears next to the tab icon. The default is a small dot.
 */
@property (strong, nonatomic, null_resettable) UIImage *notificationIndicator;

/**
 * @abstract The class of the button that will be displayed in the tab bar. The default class is `TBTabBarButton`.
 */
@property (strong, nonatomic, readonly) Class buttonClass;

/**
 * @abstract Initializes a tab item with an image and a button class.
 * @param image The image for the tab icon.
 * @param buttonClass The class of the button to be displayed in the tab bar.
 * @return An initialized TBTabBarItem instance.
 */
- (instancetype)initWithImage:(UIImage *)image buttonClass:(nullable Class)buttonClass;

/**
 * @abstract Initializes a tab item with an image, a selected image, and a button class.
 * @param image The image for the tab icon.
 * @param selectedImage The image for the tab icon when it is selected.
 * @param buttonClass The class of the button to be displayed in the tab bar.
 * @return An initialized TBTabBarItem instance.
 */
- (instancetype)initWithImage:(UIImage *)image
                selectedImage:(nullable UIImage *)selectedImage
                  buttonClass:(nullable Class)buttonClass;

/**
 * @abstract Initializes a tab item with an image, a selected image, a title, and a button class.
 * @param image The image for the tab icon.
 * @param selectedImage The image for the tab icon when it is selected.
 * @param title The title of the tab item.
 * @param buttonClass The class of the button to be displayed in the tab bar.
 * @return An initialized TBTabBarItem instance.
 */
- (instancetype)initWithImage:(UIImage *)image
                selectedImage:(nullable UIImage *)selectedImage
                        title:(nullable NSString *)title
                  buttonClass:(nullable Class)buttonClass NS_DESIGNATED_INITIALIZER;

/**
 * @abstract This method is unavailable. Use designated initializers to create TBTabBarItem instances.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @abstract This method is unavailable. Use designated initializers to create TBTabBarItem instances.
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark - Extended

@interface TBTabBarItem (TBExtendedTabBarItem)

- (BOOL)isEqualToItem:(TBTabBarItem *)item NS_SWIFT_NAME(isEqual(to:));

@end

NS_ASSUME_NONNULL_END
