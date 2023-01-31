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
 * @abstract An item in a tab bar. Similar to UITabBarItem.
 */
@interface TBTabBarItem : NSObject <NSCopying>

/**
 * @abstract Describes whether item should be enabled or disabled. Default value is YES.
 */
@property (assign, nonatomic, getter = isEnabled) BOOL enabled NS_SWIFT_NAME(isEnabled);

/**
 * @abstract Describes whether should show a notification indicator next to the tab icon.
 * Default value is NO.
 */
@property (assign, nonatomic) BOOL showsNotificationIndicator;

/**
 * @abstract A tab title. By default it does not appear anywhere.
 */
@property (copy, nonatomic, nullable) NSString *title;

/**
 * @abstract A tab icon image.
 */
@property (strong, nonatomic) UIImage *image;

/**
 * @abstract A tab icon image when selected.
 */
@property (strong, nonatomic, nullable) UIImage *selectedImage;

/**
 * @abstract A notification indicator image that appears next to the tab icon.
 * By default it's a small dot.
 */
@property (strong, nonatomic, null_resettable) UIImage *notificationIndicator;

/**
 * @abstract A button class, instance of which will be displayed in the tab bar.
 * By default it's @b `TBTabBarButton` class.
 * @note It is supposed to be a kind of @b `TBTabBarButton` class.
 */
@property (strong, nonatomic, readonly) Class buttonClass;

- (instancetype)initWithImage:(UIImage *)image buttonClass:(nullable Class)buttonClass;

- (instancetype)initWithImage:(UIImage *)image
                selectedImage:(nullable UIImage *)selectedImage
                  buttonClass:(nullable Class)buttonClass;

- (instancetype)initWithImage:(UIImage *)image
                selectedImage:(nullable UIImage *)selectedImage
                        title:(nullable NSString *)title
                  buttonClass:(nullable Class)buttonClass NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark - Extended

@interface TBTabBarItem (TBExtendedTabBarItem)

- (BOOL)isEqualToItem:(TBTabBarItem *)item NS_SWIFT_NAME(isEqual(to:));

@end

NS_ASSUME_NONNULL_END
