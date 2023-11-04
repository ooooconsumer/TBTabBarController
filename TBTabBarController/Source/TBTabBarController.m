//
//  TBTabBarController.m
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

#import "TBTabBarController.h"

#import "TBTabBar.h"
#import "TBTabBarItem.h"
#import "TBDummyBar.h"
#import "TBTabBarController+Private.h"
#import "TBTabBar+Private.h"
#import "TBTabBarButton.h"
#import "_TBUtils.h"
#import "UIView+Extensions.h"
#import "_TBTabBarControllerTransitionContext.h"
#import "_TBTabBarControllerTransitionState.h"
#import "_TBTabBarControllerTransitionAnimator.h"
#import "NSArray+Extensions.h"

#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, _TBTabBarControllerMethodOverrides) {
    _TBTabBarControllerMethodOverrideNone = 0,
    _TBTabBarControllerMethodOverridePreferredTabBarPlacementForHorizontalSizeClass = 1 << 0,
    _TBTabBarControllerMethodOverridePreferredTabBarPlacementForViewSize = 1 << 1
};

static void *tbtbbrcntrlr_tabBarItemTitleContext = &tbtbbrcntrlr_tabBarItemTitleContext;
static void *tbtbbrcntrlr_tabBarItemImageContext = &tbtbbrcntrlr_tabBarItemImageContext;
static void *tbtbbrcntrlr_tabBarItemSelectedImageContext = &tbtbbrcntrlr_tabBarItemSelectedImageContext;
static void *tbtbbrcntrlr_tabBarItemNotificationIndicatorContext = &tbtbbrcntrlr_tabBarItemNotificationIndicatorContext;
static void *tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext = &tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext;
static void *tbtbbrcntrlr_tabBarItemEnabledContext = &tbtbbrcntrlr_tabBarItemEnabledContext;

#pragma mark - Tab bar controller

@interface TBTabBarController ()

@property (strong, nonatomic, readwrite) TBTabBar *verticalTabBar;
@property (strong, nonatomic, readwrite) TBTabBar *horizontalTabBar;
@property (weak, nonatomic, readwrite) TBTabBar *visibleTabBar;

@property (strong, nonatomic) UIView *containerView;

@end

static _TBTabBarControllerMethodOverrides tbtbbrcntrlr_methodOverridesFlag;

@implementation TBTabBarController {

    __weak UINavigationController *tbtbbrcntrlr_nestedNavigationController;
    _TBTabBarControllerTransitionState *tbtbbrcntrlr_transitionState;

    CGFloat tbtbbrcntrlr_dummyBarInternalHeight;

    BOOL tbtbbrcntrlr_needsLayout;
    BOOL tbtbbrcntrlr_needsUpdateTabBarPlacement;
    BOOL tbtbbrcntrlr_selectedViewControllerNeedsLayout;
    BOOL tbtbbrcntrlr_isTransitioning;
}

@synthesize dummyBar = _dummyBar;
@synthesize popGestureRecognizer = _popGestureRecognizer;

#pragma mark - Public

#pragma mark Lifecycle

+ (void)initialize {

    [super initialize];

    if (self != [TBTabBarController class]) {
        if (_TBSubclassOverridesMethod([TBTabBarController class], self, @selector(preferredTabBarPlacementForHorizontalSizeClass:))) {
            tbtbbrcntrlr_methodOverridesFlag |= _TBTabBarControllerMethodOverridePreferredTabBarPlacementForHorizontalSizeClass;
        }
        if (_TBSubclassOverridesMethod([TBTabBarController class], self, @selector(preferredTabBarPlacementForViewSize:))) {
            tbtbbrcntrlr_methodOverridesFlag |= _TBTabBarControllerMethodOverridePreferredTabBarPlacementForViewSize;
        }
        NSAssert(tbtbbrcntrlr_methodOverridesFlag <= _TBTabBarControllerMethodOverridePreferredTabBarPlacementForViewSize,
                 @"Subclasses should never override both of the methods of the Subclassing category");
    }
}

- (instancetype)init {

    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        [self tbtbbrcntrlr_commonInit];
    }

    return self;
}

+ (instancetype)new {

    return [[TBTabBarController alloc] init];
}

- (void)dealloc {

    [self tbtbbrcntrlr_removeItemObservers];
}

#pragma mark Public Methods

- (void)willPresentTabBar {

    [self _specifyPreferredTabBarPlacementForHorizontalSizeClass:self.traitCollection.horizontalSizeClass
                                                           size:self.view.bounds.size];

    _currentPlacement = _preferredPlacement;
}

- (void)didPresentTabBar {

    _didPresentTabBarOnce = true;

    self.selectedIndex = self.startingIndex;
}

- (void)currentlyVisibleTabBar:(TBTabBar **)visibleTabBar hiddenTabBar:(TBTabBar **)hiddenTabBar {

    switch (_currentPlacement) {
        case TBTabBarControllerTabBarPlacementHidden:
            if (_preferredPlacement > TBTabBarControllerTabBarPlacementHidden) {
                switch (_preferredPlacement) {
                    case TBTabBarControllerTabBarPlacementLeading:
                    case TBTabBarControllerTabBarPlacementTrailing:
                        if (hiddenTabBar != nil) {
                            *hiddenTabBar = self.verticalTabBar;
                        }
                        break;

                    case TBTabBarControllerTabBarPlacementBottom:
                        if (hiddenTabBar != nil) {
                            *hiddenTabBar = self.horizontalTabBar;
                        }
                        break;

                    default:
                        break;
                }
            }
            break;

        case TBTabBarControllerTabBarPlacementLeading:
        case TBTabBarControllerTabBarPlacementTrailing:
            if (visibleTabBar != nil) {
                *visibleTabBar = self.verticalTabBar;
            }
            if (hiddenTabBar != nil) {
                *hiddenTabBar = self.horizontalTabBar;
            }
            break;

        case TBTabBarControllerTabBarPlacementBottom:
            if (visibleTabBar != nil) {
                *visibleTabBar = self.horizontalTabBar;
            }
            if (hiddenTabBar != nil) {
                *hiddenTabBar = self.verticalTabBar;
            }
            break;
        default:
            break;
    }
}

- (void)beginTabBarTransition {

    tbtbbrcntrlr_selectedViewControllerNeedsLayout = true;

    [self tbtbbrcntrlr_beginTabBarTransition];
}

- (void)endTabBarTransition {

    tbtbbrcntrlr_selectedViewControllerNeedsLayout = false;

    [self tbtbbrcntrlr_endTabBarTransition];
}

- (void)addItem:(__kindof TBTabBarItem *)item {

    [self tbtbbrcntrlr_observeItem:item];

    [_items addObject:item];

    [self.horizontalTabBar _setItems:_items];
    [self.verticalTabBar _setItems:_items];
}

- (void)insertItem:(__kindof TBTabBarItem *)item atIndex:(NSUInteger)index {

    [self tbtbbrcntrlr_observeItem:item];

    [_items insertObject:item atIndex:index];

    [self.horizontalTabBar _setItems:_items];
    [self.verticalTabBar _setItems:_items];
}

- (void)removeItemAtIndex:(NSUInteger)index {

    TBTabBarItem *item = _items[index];

    [self tbtbbrcntrlr_removeObserverForItem:item];

    [_items removeObjectAtIndex:index];

    [self.horizontalTabBar _setItems:_items];
    [self.verticalTabBar _setItems:_items];

    UIViewController *viewControllerToRemove = [self.viewControllers firstObject:^BOOL(__kindof UIViewController *_Nonnull viewController) {
        return [viewController.tb_tabBarItem isEqualToItem:item];
    }];

    if (viewControllerToRemove == nil) {
        return;
    }

    NSMutableArray<UIViewController *> *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeObject:viewControllerToRemove];

    self.viewControllers = viewControllers;

    if (viewControllers.count == 0) {
        return;
    }

    UIViewController *viewControllerToSelect;

    if (_delegateFlags.shouldSelectItemAtIndex) {
        for (UIViewController *viewController in viewControllers) {
            if ([self.delegate tabBarController:self shouldSelectViewController:viewController]) {
                viewControllerToSelect = viewController;
                break;
            }
        }
    } else {
        viewControllerToSelect = viewControllers.firstObject;
    }

    if (viewControllerToSelect == nil) {
        return;
    }

    NSUInteger const viewControllerIndexToSelect = [viewControllers indexOfObject:viewControllerToSelect];

    [self tbtbbrcntrlr_moveToViewControllerAtIndex:viewControllerIndexToSelect];

    NSUInteger const hTabBarItemIndexToSelect = [self.horizontalTabBar.visibleItems indexOfObject:viewControllerToSelect.tb_tabBarItem];

    [self.horizontalTabBar _setSelectedIndex:hTabBarItemIndexToSelect quietly:true];

    NSUInteger const vTabBarItemIndexToSelect = [self.verticalTabBar.visibleItems indexOfObject:viewControllerToSelect.tb_tabBarItem];

    [self.verticalTabBar _setSelectedIndex:vTabBarItemIndexToSelect quietly:true];

    if (_delegateFlags.didSelectViewController) {
        [self.delegate tabBarController:self didSelectViewController:viewControllerToSelect];
    }
}

#pragma mark Overrides

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {

    return [self _visibleViewController].preferredStatusBarUpdateAnimation;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self tbtbbrcntrlr_setup];
}

- (void)viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];

    if (@available(iOS 13.0, *)) {
        if (!_didPresentTabBarOnce) {
            [self tbtbbrcntrlr_presentTabBar];
        }
    }

    [self tbtbbrcntrlr_layoutBars];
}

#pragma mark UIContainerViewControllerProtectedMethods

- (UIViewController *)childViewControllerForStatusBarStyle {

    return [self _visibleViewController];
}

- (UIViewController *)childViewControllerForStatusBarHidden {

    return [self _visibleViewController];
}

#pragma mark UIViewControllerRotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    return [self _visibleViewController].supportedInterfaceOrientations;
}

#pragma mark UIHomeIndicatorAutoHidden

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {

    return [self _visibleViewController];
}

#pragma mark UIContentContainer

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {

    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    UIUserInterfaceSizeClass const newHorizontalSizeClass = newCollection.horizontalSizeClass;

    if (self.traitCollection.horizontalSizeClass != newHorizontalSizeClass) {
        
        _preferredPlacement = [self tbtbbrcntrlr_preferredTabBarPlacementForSizeClass:newHorizontalSizeClass];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {

    if (CGSizeEqualToSize(self.view.bounds.size, size) == false) {
        
        __weak typeof(self) weakSelf = self;

        UIUserInterfaceSizeClass const sizeClass = self.traitCollection.horizontalSizeClass;
        
        [self _specifyPreferredTabBarPlacementForHorizontalSizeClass:sizeClass size:size];
        
        // Adjust the vertical tab bar height to make it look good during the transition
        [self tbtbbrcntrlr_adjustVerticalTabBarHeightIfNeeded];

        [self tbtbbrcntrlr_ensureVerticalTabBarPlacedAtRightLocationBeforeTransition];
        
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            [weakSelf beginTabBarTransition];
        } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
            [weakSelf endTabBarTransition];
        }];
    }

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark UITraitEnvironment

#if FAlse
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

    if (@available(iOS 13.0, *)) { } else {
        if (_didPresentTabBarOnce == false) {
            [self tbtbbrcntrlr_presentTabBar];
        }
    }

    [super traitCollectionDidChange:previousTraitCollection];
}
#endif

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary <NSKeyValueChangeKey, id> *)change
                       context:(void *)context {

    TBTabBar *horizontalTabBar = self.horizontalTabBar;
    TBTabBar *verticalTabBar = self.verticalTabBar; 

    [self currentlyVisibleTabBar:&horizontalTabBar hiddenTabBar:&verticalTabBar];

    NSUInteger const verticalTabBarButtonIndex = [horizontalTabBar.items indexOfObject:object];
    NSUInteger const hiddenTabBarButtonIndex = [verticalTabBar.items indexOfObject:object];

    id newValue = change[NSKeyValueChangeNewKey];

    if (tbtbbrcntrlr_tabBarItemImageContext == context && [keyPath isEqualToString:NSStringFromSelector(@selector(image))]) {
        [horizontalTabBar _setNormalImage:newValue forButtonAtIndex:verticalTabBarButtonIndex];
        [verticalTabBar _setNormalImage:newValue forButtonAtIndex:hiddenTabBarButtonIndex];
        return;
    } else if (tbtbbrcntrlr_tabBarItemSelectedImageContext == context && [keyPath isEqualToString:NSStringFromSelector(@selector(selectedImage))]) {
        [horizontalTabBar _setSelectedImage:newValue forButtonAtIndex:verticalTabBarButtonIndex];
        [verticalTabBar _setSelectedImage:newValue forButtonAtIndex:hiddenTabBarButtonIndex];
        return;
    } else if (tbtbbrcntrlr_tabBarItemNotificationIndicatorContext == context && [keyPath isEqualToString:NSStringFromSelector(@selector(notificationIndicator))]) {
        [horizontalTabBar _setNotificationIndicatorImage:newValue forButtonAtIndex:verticalTabBarButtonIndex];
        [verticalTabBar _setNotificationIndicatorImage:newValue forButtonAtIndex:hiddenTabBarButtonIndex];
        return;
    } else if (tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext == context && [keyPath isEqualToString:NSStringFromSelector(@selector(showsNotificationIndicator))]) {
        BOOL const isNotificationIndicatorHidden = ![(NSNumber *)newValue boolValue];
        [horizontalTabBar _setNotificationIndicatorHidden:isNotificationIndicatorHidden forButtonAtIndex:verticalTabBarButtonIndex];
        [verticalTabBar _setNotificationIndicatorHidden:isNotificationIndicatorHidden forButtonAtIndex:hiddenTabBarButtonIndex];
        return;
    } else if (tbtbbrcntrlr_tabBarItemEnabledContext == context && [keyPath isEqual:NSStringFromSelector(@selector(isEnabled))]) {
        BOOL const isButtonEnabled = [(NSNumber *)newValue boolValue];
        [horizontalTabBar _setButtonEnabled:isButtonEnabled atIndex:verticalTabBarButtonIndex];
        [verticalTabBar _setButtonEnabled:isButtonEnabled atIndex:hiddenTabBarButtonIndex];
        return;
    }

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark TBTabBarDelegate

- (BOOL)tabBar:(TBTabBar *)tabBar shouldSelectItem:(TBTabBarItem *)item atIndex:(NSUInteger)index {

    BOOL shouldSelect = true;

    if (_delegateFlags.shouldSelectItemAtIndex) {
        shouldSelect = [self.delegate tabBarController:self shouldSelectItem:item atIndex:index];
    }

    if (shouldSelect && _delegateFlags.shouldSelectViewController) {
        NSUInteger const viewControllerIndex = [self.viewControllers indexOfObjectPassingTest:^BOOL(__kindof UIViewController *_Nonnull viewController, NSUInteger index, BOOL * _Nonnull stop) {
            if ([viewController.tb_tabBarItem isEqual:item]) {
                *stop = true;
                return true;
            }
            return false;
        }];
        UIViewController *viewController = viewControllerIndex != NSNotFound ? self.viewControllers[viewControllerIndex] : nil;
        _shouldSelectViewController = [self.delegate tabBarController:self shouldSelectViewController:viewController];
    }

    return shouldSelect;
}

- (void)tabBar:(TBTabBar *)tabBar didSelectItem:(TBTabBarItem *)item atIndex:(NSUInteger)index {

    if (_delegateFlags.didSelectItemAtIndex) {
        [self.delegate tabBarController:self didSelectItem:item atIndex:index];
    }

    BOOL const shouldSelectViewController = _shouldSelectViewController;

    _shouldSelectViewController = true;

    if (!shouldSelectViewController) {
        return;
    }

    TBTabBar *otherTabBar = tabBar.isVertical ? self.horizontalTabBar : self.verticalTabBar;

    if (_delegateFlags.shouldSelectViewController && ![self.delegate tabBarController:self shouldSelectViewController:self.viewControllers[index]]) {
        return;
    }

    [self tbtbbrcntrlr_moveToViewControllerAtIndex:index];

    [tabBar _setSelectedIndex:index quietly:true];

    if (otherTabBar.items.count > 0) {

        NSUInteger const visibleItemIndexToSelect = [otherTabBar.visibleItems indexOfObject:item];

        if (visibleItemIndexToSelect != NSNotFound) {
            [otherTabBar _setSelectedIndex:visibleItemIndexToSelect quietly:true];
        } else {
            [otherTabBar _deselect];
        }
    }

    if (_delegateFlags.didSelectViewController) {
        [self.delegate tabBarController:self didSelectViewController:_selectedViewController];
    }
}

#pragma mark Private Methods

#pragma mark Setup

- (void)tbtbbrcntrlr_commonInit {

    _shouldSelectViewController = true;
    _startingIndex = 0;
    _horizontalTabBarHeight = 49.0;
    _verticalTabBarWidth = 60.0;
}

- (void)tbtbbrcntrlr_setup {
    // View
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    // Container
    [self.view addSubview:self.containerView];
    // Horizontal tab bar
    [self.view addSubview:self.horizontalTabBar];
    // Verical tab bar
    [self.view addSubview:self.verticalTabBar];
    // Dummy bar
    [self.view addSubview:self.dummyBar];
    // Gestures
    [self.verticalTabBar addGestureRecognizer:self.popGestureRecognizer];
}

#pragma mark Tab bar visibility

- (void)tbtbbrcntrlr_beginTabBarTransition {

    tbtbbrcntrlr_isTransitioning = true;

    if (_preferredPlacement == _currentPlacement ||
        _preferredPlacement == TBTabBarControllerTabBarPlacementUndefined) {
        [self _specifyPreferredTabBarPlacementForHorizontalSizeClass:self.traitCollection.horizontalSizeClass
                                                                size:self.view.bounds.size];
    }

    tbtbbrcntrlr_needsUpdateTabBarPlacement = true;

    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];

    [visibleTabBar _prepareForTransitionToPlacement:_preferredPlacement];
    [hiddenTabBar _prepareForTransitionToPlacement:_preferredPlacement];

    self.dummyBar.separatorPosition = self.verticalTabBar.separatorPosition;

    if (_preferredPlacement != TBTabBarControllerTabBarPlacementHidden) {
        if (tbtbbrcntrlr_nestedNavigationController != nil) {
            // When there is no transition between the view controllers we can user the currently
            // visible view controller to look up whether we should hide the tab bar or not.
            BOOL const shouldHideTabBar = tbtbbrcntrlr_transitionState != nil ?
                _visibleViewControllerWantsHideTabBar :
                [self _visibleViewController].tb_hidesTabBarWhenPushed;
            if (shouldHideTabBar) {
                _preferredPlacement = TBTabBarControllerTabBarPlacementHidden;
                _visibleViewControllerWantsHideTabBar = true;
            } else {
                _visibleViewControllerWantsHideTabBar = false;
            }
        }
    }

    if (_preferredPlacement != _currentPlacement) {
        id<TBTabBarControllerDelegate> delegate = self.delegate;
        switch (_preferredPlacement) {
            case TBTabBarControllerTabBarPlacementHidden:
                if (visibleTabBar != nil && _delegateFlags.willHideTabBar) {
                    [delegate tabBarController:self willHideTabBar:visibleTabBar];
                }
                hiddenTabBar = nil; // This bar won't go visible anyway
                break;

            case TBTabBarControllerTabBarPlacementLeading:
            case TBTabBarControllerTabBarPlacementTrailing:
            case TBTabBarControllerTabBarPlacementBottom:
                if (hiddenTabBar != nil && _delegateFlags.willShowTabBar) {
                    [delegate tabBarController:self willShowTabBar:hiddenTabBar];
                }
                if (visibleTabBar != nil && _delegateFlags.willHideTabBar) {
                    [delegate tabBarController:self willHideTabBar:visibleTabBar];
                }
                break;

            default:
                break;
        }
    }

    [self tbtbbrcntrlr_showTabBarIfNeeded:hiddenTabBar tabBarToHide:visibleTabBar];
    [self tbtbbrcntrlr_updateAdditionalSafeAreaInsets:tbtbbrcntrlr_selectedViewControllerNeedsLayout];

    tbtbbrcntrlr_needsLayout = true;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)tbtbbrcntrlr_endTabBarTransition {

    if (!tbtbbrcntrlr_needsUpdateTabBarPlacement) {
        _preferredPlacement = TBTabBarControllerTabBarPlacementUndefined;
        tbtbbrcntrlr_isTransitioning = false;
        return;
    }

    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];

    if (_preferredPlacement != _currentPlacement) {
        id<TBTabBarControllerDelegate> delegate = self.delegate;
        switch (_preferredPlacement) {
            case TBTabBarControllerTabBarPlacementHidden:
                if (visibleTabBar != nil && _delegateFlags.didHideTabBar) {
                    [delegate tabBarController:self didHideTabBar:visibleTabBar];
                }
                break;

            case TBTabBarControllerTabBarPlacementLeading:
            case TBTabBarControllerTabBarPlacementTrailing:
            case TBTabBarControllerTabBarPlacementBottom:
                if (hiddenTabBar != nil && _delegateFlags.didShowTabBar) {
                    [delegate tabBarController:self didShowTabBar:hiddenTabBar];
                }
                if (visibleTabBar != nil && _delegateFlags.didHideTabBar) {
                    [delegate tabBarController:self didHideTabBar:visibleTabBar];
                }
                break;

            default:
                break;
        }
    }

    [self tbtbbrcntrlr_hideTabBarIfNeeded:visibleTabBar tabBarToShow:hiddenTabBar];

    tbtbbrcntrlr_needsLayout = true;
    tbtbbrcntrlr_needsUpdateTabBarPlacement = false;
    tbtbbrcntrlr_isTransitioning = false;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    _preferredPlacement = TBTabBarControllerTabBarPlacementUndefined;
}


- (void)tbtbbrcntrlr_updateAdditionalSafeAreaInsets:(BOOL)shouldLayoutManually {

    UIViewController *selectedViewController = self.selectedViewController;
    UIEdgeInsets additionalSafeAreaInsets = UIEdgeInsetsZero;

    switch (_preferredPlacement) {
        case TBTabBarControllerTabBarPlacementLeading:
            additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0);
            break;

        case TBTabBarControllerTabBarPlacementTrailing:
            additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.verticalTabBarWidth);
            break;

        case TBTabBarControllerTabBarPlacementBottom:
            additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0);
            break;

        default:
            break;
    }

    selectedViewController.additionalSafeAreaInsets = additionalSafeAreaInsets;

    if (shouldLayoutManually) {
        [selectedViewController.view setNeedsLayout];
        [selectedViewController.view layoutIfNeeded];
    }
}

- (void)tbtbbrcntrlr_showTabBarIfNeeded:(nullable TBTabBar *)tabBarToShow
                           tabBarToHide:(nullable TBTabBar *)tabBarToHide {

    if (_preferredPlacement == _currentPlacement) {
        return;
    }

    if (tbtbbrcntrlr_isTransitioning) {
        // Adjust content insets only if the device is transitioning to the ...
        if (tabBarToShow != nil) {
            if (tabBarToShow.isVertical && tabBarToHide != nil) {
                CGFloat const bottomInset = self.horizontalTabBarHeight + self.view.safeAreaInsets.bottom;
                [tabBarToShow _setAdditionalContentInsets:UIEdgeInsetsMake(0.0,
                                                                           0.0,
                                                                           bottomInset,
                                                                           0.0)];
            } else {
                [tabBarToShow _setAdditionalContentInsets:UIEdgeInsetsZero];
            }
        }
        if (tabBarToHide != nil && tabBarToShow != nil && !tabBarToHide.isVertical) {
            [tabBarToHide _setAdditionalContentInsets:UIEdgeInsetsMake(0.0,
                                                                       self.verticalTabBarWidth,
                                                                       0.0,
                                                                       0.0)];
        }
    }

    if (_preferredPlacement != TBTabBarControllerTabBarPlacementHidden && tabBarToShow != nil) {
        [self tbtbbrcntrlr_showTabBar:tabBarToShow];
    }
}

- (void)tbtbbrcntrlr_hideTabBarIfNeeded:(nullable TBTabBar *)tabBarToHide
                           tabBarToShow:(nullable TBTabBar *)tabBarToShow {

    if (_preferredPlacement == _currentPlacement) {
        return;
    }

    if (tbtbbrcntrlr_isTransitioning) {
        if (tabBarToShow != nil && tabBarToShow.isVertical) {
            [tabBarToShow _setAdditionalContentInsets:UIEdgeInsetsZero];
        }
    }

    if (_currentPlacement != TBTabBarControllerTabBarPlacementHidden) {
        [self tbtbbrcntrlr_hideTabBar:tabBarToHide];
    }

    _currentPlacement = _preferredPlacement;
}

- (void)tbtbbrcntrlr_presentTabBar {

    tbtbbrcntrlr_needsLayout = true;

    [self willPresentTabBar];

    [self tbtbbrcntrlr_ensureVerticalTabBarPlacedAtRightLocationBeforeTransition];

    if (_currentPlacement != TBTabBarControllerTabBarPlacementHidden) {
        TBTabBar *visibleTabBar, *hiddenTabBar;
        [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];
        [self tbtbbrcntrlr_showTabBar:visibleTabBar];
        [hiddenTabBar _setVisible:false];
    } else {
        [self.horizontalTabBar _setVisible:false];
        [self.verticalTabBar _setVisible:false];
    }

    [self didPresentTabBar];
}

- (void)tbtbbrcntrlr_showTabBar:(TBTabBar *)tabBar {

    if (tabBar.isVertical) {
        TBTabBar *horizontalTabBar = self.horizontalTabBar;
        if (horizontalTabBar.superview != nil) {
            [self.view insertSubview:tabBar aboveSubview:horizontalTabBar];
            [self.view insertSubview:self.dummyBar aboveSubview:tabBar];
        } else {
            [self.view addSubview:tabBar];
            [self.view addSubview:self.dummyBar];
        }
    } else {
        TBTabBar *verticalTabBar = self.verticalTabBar;
        if (verticalTabBar.superview != nil) {
            [self.view insertSubview:tabBar belowSubview:verticalTabBar];
        } else {
            [self.view addSubview:tabBar];
        }
    }

    [tabBar _setVisible:true];

    self.visibleTabBar = tabBar;
}

- (void)tbtbbrcntrlr_hideTabBar:(TBTabBar *)tabBar {

    if (tabBar.isVertical) {
        [self.dummyBar removeFromSuperview];
    }

    [tabBar removeFromSuperview];

    [tabBar _setVisible:false];

    if ([self.visibleTabBar isEqual:tabBar]) {
        self.visibleTabBar = nil;
    }
}

#pragma mark Layout

- (void)tbtbbrcntrlr_layoutBars {

    if (!tbtbbrcntrlr_needsLayout) {
        return;
    }

    tbtbbrcntrlr_needsLayout = false;

    if (_preferredPlacement != TBTabBarControllerTabBarPlacementUndefined) {

        TBTabBar *hTabBar = self.horizontalTabBar;
        TBTabBar *vTabBar = self.verticalTabBar;

        switch (_preferredPlacement) {
            case TBTabBarControllerTabBarPlacementHidden:
                [self tbtbbrcntrlr_layoutBarsHBarHidden:true vBarHidden:true];
                break;

            case TBTabBarControllerTabBarPlacementLeading:
            case TBTabBarControllerTabBarPlacementTrailing:
                switch (_currentPlacement) {
                    case TBTabBarControllerTabBarPlacementHidden:
                        [self tbtbbrcntrlr_layoutBarsHBarHidden:true vBarHidden:false];
                        break;

                    case TBTabBarControllerTabBarPlacementLeading:
                    case TBTabBarControllerTabBarPlacementTrailing:
                        [self tbtbbrcntrlr_layoutBarsHBarHidden:true vBarHidden:false];
                        break;

                    case TBTabBarControllerTabBarPlacementBottom:

                        [self tbtbbrcntrlr_layoutBarsHBarHidden:true vBarHidden:false];

                        if (tbtbbrcntrlr_isTransitioning) {
                            CGRect vTabBarFrame = vTabBar.frame;
                            vTabBarFrame.size.height += hTabBar.frame.size.height;
                            vTabBar.frame = vTabBarFrame;
                        }

                        break;

                    default:
                        break;
                }
                break;

            case TBTabBarControllerTabBarPlacementBottom:
                [self tbtbbrcntrlr_layoutBarsHBarHidden:false vBarHidden:true];

            default:
                break;
        }

    } else if (_currentPlacement != TBTabBarControllerTabBarPlacementUndefined) {

        switch (_currentPlacement) {
            case TBTabBarControllerTabBarPlacementHidden:
                [self tbtbbrcntrlr_layoutBarsHBarHidden:true vBarHidden:true];
                break;

            case TBTabBarControllerTabBarPlacementLeading:
            case TBTabBarControllerTabBarPlacementTrailing:
                [self tbtbbrcntrlr_layoutBarsHBarHidden:true vBarHidden:false];
                break;

            case TBTabBarControllerTabBarPlacementBottom:
                [self tbtbbrcntrlr_layoutBarsHBarHidden:false vBarHidden:true];
                break;

            default:
                break;
        }
    }
}

- (void)tbtbbrcntrlr_layoutBarsHBarHidden:(BOOL)hBarHidden vBarHidden:(BOOL)vBarHidden {

    CGRect const bounds = self.view.bounds;

    self.horizontalTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrame:bounds hidden:hBarHidden];
    self.verticalTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrame:bounds hidden:vBarHidden];
    self.dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrame:bounds hidden:vBarHidden];
}

- (CGRect)tbtbbrcntrlr_horizontalTabBarFrame:(CGRect)bounds hidden:(BOOL)hidden {

    CGFloat const width = CGRectGetWidth(bounds);
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const hTabBarHeight = self.horizontalTabBarHeight + self.view.safeAreaInsets.bottom;

    if (hidden) {
        return (CGRect){{0.0, height}, {width, hTabBarHeight}};
    } else {
        return (CGRect){{0.0, height - hTabBarHeight}, {width, hTabBarHeight}};
    }
}

- (CGRect)tbtbbrcntrlr_verticalTabBarFrame:(CGRect)bounds hidden:(BOOL)hidden {

    CGFloat const width = CGRectGetWidth(bounds);
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const vTabBarWidth = self.verticalTabBarWidth + self.view.safeAreaInsets.left;

    CGFloat xPosition = 0.0;

    switch (_preferredPlacement) {
        case TBTabBarControllerTabBarPlacementLeading:
            xPosition = hidden ? -vTabBarWidth : 0.0;
            break;

        case TBTabBarControllerTabBarPlacementTrailing:
            xPosition = hidden ? width : width - vTabBarWidth;
            break;

        default:
            switch (self.verticalTabBar.currentPlacement) {
                case TBTabBarControllerTabBarPlacementLeading:
                    xPosition = hidden ? -vTabBarWidth : 0.0;
                    break;

                case TBTabBarControllerTabBarPlacementTrailing:
                    xPosition = hidden ? width : width - vTabBarWidth;
                    break;

                default:
                    xPosition = hidden ? -vTabBarWidth : 0.0;
                    break;
            }
            break;
    }

    return (CGRect){
        {xPosition, tbtbbrcntrlr_dummyBarInternalHeight},
        {vTabBarWidth, height - tbtbbrcntrlr_dummyBarInternalHeight}
    };
}

- (CGRect)tbtbbrcntrlr_dummyBarFrame:(CGRect)bounds hidden:(BOOL)hidden {

    CGRect frame = [self tbtbbrcntrlr_verticalTabBarFrame:bounds hidden:hidden];
    frame.origin.y = 0.0;
    frame.size.height = tbtbbrcntrlr_dummyBarInternalHeight;

    return frame;
}

- (void)tbtbbrcntrlr_ensureVerticalTabBarPlacedAtRightLocationBeforeTransition {

    TBTabBar *tabBar = self.verticalTabBar;
    tabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrame:self.view.bounds hidden:!tabBar.isVisible];

    [tabBar _prepareForTransitionToPlacement:_preferredPlacement];
    [tabBar layoutIfNeeded];

    TBDummyBar *dummyBar = self.dummyBar;
    dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrame:self.view.bounds hidden:!tabBar.isVisible];
    dummyBar.separatorPosition = tabBar.separatorPosition;

    [dummyBar layoutIfNeeded];
}

- (void)tbtbbrcntrlr_adjustVerticalTabBarHeightIfNeeded {

    if (_preferredPlacement == TBTabBarControllerTabBarPlacementBottom &&
        (_currentPlacement == TBTabBarControllerTabBarPlacementLeading ||
         _currentPlacement == TBTabBarControllerTabBarPlacementTrailing)) {
        TBTabBar *verticalTabBar = self.verticalTabBar;
        CGRect frame = verticalTabBar.frame;
        frame.size.height = CGRectGetHeight(frame) + self.horizontalTabBar.frame.size.height;
        verticalTabBar.frame = frame;
    }
}

#pragma mark Transitions

- (void)tbtbbrcntrlr_moveToViewControllerAtIndex:(NSUInteger)index {

    NSArray<UIViewController *> *viewControllers = self.viewControllers;

    if (index == NSNotFound || viewControllers.count <= index || !self.isViewLoaded) {
        return;
    }

    __kindof UIViewController *sourceViewController = _selectedViewController;
    __kindof UIViewController *destinationViewController = viewControllers[index];

    if ([sourceViewController isEqual:destinationViewController]) {
        return;
    }

    _selectedViewController = destinationViewController;

    [self tbtbbrcntrlr_captureNestedNavigationControllerIfExists];

    [self tbtbbrcntrlr_cycleFromSourceViewController:sourceViewController
                         toDestinationViewController:destinationViewController
                                     completionBlock:nil];
}

- (void)tbtbbrcntrlr_clearHierarchy {

    __kindof UIViewController *sourceViewController = _selectedViewController;

    if (sourceViewController == nil || !self.isViewLoaded) {
        return;
    }

    __weak typeof(self) weakSelf = self;

    [self tbtbbrcntrlr_cycleFromSourceViewController:sourceViewController
                         toDestinationViewController:nil
                                     completionBlock:^{

                                        if (weakSelf == nil) {
                                            return;
                                        }

                                        typeof(self) strongSelf = weakSelf;

                                        strongSelf->_selectedViewController = nil;
                                        strongSelf->tbtbbrcntrlr_nestedNavigationController = nil;
                                    }];
}

- (void)tbtbbrcntrlr_cycleFromSourceViewController:(nullable UIViewController *)sourceViewController
                       toDestinationViewController:(nullable UIViewController *)destinationViewController
                                   completionBlock:(nullable void(^)(void))completionBlock {

    [sourceViewController willMoveToParentViewController:nil];

    if (destinationViewController != nil) {
        destinationViewController.view.frame = self.containerView.bounds;
        [self addChildViewController:destinationViewController];
    }

    __weak typeof(self) weakSelf = self;

    id<UIViewControllerAnimatedTransitioning> animator;

    if (_delegateFlags.animationControllerForTransition) {
        animator = [self.delegate tabBarController:self
animationControllerForTransitionFromViewController:sourceViewController
                                  toViewController:destinationViewController];
    } else {
        animator = [[_TBTabBarControllerTransitionAnimator alloc] init];
    }

    _TBTabBarControllerTransitionContext *transitionContext = [[_TBTabBarControllerTransitionContext alloc] initWithSourceViewController:sourceViewController destinationViewController:destinationViewController containerView:self.containerView];
    transitionContext.animated = true;
    transitionContext.interactive = false;
    transitionContext.completionBlock = ^(BOOL didComplete) {

        [sourceViewController.view removeFromSuperview];
        [sourceViewController removeFromParentViewController];
        [destinationViewController didMoveToParentViewController:weakSelf];

        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }

        if (completionBlock != nil) {
            completionBlock();
        }
    };

    [animator animateTransition:transitionContext];
}

#pragma mark KVO

- (void)tbtbbrcntrlr_observeItems {

    for (TBTabBarItem *item in _items) {
        [self tbtbbrcntrlr_observeItem:item];
    }
}

- (void)tbtbbrcntrlr_observeItem:(TBTabBarItem *)item {

    [item addObserver:self
           forKeyPath:NSStringFromSelector(@selector(title))
              options:NSKeyValueObservingOptionNew
              context:tbtbbrcntrlr_tabBarItemTitleContext];

    [item addObserver:self
           forKeyPath:NSStringFromSelector(@selector(image))
              options:NSKeyValueObservingOptionNew
              context:tbtbbrcntrlr_tabBarItemImageContext];

    [item addObserver:self
           forKeyPath:NSStringFromSelector(@selector(selectedImage))
              options:NSKeyValueObservingOptionNew
              context:tbtbbrcntrlr_tabBarItemSelectedImageContext];

    [item addObserver:self
           forKeyPath:NSStringFromSelector(@selector(notificationIndicator))
              options:NSKeyValueObservingOptionNew
              context:tbtbbrcntrlr_tabBarItemNotificationIndicatorContext];

    [item addObserver:self
           forKeyPath:NSStringFromSelector(@selector(showsNotificationIndicator))
              options:NSKeyValueObservingOptionNew
              context:tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext];

    [item addObserver:self
           forKeyPath:NSStringFromSelector(@selector(isEnabled))
              options:NSKeyValueObservingOptionNew
              context:tbtbbrcntrlr_tabBarItemEnabledContext];
}

- (void)tbtbbrcntrlr_removeItemObservers {

    for (TBTabBarItem *item in _items) {
        [self tbtbbrcntrlr_removeObserverForItem:item];
    }
}

- (void)tbtbbrcntrlr_removeObserverForItem:(TBTabBarItem *)item {

    [item removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(title))
                 context:tbtbbrcntrlr_tabBarItemTitleContext];

    [item removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(image))
                 context:tbtbbrcntrlr_tabBarItemImageContext];

    [item removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(selectedImage))
                 context:tbtbbrcntrlr_tabBarItemSelectedImageContext];

    [item removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(notificationIndicator))
                 context:tbtbbrcntrlr_tabBarItemNotificationIndicatorContext];

    [item removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(showsNotificationIndicator))
                 context:tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext];

    [item removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(isEnabled))
                 context:tbtbbrcntrlr_tabBarItemEnabledContext];
}

#pragma mark Helpers

- (void)tbtbbrcntrlr_specifyPreferredPlacementForSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass {

    if (_preferredPlacement == TBTabBarControllerTabBarPlacementUndefined) {
        _preferredPlacement = [self tbtbbrcntrlr_preferredTabBarPlacementForSizeClass:horizontalSizeClass];
    }
}

- (TBTabBarControllerTabBarPlacement)tbtbbrcntrlr_preferredTabBarPlacementForSizeClass:(UIUserInterfaceSizeClass)sizeClass  {

    return sizeClass == UIUserInterfaceSizeClassRegular ?
        TBTabBarControllerTabBarPlacementTrailing :
        TBTabBarControllerTabBarPlacementBottom;
}

- (void)tbtbbrcntrlr_captureNestedNavigationControllerIfExists {

    // This solution was borrowed from TOTabBarController
    // https://github.com/TimOliver/TOTabBarController

    UIViewController *viewController = _selectedViewController;

    do {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            tbtbbrcntrlr_nestedNavigationController = (UINavigationController *)viewController;
            break;
        }
    } while ((viewController = viewController.childViewControllers.firstObject));

    switch (_currentPlacement) {
        case TBTabBarControllerTabBarPlacementLeading:
            tbtbbrcntrlr_nestedNavigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0);
            break;

        case TBTabBarControllerTabBarPlacementTrailing:
            tbtbbrcntrlr_nestedNavigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.verticalTabBarWidth);
            break;

        case TBTabBarControllerTabBarPlacementBottom:
            tbtbbrcntrlr_nestedNavigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0);
            break;

        default:
            break;
    }
}

- (void)tbtbbrcntrlr_processViewControllersWithValue:(id)value {

    for (UIViewController *viewController in self.viewControllers) {
        [self tbtbbrcntrlr_processViewControllerChildren:viewController withValue:value];
    }
}

- (void)tbtbbrcntrlr_processViewControllerChildren:(__kindof UIViewController *)viewController
                                         withValue:(id)value {

    for (UIViewController *childViewController in viewController.childViewControllers) {
        [self tbtbbrcntrlr_processViewControllerChildren:childViewController withValue:value];
    }

    [viewController setValue:value forKey:NSStringFromSelector(@selector(tb_tabBarController))];
}

- (void)tbtbbrcntrlr_captureItems {

    _items = [self.viewControllers valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", NSStringFromSelector(@selector(tb_tabBarItem))]];
}

- (void)tbtbbrcntrlr_handleItemSelectionAtIndex:(NSUInteger)index {

    TBTabBar *visibleTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:nil];

    if (visibleTabBar != nil) {
        visibleTabBar.selectedIndex = index;
    } else {
        // If the current tab bar placement is .hidden there will be no visible tab bar
        // This means that the logic that responds for item selection won't be called
        // This is a workaround
        if (_delegateFlags.shouldSelectViewController && ![self.delegate tabBarController:self shouldSelectViewController:self.viewControllers[index]]) {
            return;
        }

        [self tbtbbrcntrlr_moveToViewControllerAtIndex:index];
        [self.horizontalTabBar _setSelectedIndex:index quietly:true];
        [self.verticalTabBar _setSelectedIndex:index quietly:true];

        if (_delegateFlags.didSelectViewController) {
            [self.delegate tabBarController:self didSelectViewController:_selectedViewController];
        }
    }
}

#pragma mark Gestures

- (void)tbtbbrcntrlr_handlePopGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer {

    if (tbtbbrcntrlr_nestedNavigationController != nil && tbtbbrcntrlr_nestedNavigationController.viewControllers.count > 1) {
        [tbtbbrcntrlr_nestedNavigationController popViewControllerAnimated:true];
    }
}

#pragma mark Getters

- (NSArray<__kindof TBTabBarItem *> *)items {

    return _items != nil ? [_items copy] : nil;
}

- (TBTabBar *)horizontalTabBar {

    if (_horizontalTabBar == nil) {

        Class const class = [[self class] horizontalTabBarClass];

        NSAssert([class isSubclassOfClass:[TBTabBar class]],
                 @"Horizontal tab bar must be kind of `%@`",
                 NSStringFromClass([TBTabBar class]));

        _horizontalTabBar = [[class alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
        _horizontalTabBar.delegate = self;
    }

    return _horizontalTabBar;
}

- (TBTabBar *)verticalTabBar {

    if (_verticalTabBar == nil) {

        Class const class = [[self class] verticalTabBarClass];

        NSAssert([class isSubclassOfClass:[TBTabBar class]],
                 @"Vertical tab bar must be kind of `%@`",
                 NSStringFromClass([TBTabBar class]));

        _verticalTabBar = [[class alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationVertical];
        _verticalTabBar.delegate = self;
    }

    return _verticalTabBar;
}

- (TBDummyBar *)dummyBar {

    if (_dummyBar == nil) {
        _dummyBar = [[TBDummyBar alloc] init];
    }

    return _dummyBar;
}

- (UISwipeGestureRecognizer *)popGestureRecognizer {

    if (_popGestureRecognizer == nil) {
        _popGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tbtbbrcntrlr_handlePopGestureRecognizer:)];
        _popGestureRecognizer.direction = self.view.tb_isLeftToRight ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionLeft;
    }

    return _popGestureRecognizer;
}

- (UIView *)containerView {

    if (_containerView == nil) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    return _containerView;
}

#pragma mark Setters

- (void)setViewControllers:(NSArray <__kindof UIViewController *> *)viewControllers {

    if (_viewControllers != nil && _viewControllers.count > 0) {
        [self tbtbbrcntrlr_removeItemObservers];
        [self tbtbbrcntrlr_processViewControllersWithValue:nil];
        [_items removeAllObjects];
    }

    if (viewControllers != nil && viewControllers.count > 0) {
        _viewControllers = [viewControllers copy];
        [self tbtbbrcntrlr_captureItems];
        [self tbtbbrcntrlr_observeItems];
        [self tbtbbrcntrlr_processViewControllersWithValue:self];
    } else {
        _viewControllers = nil;
        [self tbtbbrcntrlr_clearHierarchy];
    }

    [self.horizontalTabBar _setItems:_items];
    [self.verticalTabBar _setItems:_items];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {

    _selectedIndex = selectedIndex;

    [self tbtbbrcntrlr_handleItemSelectionAtIndex:selectedIndex];
}

- (void)setVerticalTabBarWidth:(CGFloat)verticalTabBarWidth {

    _verticalTabBarWidth = verticalTabBarWidth;

    [self.view setNeedsLayout];
}

- (void)setHorizontalTabBarHeight:(CGFloat)horizontalTabBarHeight {

    _horizontalTabBarHeight = horizontalTabBarHeight;

    [self.view setNeedsLayout];
}

- (void)setDelegate:(id<TBTabBarControllerDelegate>)delegate {

    _delegate = delegate;

    _delegateFlags.shouldSelectItemAtIndex = [_delegate respondsToSelector:@selector(tabBarController:shouldSelectItem:atIndex:)];
    _delegateFlags.didSelectItemAtIndex = [_delegate respondsToSelector:@selector(tabBarController:didSelectItem:atIndex:)];
    _delegateFlags.shouldSelectViewController = [_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)];
    _delegateFlags.didSelectViewController = [_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)];
    _delegateFlags.willShowTabBar = [_delegate respondsToSelector:@selector(tabBarController:willShowTabBar:)];
    _delegateFlags.didShowTabBar = [_delegate respondsToSelector:@selector(tabBarController:didShowTabBar:)];
    _delegateFlags.willHideTabBar = [_delegate respondsToSelector:@selector(tabBarController:willHideTabBar:)];
    _delegateFlags.didHideTabBar = [_delegate respondsToSelector:@selector(tabBarController:didHideTabBar:)];
    _delegateFlags.animationControllerForTransition = [_delegate respondsToSelector:@selector(tabBarController:animationControllerForTransitionFromViewController:toViewController:)];
}

@end

#pragma mark - Subclassing

@implementation TBTabBarController (Subclassing)

#pragma mark Public Methods

- (TBTabBarControllerTabBarPlacement)preferredTabBarPlacementForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass {

    return [self tbtbbrcntrlr_preferredTabBarPlacementForSizeClass:sizeClass];
}

- (TBTabBarControllerTabBarPlacement)preferredTabBarPlacementForViewSize:(CGSize)size {

    return _preferredPlacement;
}

+ (Class)horizontalTabBarClass {

    return [TBTabBar class];
}

+ (Class)verticalTabBarClass {

    return [TBTabBar class];
}

@end

#pragma mark - View controller extension

@implementation UIViewController (TBTabBarControllerExtension)

static char *_tabBarItemPropertyKey;
static char *_tabBarControllerPropertyKey;
static char *_tabBarControllerCategoryHidesTabBarWhenPushedKey;

#pragma mark Overrides

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TBSwizzleMethod([self class], @selector(setTitle:), @selector(_setTitle:));
    });
}

#pragma mark Private Methods

#pragma mark Getters

- (TBTabBarItem *)tb_tabBarItem {

    TBTabBarItem *item = objc_getAssociatedObject(self, &_tabBarItemPropertyKey);

    if (item == nil) {
        item = [[TBTabBarItem alloc] initWithImage:[[UIImage alloc] init] buttonClass:[TBTabBarButton class]];
        objc_setAssociatedObject(self, &_tabBarItemPropertyKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return item;
}

- (TBTabBarController *)tb_tabBarController {

    return objc_getAssociatedObject(self, &_tabBarControllerPropertyKey);
}

- (BOOL)tb_hidesTabBarWhenPushed {

    return [(NSNumber *)objc_getAssociatedObject(self, &_tabBarControllerCategoryHidesTabBarWhenPushedKey) boolValue];
}

#pragma mark Setters

- (void)_setTitle:(NSString *)title {

    [self _setTitle:title];

    if (self.tb_tabBarController != nil) {
        self.tb_tabBarItem.title = [title copy];
    }
}

- (void)tb_setTabBarItem:(TBTabBarItem *)tabBarItem {

    TBTabBarItem *prevItem = objc_getAssociatedObject(self, &_tabBarItemPropertyKey);
    TBTabBarItem *newItem = tabBarItem;

    if (newItem == nil) {
        newItem = [[TBTabBarItem alloc] initWithImage:[[UIImage alloc] init] buttonClass:[TBTabBarButton class]];
    }

    if (prevItem != nil) {
        if (self.tb_tabBarController != nil) {
            self.tb_tabBarItem.title = self.title;
            [self.tb_tabBarController _changeItem:prevItem toItem:newItem];
        }
    } else {
        if (self.tb_tabBarController != nil) {
            self.tb_tabBarItem.title = self.title;
        }
    }

    objc_setAssociatedObject(self,
                             &_tabBarItemPropertyKey,
                             tabBarItem,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTb_tabBarController:(TBTabBarController * _Nullable)tb_tabBarController {

    objc_setAssociatedObject(self,
                             &_tabBarControllerPropertyKey,
                             tb_tabBarController,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (void)tb_setHidesTabBarWhenPushed:(BOOL)_hidesTabBarWhenPushed {

    objc_setAssociatedObject(self,
                             &_tabBarControllerCategoryHidesTabBarWhenPushedKey,
                             @(_hidesTabBarWhenPushed),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - Tab bar controller private

@implementation TBTabBarController (Private)

- (void)_specifyPreferredTabBarPlacementForHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass
                                                         size:(CGSize)size {

    [self tbtbbrcntrlr_specifyPreferredPlacementForSizeClass:horizontalSizeClass];

    if (tbtbbrcntrlr_methodOverridesFlag & _TBTabBarControllerMethodOverridePreferredTabBarPlacementForViewSize) {
        TBTabBarControllerTabBarPlacement const preferredPlacement = [self preferredTabBarPlacementForViewSize:size];
        if (preferredPlacement != _preferredPlacement && preferredPlacement != TBTabBarControllerTabBarPlacementUndefined) {
            _preferredPlacement = preferredPlacement;
        }
    } else if (tbtbbrcntrlr_methodOverridesFlag & _TBTabBarControllerMethodOverridePreferredTabBarPlacementForHorizontalSizeClass) {
        TBTabBarControllerTabBarPlacement const preferredPlacement = [self preferredTabBarPlacementForHorizontalSizeClass:horizontalSizeClass];
        if (preferredPlacement != _preferredPlacement && preferredPlacement != TBTabBarControllerTabBarPlacementUndefined) {
            _preferredPlacement = preferredPlacement;
        }
    }
}

- (void)_changeItem:(TBTabBarItem *)item toItem:(TBTabBarItem *)newItem {

    NSUInteger const index = [_items indexOfObject:item];

    if (index == NSNotFound) {
        return;
    }

    [self tbtbbrcntrlr_removeObserverForItem:item];
    [_items removeObjectAtIndex:index];
    [self insertItem:item atIndex:index];
}

- (__kindof UIViewController *_Nullable)_visibleViewController {

    return tbtbbrcntrlr_nestedNavigationController != nil ?
        tbtbbrcntrlr_nestedNavigationController.visibleViewController :
        self.selectedViewController;
}

@end

#pragma mark - Navigation controller private delegate

@implementation TBTabBarController (TBNavigationControllerExtensionDefaultDelegate)

#pragma mark _TBNavigationControllerDelegate

- (void)tb_navigationController:(UINavigationController *)navigationController
   navigationBarDidChangeHeight:(CGFloat)height {

    if (tbtbbrcntrlr_dummyBarInternalHeight == height) {
        return;
    }

    tbtbbrcntrlr_dummyBarInternalHeight = height;

    [self.view setNeedsLayout];
}

- (void)tb_navigationController:(UINavigationController *)navigationController
         didBeginTransitionFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                      backwards:(BOOL)backwards {

    if (tbtbbrcntrlr_transitionState != nil) {
        return;
    }

    TBTabBar *tabBar;
    [self currentlyVisibleTabBar:&tabBar hiddenTabBar:nil];

    UIViewController *viewController;

    if (backwards) {
        if (navigationController.viewControllers.count < 2) {
            if (tabBar == nil) {
                [self _specifyPreferredTabBarPlacementForHorizontalSizeClass:self.traitCollection.horizontalSizeClass size:self.view.bounds.size];
                [self currentlyVisibleTabBar:nil hiddenTabBar:&tabBar];
            } else {
                _preferredPlacement = _currentPlacement;
            }
        } else {
            viewController = destinationViewController;
        }
    } else {
        viewController = destinationViewController;
    }

    if (viewController != nil) {
        BOOL const shouldHideTabBar = viewController.tb_hidesTabBarWhenPushed;
        if (tabBar == nil) {
            if (shouldHideTabBar) {
                _preferredPlacement = _currentPlacement;
            } else {
                [self _specifyPreferredTabBarPlacementForHorizontalSizeClass:self.traitCollection.horizontalSizeClass
                                                                        size:self.view.bounds.size];
                [self currentlyVisibleTabBar:nil hiddenTabBar:&tabBar];
            }
        } else {
            if (shouldHideTabBar) {
                _preferredPlacement = TBTabBarControllerTabBarPlacementHidden;
            } else {
                _preferredPlacement = _currentPlacement;
            }
        }
    }

    if (tabBar != nil) {
        
        if (_visibleViewControllerWantsHideTabBar) {
            [self tbtbbrcntrlr_showTabBarIfNeeded:tabBar tabBarToHide:nil];
        }
        
        tbtbbrcntrlr_transitionState = [_TBTabBarControllerTransitionState stateWithManipulatedTabBar:tabBar
                                                                                     initialPlacement:_currentPlacement
                                                                                      targetPlacement:_preferredPlacement
                                                                                            backwards:backwards];
        
    } else {
        
        tbtbbrcntrlr_transitionState = [_TBTabBarControllerTransitionState stateWithInitialPlacement:TBTabBarControllerTabBarPlacementHidden
                                                                                     targetPlacement:_currentPlacement
                                                                                           backwards:backwards];
    }

    _preferredPlacement = TBTabBarControllerTabBarPlacementUndefined;
}

- (void)tb_navigationController:(UINavigationController *)navigationController
       didUpdateInteractiveFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                percentComplete:(CGFloat)percentComplete {

    if (tbtbbrcntrlr_transitionState == nil) {
        return;
    }

    TBTabBar *tabBar = tbtbbrcntrlr_transitionState.manipulatedTabBar;

    if (tabBar == nil) {
        return;
    }

    if (tabBar.isVertical) {
        CGFloat const tabBarWidth = self.verticalTabBarWidth + self.view.safeAreaInsets.left;
        CGRect frame = tabBar.frame;
        if (tbtbbrcntrlr_transitionState.isShowing) {
            CGFloat const offset = -(tabBarWidth * MAX(0.0, (1.0 - percentComplete)));
            frame.origin.x = offset;
            tabBar.frame = frame;
            CGRect dummyBarFrame = self.dummyBar.frame;
            dummyBarFrame.origin.x = offset;
            self.dummyBar.frame = dummyBarFrame;
        } else if (tbtbbrcntrlr_transitionState.isHiding) {
            frame.origin.x = -(tabBarWidth * percentComplete);
            tabBar.frame = frame;
        }
    } else {
        CGFloat const tabBarHeight = self.horizontalTabBarHeight + self.view.safeAreaInsets.bottom;
        CGRect frame = tabBar.frame;
        if (tbtbbrcntrlr_transitionState.isShowing) {
            frame.origin.y = CGRectGetHeight(self.view.bounds) - (tabBarHeight * percentComplete);
            tabBar.frame = frame;
        } else if (tbtbbrcntrlr_transitionState.isHiding) {
            frame.origin.y = CGRectGetHeight(self.view.bounds) - (tabBarHeight * MAX(0.0, (1.0 - percentComplete)));
            tabBar.frame = frame;
        }
    }
}

- (void)tb_navigationController:(UINavigationController *)navigationController
          willEndTransitionFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                      cancelled:(BOOL)cancelled {

    if (tbtbbrcntrlr_transitionState == nil) {
        return;
    }

    if (cancelled) {
        _preferredPlacement = tbtbbrcntrlr_transitionState.initialPlacement;
    } else {
        _preferredPlacement = tbtbbrcntrlr_transitionState.targetPlacement;
    }

    UIViewController *visibleViewController = tbtbbrcntrlr_transitionState.backwards ? cancelled ? prevViewController : destinationViewController : destinationViewController;

    _visibleViewControllerWantsHideTabBar = visibleViewController.tb_hidesTabBarWhenPushed;

    [self tbtbbrcntrlr_beginTabBarTransition];
}

- (void)tb_navigationController:(UINavigationController *)navigationController
           didEndTransitionFrom:(UIViewController *)prevViewController
                             to:(UIViewController *)destinationViewController
                      cancelled:(BOOL)cancelled {

    [self tbtbbrcntrlr_endTabBarTransition];

    tbtbbrcntrlr_transitionState = nil;
}

@end
