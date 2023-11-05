//
//  TBTabBarController.h
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

#import <TBTabBarController/TBDummyBar.h>
#import <TBTabBarController/TBTabBar.h>
#import <TBTabBarController/TBTabBarItem.h>

@class TBTabBarController;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TBTabBarControllerTabBarPlacement) {
    /// The tab bar placement is undefined. This is typically used for `_preferredPlacement`
    /// when there's no tab bar placement update. The current placement can also be undefined until the tab bar is presented.
    TBTabBarControllerTabBarPlacementUndefined,

    /// The tab bar will be hidden.
    TBTabBarControllerTabBarPlacementHidden,

    /// A vertical tab bar attached to the leading side of the screen will be used.
    TBTabBarControllerTabBarPlacementLeading,

    /// A vertical tab bar attached to the trailing side of the screen will be used.
    TBTabBarControllerTabBarPlacementTrailing,

    /// A horizontal tab bar attached to the bottom side of the screen will be used.
    TBTabBarControllerTabBarPlacementBottom,
};

#pragma mark - Delegate

/**
 * @abstract The `TBTabBarControllerDelegate` protocol defines a set of optional methods that can be adopted
 * by an object to receive notifications and control various aspects of a `TBTabBarController`. The delegate allows you
 * to respond to tab selection, view controller transitions, and customize tab bar-related behavior.
 * @discussion This delegate is your primary interface for interacting with a `TBTabBarController`. It provides methods
 * for fine-grained control over the tab switching process, the selection of view controllers, and the appearance of the tab bar.
 * You can use these methods to define custom behavior, perform pre- and post-selection actions,
 * and provide animations for transitions between tabs.
 * @note Please note that these delegate methods are only called by the currently visible tab bar.
 */
@protocol TBTabBarControllerDelegate <NSObject>

@optional

/**
 * @abstract Notifies the delegate before selecting a new tab item.
 * @discussion This method is called when the user attempts to select a new tab item in the tab bar controller. Returning `NO` will prevent the tab switch.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param item The tab item that is being selected.
 * @param index The index of the tab item in the tab bar.
 * @return `YES` to allow the selection, `NO` to prevent it.
 */
- (BOOL)tabBarController:(TBTabBarController *)tabBarController
        shouldSelectItem:(__kindof TBTabBarItem *)item
                 atIndex:(NSUInteger)index;

/**
 * @abstract Notifies the delegate when the tab bar controller selects a new tab.
 * @discussion This method is called after the tab bar controller has successfully selected a new tab item. Use this callback for post-selection actions or updates.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param item The tab item that was selected.
 * @param index The index of the tab item in the tab bar.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController
           didSelectItem:(__kindof TBTabBarItem *)item
                 atIndex:(NSUInteger)index;

/**
 * @abstract Notifies the delegate before selecting a new view controller.
 * @discussion This method is called before the tab bar controller switches to a different view controller. 
 * You can use this method to perform actions or validations on the view controller before it is presented to the user.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param viewController The view controller that is being selected.
 * @return `YES` to allow the selection, `NO` to prevent it.
 */
- (BOOL)tabBarController:(TBTabBarController *)tabBarController
shouldSelectViewController:(__kindof UIViewController * _Nullable)viewController;

/**
 * @abstract Notifies the delegate when the tab bar controller selects a new view controller.
 * @discussion This method is called after the tab bar controller has successfully selected a new view controller. 
 * You can use this callback to perform additional actions on the selected view controller.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param viewController The view controller that was selected.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController
 didSelectViewController:(__kindof UIViewController *)viewController;

/**
 * @abstract Notifies the delegate before the controller shows the tab bar.
 * @discussion This method is called when the tab bar controller is about to display the tab bar. 
 * You can use this callback to prepare or animate the tab bar's appearance.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param tabBar The tab bar view that will be shown.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController willShowTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Notifies the delegate after the controller has shown the tab bar.
 * @discussion This method is called once the tab bar controller has successfully displayed the tab bar. 
 * You can use this callback for additional actions or animations.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param tabBar The tab bar view that has been shown.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController didShowTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Notifies the delegate before the controller hides the tab bar.
 * @discussion This method is called when the tab bar controller is about to hide the tab bar. 
 * You can use this callback to prepare or animate the tab bar's disappearance.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param tabBar The tab bar view that will be hidden.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController willHideTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Notifies the delegate after the controller has hidden the tab bar.
 * @discussion This method is called once the tab bar controller has successfully hidden the tab bar. 
 * You can use this callback for additional actions or animations.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param tabBar The tab bar view that has been hidden.
 */
- (void)tabBarController:(TBTabBarController *)tabBarController didHideTabBar:(TBTabBar *)tabBar;

/**
 * @abstract Asks the delegate for an animation controller responsible for animating transitions between tabs.
 * @discussion Use this method to provide a custom animation controller for transitioning between view controllers 
 * within the tab bar controller. Return an object conforming to the `UIViewControllerAnimatedTransitioning` protocol
 * to define the transition animations.
 * @param tabBarController The tab bar controller that triggered the event.
 * @param fromViewController The view controller from which the transition originates.
 * @param toViewController The view controller to which the transition is directed.
 * @return An object conforming to the `UIViewControllerAnimatedTransitioning` protocol.
 */
- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(TBTabBarController *)tabBarController
           animationControllerForTransitionFromViewController:(nullable UIViewController *)fromViewController
                                             toViewController:(nullable UIViewController *)toViewController;

@end

#pragma mark - Tab bar controller

/**
 * @abstract `TBTabBarController` is a view controller designed to manage and display multiple child view controllers
 * using a tab bar. What makes it unique is its ability to support both vertical and horizontal tab bar layouts,
 * offering flexibility in how your app's navigation is presented.
 * @discussion It's important to note that TBTabBarController actually incorporates two tab bars within its design. 
 * The first tab bar is positioned horizontally and resides at the bottom of the view, while the second tab bar is oriented vertically
 * and can be displayed either on the left or right side of the screen. The choice between horizontal and vertical tab bar presentation
 * depends on factors like the view's size or the horizontal size class.
 * By default, the controller follows the horizontal size classes to determine which tab bar layout to use.
 * However, you have the option to customize this behavior and manually specify whether the horizontal or vertical tab bar
 * should be displayed, giving you full control over your app's user interface.
 */
@interface TBTabBarController : UIViewController <TBTabBarDelegate> {

@protected

    struct {
        BOOL shouldSelectItemAtIndex:1;
        BOOL didSelectItemAtIndex:1;
        BOOL shouldSelectViewController:1;
        BOOL didSelectViewController:1;
        BOOL willShowTabBar:1;
        BOOL didShowTabBar:1;
        BOOL willHideTabBar:1;
        BOOL didHideTabBar:1;
        BOOL animationControllerForTransition:1;
    } _delegateFlags;

    NSMutableArray <TBTabBarItem *> *_items;

    TBTabBarControllerTabBarPlacement _currentPlacement;
    TBTabBarControllerTabBarPlacement _preferredPlacement;

    BOOL _shouldSelectViewController;
    BOOL _didPresentTabBarOnce;
    BOOL _visibleViewControllerWantsHideTabBar;
}

/**
 * @abstract The delegate object responsible for handling tab bar controller events and interactions.
 * @discussion The delegate conforms to the `TBTabBarControllerDelegate` protocol, 
 * which provides methods for customizing tab selection, tab bar appearance, and view controller transitions.
 *
 * The delegate methods include:
 * - `tabBarController:shouldSelectItem:atIndex:`: Notifies the delegate before selecting a new tab item.
 * - `tabBarController:didSelectItem:atIndex:`: Notifies the delegate that the tab bar controller did select a new tab.
 * - `tabBarController:shouldSelectViewController:`: Notifies the delegate before selecting a new view controller. 
 *    Use this method if you want to perform actions on the view controller before it is selected.
 * - `tabBarController:didSelectViewController:`: Notifies the delegate that the tab bar controller did select a new
 *    view controller. If you want to perform actions on the selected view controller before the user actually selects it, you can use the method above.
 * - `tabBarController:willShowTabBar:`: Notifies the delegate before the controller shows a tab bar.
 * - `tabBarController:didShowTabBar:`: Notifies the delegate after the controller has shown a tab bar.
 * - `tabBarController:willHideTabBar:`: Notifies the delegate before the controller hides a tab bar.
 * - `tabBarController:didHideTabBar:`: Notifies the delegate after the controller has hidden a tab bar.
 * - `tabBarController:animationControllerForTransitionFromViewController:toViewController:`: Asks 
 *    the delegate for an animation controller responsible for performing animations during tab transitions.
 *
 * You can implement these optional methods in your delegate object to customize the behavior and appearance of the tab bar controller.
 */
@property (weak, nonatomic, nullable) id <TBTabBarControllerDelegate> delegate;

/**
 * @abstract An array of view controllers to be displayed in the tab bar controller. 
 * They will be shown in the order they appear in the array.
 */
@property (copy, nonatomic, nullable) NSArray <__kindof UIViewController *> *viewControllers;

/**
 * @abstract An array of displayed items within the tab bar controller.
 */
@property (copy, nonatomic, nullable, readonly) NSArray <__kindof TBTabBarItem *> *items;

/**
 * @abstract The view controller that is currently selected within the tab bar controller.
 */
@property (assign, nonatomic, nullable, readonly) __kindof UIViewController *selectedViewController;

/**
 * @abstract A pop gesture recognizer for the vertical tab bar.
 * @discussion When the vertical bar is displayed, it overlaps the default back gesture recognizer. 
 * This gesture recognizer allows users to perform a swipe gesture on the vertical tab bar to pop the top view controller.
 */
@property (strong, nonatomic, readonly) UISwipeGestureRecognizer *popGestureRecognizer;

/**
 * @abstract This property represents an empty view that has been created to replicate the visual characteristics
 * of the navigation bar of the currently selected view controller, should one be active.
 * Its primary function is to occupy the empty space between the navigation bar and the vertical tab bar,
 * providing a consistent and aesthetically pleasing user interface.
 */
@property (strong, nonatomic, readonly) TBDummyBar *dummyBar;

/**
 * @abstract The horizontal tab bar positioned at the bottom of the controller.
 * The tab bar is a key component for navigating and selecting view controllers within the controller.
 */
@property (strong, nonatomic, readonly) TBTabBar *horizontalTabBar;

/**
 * @abstract This property represents the vertical tab bar, which is positioned at the left side of the controller or on the right side,
 * depending on the language direction. It can also be manually configured to appear on the right side as needed.
 * The tab bar is a key component for navigating and selecting view controllers within the controller.
 */
@property (strong, nonatomic, readonly) TBTabBar *verticalTabBar;

/**
 * @abstract The currently visible tab bar, if one is currently displayed.
 * @discussion This property may return a nil value (please see the note below).
 * To access both the visible and hidden tab bars, consider using the `currentlyVisibleTabBar:hiddenTabBar:` method.
 * @note Prior to iOS 13, this property is nil when the trait collection is not initialized yet. 
 * It can also be nil when there is no visible tab bar or when the controller is in the process of updating the tab bar placement.
 */
@property (weak, nonatomic, readonly, nullable) TBTabBar *visibleTabBar;

/**
 * @abstract The index of the currently selected view controller.
 */
@property (assign, nonatomic) NSUInteger selectedIndex;

/**
 * @abstract Specifies the index of the tab to be presented as the initial selection. The default value is 0.
 * You can modify this property to determine the initial presentation of your tab bar.
 */
@property (assign, nonatomic) NSUInteger startingIndex;

/**
 * @abstract This property specifies the height of the horizontal tab bar located at the bottom of the controller.
 * The default height is set to 49 points, but you can adjust this value to customize the appearance of the horizontal tab bar 
 * to better suit your design and layout preferences.
 */
@property (assign, nonatomic) CGFloat horizontalTabBarHeight;

/**
 * @abstract This property defines the width of the vertical tab bar. By default, it is set to 60 points. You can modify this value 
 * to adjust the width of the vertical tab bar according to your application's visual design and layout requirements.
 */
@property (assign, nonatomic) CGFloat verticalTabBarWidth;

@property (assign, nonatomic) CGFloat dummyBarHeight NS_UNAVAILABLE;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/**
 * @abstract Informs the tab bar controller that the visible tab bar is about to be added to a view hierarchy for the first time.
 * @note Do not call this method directly. This method should be called within the context of a superclass when overridden.
 */
- (void)willPresentTabBar NS_REQUIRES_SUPER;

/**
 * @abstract Informs the tab bar controller that the tab bar has been added to a view hierarchy for the first time.
 * @note Do not call this method directly. This method should be called within the context of a superclass when overridden.
 */
- (void)didPresentTabBar NS_REQUIRES_SUPER;

/**
 * @abstract A method that takes into account the current tab bar placement (or the preferred placement, depending on the context) 
 * and provides references to both the visible tab bar and the hidden tab bar, if available.
 * @discussion If neither the visible nor the hidden tab bar is available, it indicates that both tab bars are hidden. 
 * In this case, you should call the `_specifyPreferredTabBarPlacementForHorizontalSizeClass:size:` method
 * to specify the preferred tab bar placement. Afterward, you can call this method again to retrieve the hidden tab bar.
 *
 * @code
    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];

    if (visibleTabBar != nil) {
        // Perform actions with the visible tab bar
    } else if (hiddenTabBar != nil) {
        // Perform actions with the hidden tab bar
    } else {
        // Both tab bars are hidden - you should manually specify their visibility
    }
 */
- (void)currentlyVisibleTabBar:(TBTabBar *_Nullable *_Nullable)visibleTabBar
                  hiddenTabBar:(TBTabBar *_Nullable *_Nullable)hiddenTabBar;

/**
 * @abstract Initiates the tab bar placement update if necessary. Animatable.
 * @discussion If you need to make changes to the tab bar placement, such as hiding it or changing its side, you should create 
 * a new subclass of the `TBTabBarController` class. Then, you can override one of the methods within
 * the `Subclassing` category to implement your custom logic. Alternatively, you can set a custom value
 * for the `_preferredPlacement` instance variable before calling this method, but this approach is not recommended.
 * @note It's important to always call the `endTabBarTransition` method after invoking this one.
 * @code
    [UIView animateWithDuration:0.3 animations:^{
        [self beginTabBarTransition];
    } completion:^(BOOL finished) {
        [self endTabBarTransition];
    }];
 */
- (void)beginTabBarTransition;

/**
 * @abstract Concludes the tab bar position update.
 * @note Unbalanced calls may result in unexpected behavior.
 * @see Refer to the description of the `beginTabBarTransition` method for context.
 */
- (void)endTabBarTransition;

/**
 * @abstract Appends an item to the end of the items list and generates a button that will be included in the tab bar during 
 * the next view layout cycle update. Animatable.
 * @discussion There are situations where you may want to add a non-functional button to the middle of the tab bar (for example),
 * without triggering any default actions. You can utilize the delegate methods to observe button actions and prevent unnecessary selections.
 * @param item The TBTabBarItem object to be added to the tab bar.
 */
- (void)addItem:(__kindof TBTabBarItem *)item;

/**
 * @abstract Inserts an item into the items list at a specified index. Animatable.
 * @discussion Refer to the description of the `addItem:` method for context.
 * @param item The TBTabBarItem object to insert into the tab bar.
 * @param index The index at which to insert the item in the tab bar's item list.
 */
- (void)insertItem:(__kindof TBTabBarItem *)item atIndex:(NSUInteger)index;

/**
 * @abstract Removes an item from the items list at the specified index. Animatable.
 * @note Additionally, it removes a view controller at the given index, if one is associated, 
 * and then selects the next available view controller if applicable.
 * @param index The index at which to remove the item from the tab bar's item list.
 */
- (void)removeItemAtIndex:(NSUInteger)index NS_SWIFT_NAME(removeItem(at:));

@end

#pragma mark - Subclassing

/**
 * @abstract This category contains methods for customizing and controlling the positioning and appearance of the tab bar.
 * @warning Please note that it's essential not to override both `preferredTabBarPlacementForHorizontalSizeClass:`
 * and `preferredTabBarPlacementForViewSize:` simultaneously.
 * You should choose one of these methods based on your specific requirements.
 */
@interface TBTabBarController (Subclassing)

/**
 * @discussion Invoked when the view is transitioning to a new horizontal size class.
 * @param sizeClass The new horizontal size class.
 * @return The preferred tab bar placement for the specified view size.
 */
- (TBTabBarControllerTabBarPlacement)preferredTabBarPlacementForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass;

/**
 * @discussion Invoked when the view is transitioning to a new size. 
 * You can call super to retrieve the preferred placement for the given size.
 * By default, this method relies on the horizontal size class rather than the view size.
 * @param size The new view size.
 * @return The preferred tab bar placement for the specified view size.
 */
- (TBTabBarControllerTabBarPlacement)preferredTabBarPlacementForViewSize:(CGSize)size;

/**
 * @abstract The class used for the horizontal tab bar. The default value is the TBTabBar class.
 * @note This class must be a subclass of TBTabBar.
 * @return The class to be used for the horizontal tab bar.
 */
+ (Class)horizontalTabBarClass;

/**
 * @abstract The class used for the vertical tab bar. The default value is the TBTabBar class.
 * @note This class must be a subclass of TBTabBar.
 * @return The class to be used for the vertical tab bar.
 */
+ (Class)verticalTabBarClass;

@end

#pragma mark -  View controller extension

/**
 * @abstract A category for extending UIViewController with TBTabBarController-specific properties and behavior.
 * These properties have names similar to their counterparts in the base UIViewController class but are prefixed with 'tb_' to avoid conflicts.
 */
@interface UIViewController (TBTabBarControllerExtension)

/**
 * @abstract The tab bar item associated with this view controller, allowing customization of its appearance in the tab bar.
 */
@property (strong, nonatomic, null_resettable, setter = tb_setTabBarItem:) TBTabBarItem *tb_tabBarItem;

/**
 * @abstract The TBTabBarController to which this view controller belongs.
 */
@property (assign, nonatomic, readonly, nullable) TBTabBarController *tb_tabBarController;

/**
 * @abstract A flag indicating whether the tab bar should be hidden when this view controller is pushed onto the navigation stack.
 * @warning The implementation of this property may involve unconventional techniques, including method swizzling, to achieve the desired behavior.
 */
@property (assign, nonatomic, setter = tb_setHidesTabBarWhenPushed:) BOOL tb_hidesTabBarWhenPushed;

@end

#pragma mark - Navigation controller delegate

@protocol TBNavigationControllerExtensionDelegate <NSObject>

@required

- (void)tb_navigationController:(UINavigationController *)navigationController
   navigationBarDidChangeHeight:(CGFloat)height;

- (void)tb_navigationController:(UINavigationController *)navigationController
         didBeginTransitionFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                      backwards:(BOOL)backwards;

- (void)tb_navigationController:(UINavigationController *)navigationController
       didUpdateInteractiveFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                percentComplete:(CGFloat)percentComplete;

- (void)tb_navigationController:(UINavigationController *)navigationController
          willEndTransitionFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                      cancelled:(BOOL)cancelled;

- (void)tb_navigationController:(UINavigationController *)navigationController
           didEndTransitionFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                      cancelled:(BOOL)cancelled;

@end

#pragma mark - Navigation controller extension

@interface UINavigationController (TBTabBarControllerExtension)

@property (weak, nonatomic, readonly, nullable) id<TBNavigationControllerExtensionDelegate> tb_delegate;

@end

#pragma mark - Navigation controller default delegate

@interface TBTabBarController (TBNavigationControllerExtensionDefaultDelegate) <TBNavigationControllerExtensionDelegate>

@end

NS_ASSUME_NONNULL_END
