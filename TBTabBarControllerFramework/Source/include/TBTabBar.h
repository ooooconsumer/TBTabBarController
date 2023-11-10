//
//  TBTabBar.h
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
#import "TBSimpleBar.h"

@class TBTabBar, TBTabBarItem, TBTabBarButton, TBTabBarItemsDifference;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Delegate

/**
 * @abstract The `TBTabBarDelegate` protocol defines a set of optional methods that can be adopted by an object 
 * to receive notifications related to tab selection in a `TBTabBar`. This delegate allows you to customize the behavior of the tab bar,
 * respond to tab selection events, and implement tab-specific functionality.
 * @discussion Conforming objects should implement only the methods that are relevant to their requirements. 
 * The delegate methods provide the ability to perform actions before and after tab selection, allowing you to enforce custom
 * selection rules or respond to tab changes in your user interface.
 */
@protocol TBTabBarDelegate <NSObject>

@optional

/**
 * @abstract Notifies the delegate before selecting a new tab item.
 * @discussion This method is called when a user attempts to select a new tab item in the `TBTabBar`.
 * You can implement this method to perform custom validations or to enforce rules regarding whether a particular tab should be selected.
 * @param tabBar The tab bar that triggered the event.
 * @param item The tab item that is being selected.
 * @param index The index of the tab item in the tab bar.
 * @return `YES` to allow the selection, `NO` to prevent it.
 */
- (BOOL)tabBar:(TBTabBar *)tabBar
shouldSelectItem:(__kindof TBTabBarItem *)item
       atIndex:(NSUInteger)index;

/**
 * @abstract Notifies the delegate that the tab bar did select a new tab item.
 * @discussion This method is called after the tab bar has successfully selected a new tab item.
 * You can use this callback to perform any post-selection actions or updates associated with the selected tab item.
 * @param tabBar The tab bar that triggered the event.
 * @param item The tab item that was selected.
 * @param index The index of the tab item in the tab bar.
 */
- (void)tabBar:(TBTabBar *)tabBar
 didSelectItem:(__kindof TBTabBarItem *)item
       atIndex:(NSUInteger)index;

@end

#pragma mark - Tab bar

typedef NS_ENUM(NSInteger, TBTabBarLayoutOrientation) {
    TBTabBarLayoutOrientationHorizontal,
    TBTabBarLayoutOrientationVertical
};

/**
 * @abstract A tab bar used for displaying and managing tab items.
 * @discussion `TBTabBar` is a subclass of `TBSimpleBar` and provides functionality for managing tab items 
 * within a user interface. It allows you to customize the appearance and behavior of the tab bar.
 */
@interface TBTabBar : TBSimpleBar <UIGestureRecognizerDelegate> {

@protected

    struct {
        BOOL shouldSelectItemAtIndex:1;
        BOOL didSelectItemAtIndex:1;
    } _delegateFlags;

    NSMutableArray <__kindof TBTabBarItem *> *_visibleItems;
    NSMutableArray <__kindof TBTabBarItem *> *_hiddenItems;

    NSUInteger _itemsCount;

    BOOL _shouldSelectItem;
}

/**
 * @abstract The delegate for the TBTabBar.
 * @discussion The delegate is responsible for handling events and actions associated with the tab bar.
 */
@property (weak, nonatomic, nullable) id <TBTabBarDelegate> delegate;

/**
 * @abstract The items to be displayed in the tab bar. These items are shown in the order they appear in the array.
 */
@property (weak, nonatomic, nullable, readonly) NSArray <__kindof TBTabBarItem *> *items;

/**
 * @abstract The currently visible tab items in the tab bar.
 */
@property (strong, nonatomic, readonly) NSArray <__kindof TBTabBarItem *> *visibleItems;

/**
 * @abstract The currently hidden tab items in the tab bar.
 */
@property (strong, nonatomic, readonly) NSArray <__kindof TBTabBarItem *> *hiddenItems;

/**
 * @abstract Indicates whether the tab bar's layout orientation is vertical.
 */
@property (assign, nonatomic, readonly, getter = isVertical) BOOL vertical NS_SWIFT_NAME(isVertical);

/**
 * @abstract Indicates whether the tab bar is visible.
 */
@property (assign, nonatomic, readonly, getter = isVisible) BOOL visible NS_SWIFT_NAME(isVisible);

/**
 * @abstract The tint color of unselected tab items.
 */
@property (strong, nonatomic, null_resettable) UIColor *defaultTintColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract The tint color of the selected tab item.
 */
@property (strong, nonatomic, null_resettable) UIColor *selectedTintColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract The tint color of the notification indicator. By default, it matches the tab bar's tint color.
 */
@property (strong, nonatomic, null_resettable) UIColor *notificationIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract The index of the currently selected tab.
 * @discussion You can use this property to programmatically select a tab in the tab bar.
 */
@property (assign, nonatomic) NSUInteger selectedIndex;

/**
 * @abstract The maximum number of visible tabs. A value of 0 means there is no limit. The default value is 5.
 */
@property (assign, nonatomic) NSUInteger maxNumberOfVisibleTabs UI_APPEARANCE_SELECTOR;

/**
 * @abstract The space between tab items. The default value is 4pt.
 */
@property (assign, nonatomic) CGFloat spaceBetweenTabs UI_APPEARANCE_SELECTOR;

/**
 * @abstract Initializes a TBTabBar instance with the specified layout orientation.
 * @param layoutOrientation The desired layout orientation for the tab bar. Use `TBTabBarLayoutOrientationHorizontal` 
 * for a horizontal tab bar or `TBTabBarLayoutOrientationVertical` for a vertical tab bar.
 * @return An initialized TBTabBar instance with the specified layout orientation.
 */
- (instancetype)initWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation;

/**
 * @abstract Initializes and returns a horizontal TBTabBar instance.
 * @return A TBTabBar instance with a horizontal layout orientation.
 */
+ (instancetype)horizontal;

/**
 * @abstract Initializes and returns a vertical TBTabBar instance.
 * @return A TBTabBar instance with a vertical layout orientation.
 */
+ (instancetype)vertical;

/**
 * @abstract Selects a tab item if it is present in either the visible items list or the hidden items list.
 * @param item The tab item to be selected.
 */
- (void)selectItem:(__kindof TBTabBarItem *)item NS_SWIFT_NAME(select(_:));

/**
 * @abstract Returns the TBTabBarButton associated with a tab at a given index.
 * @param tabIndex The index of the tab.
 * @return The TBTabBarButton at the specified index, or nil if it does not exist.
 * @discussion Use this method to retrieve the buttons associated with tab items. Since there is no public way to access 
 * all buttons directly, this method provides a way to retrieve them based on their index.
 */
- (nullable TBTabBarButton *)buttonAtTabIndex:(NSUInteger)tabIndex NS_SWIFT_NAME(button(at:));

@end

#pragma mark - Subclassing

/**
 * @abstract A category that provides methods for subclassing `TBTabBar` and handling item updates.
 * @discussion Use these methods when customizing the behavior of `TBTabBar` or when you want to implement
 * your own mechanism for handling item updates.
 */
@interface TBTabBar (Subclassing)

/**
 * @abstract Handles item updates by calculating the difference between the new items and the old ones.
 * @discussion Override this method to implement your own mechanism for handling item updates. 
 * This method is called automatically when items are updated.
 * @warning Do not call this method directly; it is meant to be overridden in your subclass.
 */
- (void)updateItems;

/**
 * @abstract Applies the difference to the visible tab items.
 * @param difference The difference between the new and old tab items.
 */
- (void)applyVisibleItemsDifference:(TBTabBarItemsDifference *)difference;

/**
 * @abstract Applies the difference to the hidden tab items.
 * @param difference The difference between the new and old tab items.
 */
- (void)applyHiddenItemsDifference:(TBTabBarItemsDifference *)difference;

/**
 * @abstract Returns the indexes of visible tab items. The default value is a range from 0 to the value of the `maxNumberOfVisibleTabs` property.
 * @discussion Override this method to change the order of visible tabs. For example, you can return a reversed order of indexes if needed.
 */
- (NSIndexSet *)visibleItemIndexes;

@end

NS_ASSUME_NONNULL_END
