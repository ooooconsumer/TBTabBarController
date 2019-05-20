//
//  TBTabBarController.h
//  TBTabBarController
//
//  Copyright (c) 2019 Timur Ganiev
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

#import "TBTabBar.h"
#import "TBTabBarItem.h"
#import "TBFakeNavigationBar.h"

@class TBTabBarController;

typedef NS_ENUM(NSUInteger, TBTabBarControllerTabBarPosition) {
    TBTabBarControllerTabBarPositionUnspecified = 0,
    TBTabBarControllerTabBarPositionLeft = 1,
    TBTabBarControllerTabBarPositionBottom = 2
};

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat TBFakeNavigationBarAutomaticDimension;

@protocol TBTabBarControllerDelegate <NSObject>

@optional

- (BOOL)tabBarController:(TBTabBarController *)tabBarController shouldSelectViewController:(__kindof UIViewController *)viewController;

- (void)tabBarController:(TBTabBarController *)tabBarController didSelectViewController:(__kindof UIViewController *)viewController;

@end

#pragma mark -

/**
 * @discussion You have to keep in mind, that controller actually has two tab bar views.
 * Which one is displayed depends either on the view size or the horizontal size class.
 * By default, controller relies on the horizontal size class (like Tweetbot does).
 * When it's regular, the vertical tab bar will be displayed. Otherwise, the horizontal one.
 * You can always override default behaviour by overriding one of the methods from the Subclasses category (see below).
 * @note Currently there are a lot of limitations. Please, read the README file before using this controller.
 */
@interface TBTabBarController : UIViewController <TBTabBarDelegate>

/** @brief The view controllers to display. */
@property (copy, nonatomic, nullable) NSArray <__kindof UIViewController *> *viewControllers;

/** @brief The currently selected view controller. */
@property (weak, nonatomic, nullable) __kindof UIViewController *selectedViewController;

/** @brief Describes the index, which tab should be presented first. Default is 0. */
@property (assign, nonatomic) NSUInteger startingIndex;

/** @brief The currently selected tab index. */
@property (assign, nonatomic) NSUInteger selectedIndex;

/**
 * @brief A pop gesture recognizer for the left tab bar.
 * @discussion Since default solution does not work when the left bar is presented (i.e. on iPhones when landscape), users can swipe right to pop view controller.
 */
@property (strong, nonatomic, readonly) UISwipeGestureRecognizer *popGestureRecognizer;

/** @brief The horizontal tab bar at the bottom of the controller. */
@property (strong, nonatomic, readonly) TBTabBar *bottomTabBar;

/** @brief The horizontal tab bar at the bottom of the controller. */
@property (strong, nonatomic, readonly) TBTabBar *leftTabBar;

/**
 * @brief The currently visible tab bar.
 * @note May be nil when the trait collection is not loaded yet or the view is transitioning to the new trait collection (or size).
 */
@property (weak, nonatomic, readonly, nullable) TBTabBar *visibleTabBar;

/**
 * @brief The currently hidden tab bar.
 * @note May be nil when the trait collection is not loaded yet or the view is transitioning to the new trait collection (or size).
 */
@property (weak, nonatomic, readonly, nullable) TBTabBar *hiddenTabBar;

/**
 * @discussion View that mimics UINavigationBar.
 * Appears only when the left tab bar is presented.
 */
@property (strong, nonatomic, readonly) TBFakeNavigationBar *fakeNavigationBar;

/** @brief The height of the bottom tab bar. Default is 49pt. */
@property (assign, nonatomic) CGFloat horizontalTabBarHeight;

/** @brief The width of the left tab bar. Default is 60pt. */
@property (assign, nonatomic) CGFloat verticalTabBarWidth;

/** @brief The height of the fake navigation bar. Default is TBFakeNavigationBarAutomaticDimension. */
@property (assign, nonatomic) CGFloat fakeNavigationBarHeight;

@property (weak, nonatomic, nullable) id <TBTabBarControllerDelegate> delegate;

@end

#pragma mark -

/**
 * @discussion This category contains two methods that determine the position of the tab bar.
 * Override one of them, if you want to customize positioning behavior of the tab bar.
 * For more information, please see description of the original class.
 * @note You should never override both methods.
 */
@interface TBTabBarController (Subclasses)

/**
 * @brief Called when the view is going to transition to the new horizontal size class.
 * @param sizeClass New horizontal size class.
 */
- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass;

/**
 * @discussion Called when the view is going to transition to the new size.
 * This method can be useful for iPad devices that have split view and slide over modes.
 * You can call super to see what's the preferred position for the given size as well.
 * By default, this method relies on the horizontal size class (as the method above).
 * @param size New view size.
 */
- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForViewSize:(CGSize)size;

@end

#pragma mark -

/** @brief Similar to UITabBarControllerItem category. */
@interface UIViewController (TBTabBarControllerItem)

/**
 * @brief Automatically created by the tab bar controller.
 * @note There is no title on the tab bar buttons.
 */
@property (strong, nonatomic, readonly) TBTabBarItem *tb_tabBarItem;

@property (strong, nonatomic, readonly, nullable) TBTabBarController *tb_tabBarController;

@end

NS_ASSUME_NONNULL_END
