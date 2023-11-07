//
//  TBTabBar+Private.h
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

#import <Foundation/Foundation.h>

#if SWIFT_PACKAGE
#import "TBTabBarController.h"
#else
#import <TBTabBarController/TBTabBarController.h>
#endif

@class TBTabBarItem, TBTabBarItemsDifference;

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract A private category that provides additional methods and properties for `TBTabBar`.
 * @discussion These methods and properties provided for internal implementation purposes. 
 * Use these methods and properties at your own risk for advanced customization of the tab bar's behavior.
 */
@interface TBTabBar (Private)

/**
 * @abstract The current placement of the tab bar.
 * @discussion This property represents the current placement of the tab bar, such as whether it's hidden, 
 * displayed at the top, bottom, or sides of the screen.
 */
@property (assign, nonatomic, readonly) TBTabBarControllerTabBarPlacement currentPlacement;

/**
 * @abstract Sets the array of tab items for the tab bar.
 * @param items An array of TBTabBarItem instances to set as tab items.
 */
- (void)_setItems:(NSArray <__kindof TBTabBarItem *> *)items;

/**
 * @abstract Sets the selected index for the tab bar.
 * @param selectedIndex The index of the tab item to select.
 * @param quietly A flag indicating whether the selection should be made quietly without any animation or feedback.
 */
- (void)_setSelectedIndex:(NSUInteger)selectedIndex quietly:(BOOL)quietly;

/**
 * @abstract Deselects the currently selected tab item.
 */
- (void)_deselect;

/**
 * @abstract Creates a `TBTabBarButton` instance for the given tab item.
 * @param item The tab item for which to create a button.
 * @return A `TBTabBarButton` instance associated with the specified tab item.
 */
- (__kindof TBTabBarButton *)_makeButtonWithItem:(__kindof TBTabBarItem *)item;

/**
 * @abstract Returns an array of `TBTabBarButton` instances in the tab bar.
 * @return An array of `TBTabBarButton` instances currently present in the tab bar.
 */
- (NSArray<__kindof TBTabBarButton *> *)_buttons;

/**
 * @abstract Adds a `TBTabBarButton` to the tab bar.
 * @param button The TBTabBarButton to add.
 */
- (void)_addButton:(__kindof TBTabBarButton *)button;

/**
 * @abstract Inserts a `TBTabBarButton` at a specific index in the tab bar.
 * @param button The TBTabBarButton to insert.
 * @param index The index at which to insert the button.
 */
- (void)_insertButton:(__kindof TBTabBarButton *)button atIndex:(NSUInteger)index;

/**
 * @abstract Sets the enabled state for a button at a specific index in the tab bar.
 * @param enabled A boolean value indicating whether the button should be enabled.
 * @param index The index of the button to set the enabled state for.
 */
- (void)_setButtonEnabled:(BOOL)enabled atIndex:(NSUInteger)index;

/**
 * @abstract Sets the normal image for a button at a specific index in the tab bar.
 * @param image The normal image to set for the button.
 * @param index The index of the button to set the normal image for.
 */
- (void)_setNormalImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

/**
 * @abstract Sets the selected image for a button at a specific index in the tab bar.
 * @param image The selected image to set for the button.
 * @param index The index of the button to set the selected image for.
 */
- (void)_setSelectedImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

/**
 * @abstract Sets the notification indicator image for a button at a specific index in the tab bar.
 * @param image The notification indicator image to set for the button.
 * @param index The index of the button to set the notification indicator image for.
 */
- (void)_setNotificationIndicatorImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

/**
 * @abstract Sets the visibility of the notification indicator for a button at a specific index in the tab bar.
 * @param hidden A boolean value indicating whether the notification indicator should be hidden.
 * @param index The index of the button to set the notification indicator visibility for.
 */
- (void)_setNotificationIndicatorHidden:(BOOL)hidden forButtonAtIndex:(NSUInteger)index;

/**
 * @abstract Sets additional content insets for the tab bar.
 * @param additionalContentInsets The UIEdgeInsets to set as additional content insets.
 */
- (void)_setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets;

/**
 * @abstract Sets the visibility of the tab bar.
 * @param visible A boolean value indicating whether the tab bar should be visible.
 */
- (void)_setVisible:(BOOL)visible;

/**
 * @abstract Prepares for a transition to a new tab bar placement.
 * @param preferredTabBarPlacement The preferred tab bar placement for the transition.
 */
- (void)_prepareForTransitionToPlacement:(TBTabBarControllerTabBarPlacement)preferredTabBarPlacement;

@end

NS_ASSUME_NONNULL_END
