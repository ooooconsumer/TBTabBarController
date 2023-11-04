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
#import <TBTabBarController/TBSimpleBar.h>
#import <TBTabBarController/TBTabBarItemsDifference.h>
#import <TBTabBarController/TBTabBarButton.h>

@class TBTabBar, TBTabBarItem;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Delegate

@protocol TBTabBarDelegate <NSObject>

@optional

/**
 * @abstract Notifies the delegate before selecting a new tab item.
 */
- (BOOL)tabBar:(TBTabBar *)tabBar
shouldSelectItem:(__kindof TBTabBarItem *)item
       atIndex:(NSUInteger)index;

/**
 * @abstract Notifies the delegate that the tab bar controller did select new tab.
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

@property (weak, nonatomic, nullable) id <TBTabBarDelegate> delegate;

/**
 * @abstract The items to be displayed. Shown in order.
 */
@property (weak, nonatomic, nullable, readonly) NSArray <__kindof TBTabBarItem *> *items;

/**
 * @abstract The currently visible items.
 */
@property (strong, nonatomic, readonly) NSArray <__kindof TBTabBarItem *> *visibleItems;

/**
 * @abstract The currently hidden items.
 */
@property (strong, nonatomic, readonly) NSArray <__kindof TBTabBarItem *> *hiddenItems;

/**
 * @abstract Returns YES whenever layout orientation is vertical.
 */
@property (assign, nonatomic, readonly, getter = isVertical) BOOL vertical NS_SWIFT_NAME(isVertical);

/**
 * @abstract Describes whether the tab bar is visible or not.
 */
@property (assign, nonatomic, readonly, getter = isVisible) BOOL visible NS_SWIFT_NAME(isVisible);

/**
 * @abstract When a tab is not selected, its tint color.
 */
@property (strong, nonatomic, null_resettable) UIColor *defaultTintColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract When a tab is selected, its tint color.
 */
@property (strong, nonatomic, null_resettable) UIColor *selectedTintColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract Notification indicator tint color. By default it equals to the tab bar's tint color.
 */
@property (strong, nonatomic, null_resettable) UIColor *notificationIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 * @abstract The currently selected tab index.
 * @discussion You can use this property to programmatically select a visible tab.
 */
@property (assign, nonatomic) NSUInteger selectedIndex;

/**
 * @abstract The maximum number of visible tabs. Default value is 5. A value of 0 means no limit.
 */
@property (assign, nonatomic) NSUInteger maxNumberOfVisibleTabs UI_APPEARANCE_SELECTOR;

/**
 * @abstract The space between tabs. Default value is 4pt.
 */
@property (assign, nonatomic) CGFloat spaceBetweenTabs UI_APPEARANCE_SELECTOR;

- (instancetype)initWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation;

+ (instancetype)horizontal;

+ (instancetype)vertical;

/**
 * @abstract Selects an item if it is presented either in the visible items list or in the hidden items list.
 */
- (void)selectItem:(__kindof TBTabBarItem *)item NS_SWIFT_NAME(select(_:));

/**
 * @abstract Return a button at the tab index, if any.
 * @discussion You can use this method to get buttons, since there is no public way to get all of them.
 */
- (nullable TBTabBarButton *)buttonAtTabIndex:(NSUInteger)tabIndex NS_SWIFT_NAME(button(at:));

@end

#pragma mark - Subclassing

@interface TBTabBar (Subclassing)

/**
 * @abstract A method that handles item updates by calculating the difference between the new items and the old ones.
 * @discussion You can override this method to provide your own mechanism to handle item updates.
 * @warning Do not call this method directly. Meant to be overridden.
 */
- (void)updateItems;

/**
 * @abstract A method that applies the difference for the visible items.
 */
- (void)applyVisibleItemsDifference:(TBTabBarItemsDifference *)difference;

/**
 * @abstract A method that applies the difference for the hidden items.
 */
- (void)applyHiddenItemsDifference:(TBTabBarItemsDifference *)difference;

/**
 * @abstract A visible item indexes. Default value is a range between 0 and @em `maxNumberOfVisibleTabs` property value.
 * @discussion By overriding this method, you can change order of the visible tabs.
 * For example, you can return a reversed indexes order.
 */
- (NSIndexSet *)visibleItemIndexes;

@end

NS_ASSUME_NONNULL_END
