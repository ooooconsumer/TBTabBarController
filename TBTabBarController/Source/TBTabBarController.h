//
//  TBTabBarController.h
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

#import <TBTabBarController/TBDummyBar.h>
#import <TBTabBarController/TBTabBar.h>
#import <TBTabBarController/TBTabBarItem.h>

@class TBTabBarController;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TBTabBarControllerTabBarPosition) {
    /// The tab bar position is undefined. Typically this used for @p `_preferredPosition` when there's no any tab bar position update. The current position also can be undifined until the tab bar will be presented
    TBTabBarControllerTabBarPositionUndefined,
    /// The tab bar is hidden
    TBTabBarControllerTabBarPositionHidden,
    /// When this value is used, the @em vertical tab bar will be presented on the bottom of the view
    TBTabBarControllerTabBarPositionLeading,
    /// Will be available soon
    TBTabBarControllerTabBarPositionTrailing NS_UNAVAILABLE,
    /// When this value is used, the @em horizontal tab bar will be presented on the bottom of the view
    TBTabBarControllerTabBarPositionBottom,
};

#pragma mark - Delegate

/**
 * @discussion Keep in mind that only the @em visible tab bar will call these methods.
 */
@protocol TBTabBarControllerDelegate <NSObject>

@optional

/**
 * @abstract Notifies the delegate before selecting a new tab item.
 */
- (BOOL)tabBarController:(TBTabBarController *)tabBarController
        shouldSelectItem:(__kindof TBTabBarItem *)item atIndex:(NSUInteger)index;

/**
 * @abstract Notifies the delegate that the tab bar controller did select new tab.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController
           didSelectItem:(__kindof TBTabBarItem *)item atIndex:(NSUInteger)index;

/**
 * @abstract Notifies the delegate before selecting a new view controller.
 * @discussion Use this method if you want to do something with the view controller
 * before it will be selected.
 */
- (BOOL)tabBarController:(TBTabBarController *)tabBarController
shouldSelectViewController:(__kindof UIViewController * _Nullable)viewController;

/**
 * @abstract Notifies the delegate that the tab bar controller did select new tab.
 * @discussion If you want to do something with the selected view controller before the user will actually select it you can use the method above.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController
 didSelectViewController:(__kindof UIViewController *)viewController;

/**
 * @abstract Notifies the delegate before the controller will show a tab bar.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController willShowTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Notifies the delegate after the controller did show a tab bar.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController didShowTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Notifies the delegate before the controller will hide a tab bar.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController willHideTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Notifies the delegate after the controller did hide a tab bar.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController didHideTabBar:(TBTabBar *)tabBar;

@end

#pragma mark - Tab bar controller

/**
 * @abstract A view controller that can display multiple child view controllers
 * with either a vertical or horizontal tab bar.
 * @discussion You have to keep in mind, that controller actually contains @em two tab bars.
 * The first one is horizontal and lives on the bottom of the view,
 * and the other one is vertical and can be displayed on the left or right side.
 * Which one will be displayed depends on either the view size or the horizontal size class.
 * By default, the controller relies on the horizontal size classes,
 * but you can always override this behaviour.
 */
@interface TBTabBarController : UIViewController <TBTabBarDelegate> {
    
@protected
    
    BOOL _shouldSelectViewController;
    BOOL _didPresentTabBarOnce;
    BOOL _visibleViewControllerWantsHideTabBar;
    
    TBTabBarControllerTabBarPosition _currentPosition;
    TBTabBarControllerTabBarPosition _preferredPosition;
        
    struct {
        BOOL shouldSelectItemAtIndex:1;
        BOOL didSelectItemAtIndex:1;
        BOOL shouldSelectViewController:1;
        BOOL didSelectViewController:1;
        BOOL willShowTabBar:1;
        BOOL didShowTabBar:1;
        BOOL willHideTabBar:1;
        BOOL didHideTabBar:1;
    } _delegateFlags;
        
    NSMutableArray <TBTabBarItem *> *_items;
}

@property (weak, nonatomic, nullable) id <TBTabBarControllerDelegate> delegate;

/**
 * @abstract The view controllers to be displayed. Shown in order.
 */
@property (copy, nonatomic, nullable) NSArray <__kindof UIViewController *> *viewControllers;

/**
 * @abstract Displayed items.
 */
@property (copy, nonatomic, nullable, readonly) NSArray <__kindof TBTabBarItem *> *items;

/**
 * @abstract The currently selected view controller.
 */
@property (assign, nonatomic, nullable, readonly) __kindof UIViewController *selectedViewController;

/**
 * @abstract A pop gesture recognizer for the vertical tab bar.
 * @discussion When the vertical bar is shown, it overlaps default back gesture recognizer.
 * With this gesture recognizer users can swipe on the bar to pop the top view controller.
 */
@property (strong, nonatomic, readonly) UISwipeGestureRecognizer *popGestureRecognizer;

/**
 * @abstract An empty view that matches the navigation bar of the selected view controller, if any.
 */
@property (strong, nonatomic, readonly) TBDummyBar *dummyBar;

/**
 * @abstract The horizontal tab bar at the bottom of the controller.
 */
@property (strong, nonatomic, readonly) TBTabBar *horizontalTabBar;

/**
 * @abstract The vertical tab bar at the left side of the controller.
 */
@property (strong, nonatomic, readonly) TBTabBar *verticalTabBar;

/**
 * @abstract The currently visible tab bar, if any.
 * @discussion Because this property may return nil value (see note),
 * you probably want to use  @em `currentlyVisibleTabBar:hiddenTabBar:` method.
 * That method retrieves both the visible tab bar and the hidden one.
 * @note Before iOS 13 equals to nil when the trait collection is not initialazed yet.
 * It can be nil as well either when there is no visible tab bar, or
 * when the controller is updating the tab bar position.
 */
@property (weak, nonatomic, readonly, nullable) TBTabBar *visibleTabBar;

/**
 @abstract The currently selected view controller index.
 */
@property (assign, nonatomic) NSUInteger selectedIndex;

/**
 * @abstract Describes the index, which tab should be presented first. Default value is 0.
 */
@property (assign, nonatomic) NSUInteger startingIndex;

/**
 * @abstract The height of the bottom tab bar. Default value is 49pt.
 */
@property (assign, nonatomic) CGFloat horizontalTabBarHeight;

/**
 * @abstract The width of the vertical tab bar. Default value is 60pt.
 */
@property (assign, nonatomic) CGFloat verticalTabBarWidth;

@property (assign, nonatomic) CGFloat dummyBarHeight NS_UNAVAILABLE;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
/**
 * @abstract Notifies the tab bar controller before the visible tab bar will be added
 * to a view hierarchy for the first time. Do not call directly.
 */
- (void)willPresentTabBar NS_REQUIRES_SUPER;

/**
 * @abstract Notifies the tab bar controller just after the tab bar was added
 * to a view hierarchy for the first time. Do not call directly.
 */
- (void)didPresentTabBar NS_REQUIRES_SUPER;

/**
 * @abstract A method that relies on the current tab bar position (or the preferred one — which one
 * is used is depending on the context) and returns pointers to both visible tab bar
 * and the hidden one, if possible.
 * @discussion If there's no visible or hidden tab bar, it means that they are both hidden.
 * So, you have to call @b `_specifyPreferredTabBarPositionForHorizontalSizeClass:size:` method.
 * It will specify the preferred tab bar position, so you can call this method again to fetch
 * the hidden tab bar.
 * @code
    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];

    if (visibleTabBar != nil) {
        // do things with the visible bar
    } else if (hiddenTabBar != nil) {
        // do things with the hidden bar
    } else {
        // there are no bars — you should specify their visibility manually
    }
 */
- (void)currentlyVisibleTabBar:(TBTabBar *_Nullable *_Nullable)visibleTabBar
                  hiddenTabBar:(TBTabBar *_Nullable *_Nullable)hiddenTabBar;
/**
 * @abstract Begins the tab bar position update if needed. Animatable.
 * @discussion To perform any changes to the tab bar position (hiding, changing side, etc...)  you have to create a new subclass of @p `TBTabBarController` class.
 * Then, you have to override one of the methods from the @b `Subclassing` category and write your custom logic there.
 * There is another way, based on setting your own value to the @p `_preferredPosition` instance variable before calling this method, but it's not preferred (ba-dum-tss!).
 * @note You should @B always call @em `endUpdateTabBarPosition` method after calling this one.
 * @code 
    [UIView animateWithDuration:0.3 animations:^{
        [self beginUpdateTabBarPosition];
    } completion:^(BOOL finished) {
        [self endUpdateTabBarPosition];
    }];
 */
- (void)beginUpdateTabBarPosition;

/**
 * @abstract Ends the tab bar position update.
 * @note Unbalanced calls may lead to unexpected behaviour.
 * @see Please, see @b `beginUpdateTabBarPosition` method descriptiption.
 */
- (void)endUpdateTabBarPosition;

/**
 * @abstract Adds an item to the end of the items list and creates the button that will be placed in the tab bar within the next view layout cycle update. Animatable.
 * @discussion Sometimes you want to add a simple button in the middle of the tab bar that won't perform any default actions.
 * You can use the delegate methods to observe button actions and restrict unnecessary selections.
 */
- (void)addItem:(__kindof TBTabBarItem *)item;

/**
 * @abstract Inserts an item to the items list at the specific index. Animatable.
 * @see Please, see @b `addItem:` method description.
 */
- (void)insertItem:(__kindof TBTabBarItem *)item atIndex:(NSUInteger)index;

/**
 * @abstract Removes an item from the items list at the specific index. Animatable.
 * @warning The current implementation does not handle removal of the view controller, if there is any.
 * @b Workaround: manually remove the view controller from the view controllers list and set the updated array to the @b `viewControllers` property.
 */
- (void)removeItemAtIndex:(NSUInteger)index NS_SWIFT_NAME(removeItem(at:));

@end

#pragma mark - Subclassing

/**
 * @abstract A category that contains methods for controlling the positioning and appearence of the tab bar.
 * @warning You should never override @em `preferredTabBarPositionForHorizontalSizeClass:` and @em `preferredTabBarPositionForViewSize:` at once.
 */
@interface TBTabBarController (Subclassing)

/**
 * @discussion Called when the view is going to transition to the new horizontal size class.
 * @param sizeClass A new horizontal size class.
 * @return A preferred tab bar position for the given view size.
 */
- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass;

/**
 * @discussion Called when the view is going to transition to the new size.
 * You can call super to see what's the preferred position for the given size as well.
 * By default, this method relies on the horizontal size class and not on the view size.
 * @param size A new view size.
 * @return A preferred tab bar position for the given view size.
 */
- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForViewSize:(CGSize)size;

/**
 * @abstract A class for the horizontal tab bar. Default value is TBTabBar class.
 * @note Must be a type of TBTabBar.
 */
+ (Class)horizontalTabBarClass;

/**
 * @abstract A class for the vertical tab bar. Default value is TBTabBar class.
 * @note Must be a type of TBTabBar.
 */
+ (Class)verticalTabBarClass;

@end

#pragma mark -  View controller extension

@interface UIViewController (TBTabBarControllerExtension)

@property (strong, nonatomic, null_resettable, setter = tb_setTabBarItem:) TBTabBarItem *tb_tabBarItem;

@property (assign, nonatomic, readonly, nullable) TBTabBarController *tb_tabBarController;

@property (assign, nonatomic, setter = tb_setHidesTabBarWhenPushed:) BOOL tb_hidesTabBarWhenPushed;

@end

#pragma mark - Navigation controller delegate

@protocol TBNavigationControllerExtensionDelegate <NSObject>

@required

- (void)tb_navigationController:(UINavigationController *)navigationController navigationBarDidChangeHeight:(CGFloat)height;

- (void)tb_navigationController:(UINavigationController *)navigationController didBeginTransitionFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController backwards:(BOOL)backwards;

- (void)tb_navigationController:(UINavigationController *)navigationController didUpdateInteractiveFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController percentComplete:(CGFloat)percentComplete;

- (void)tb_navigationController:(UINavigationController *)navigationController willEndTransitionFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController cancelled:(BOOL)cancelled;

- (void)tb_navigationController:(UINavigationController *)navigationController didEndTransitionFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController cancelled:(BOOL)cancelled;

@end

#pragma mark - Navigation controller extension

@interface UINavigationController (TBTabBarControllerExtension)

@property (weak, nonatomic, readonly, nullable) id<TBNavigationControllerExtensionDelegate> tb_delegate;

@end

#pragma mark - Navigation controller default delegate

@interface TBTabBarController (TBNavigationControllerExtensionDefaultDelegate) <TBNavigationControllerExtensionDelegate>

@end

NS_ASSUME_NONNULL_END
