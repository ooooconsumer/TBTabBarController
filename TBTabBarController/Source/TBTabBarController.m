//
//  TBTabBarController.m
//  TBTabBarController
//
//  Copyright (c) 2019-2020 Timur Ganiev
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
#import "UIViewController+_TBTabBarController.h"
#import "UIView+_TBTabBarController.h"
#import "_TBTabBarControllerTransitionContext.h"

#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, _TBTabBarControllerMethodOverrides) {
    _TBTabBarControllerMethodOverrideNone = 0,
    _TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass = 1 << 0,
    _TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize = 1 << 1
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

@end

static _TBTabBarControllerMethodOverrides tbtbbrcntrlr_methodOverridesFlag;

@implementation TBTabBarController {
    
    BOOL tbtbbrcntrlr_needsLayout;
    BOOL tbtbbrcntrlr_needsUpdateTabBarPosition;
    BOOL tbtbbrcntrlr_selectedViewControllerNeedsLayout;
    BOOL tbtbbrcntrlr_isTransitioning;
    
    CGFloat tbtbbrcntrlr_dummyBarInternalHeight;
    
    __weak UINavigationController *tbtbbrcntrlr_nestedNavigationController;
    
    _TBTabBarControllerTransitionContext *tbtbbrcntrlr_transitionContext;
}

@synthesize dummyBar = _dummyBar;
@synthesize popGestureRecognizer = _popGestureRecognizer;

#pragma mark - Public

#pragma mark Lifecycle

+ (void)initialize {
    
    [super initialize];
    
    if (self != [TBTabBarController class]) {
        if (_TBSubclassOverridesMethod([TBTabBarController class], self, @selector(preferredTabBarPositionForHorizontalSizeClass:))) {
            tbtbbrcntrlr_methodOverridesFlag |= _TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass;
        }
        if (_TBSubclassOverridesMethod([TBTabBarController class], self, @selector(preferredTabBarPositionForViewSize:))) {
            tbtbbrcntrlr_methodOverridesFlag |= _TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize;
        }
        NSAssert(tbtbbrcntrlr_methodOverridesFlag <= _TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize, @"Subclasses should never override both of the methods of the Subclassing category");
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

#pragma mark Interface

- (void)willPresentTabBar {
    
    [self _specifyPreferredTabBarPositionForHorizontalSizeClass:self.traitCollection.horizontalSizeClass size:self.view.bounds.size];
    
    _currentPosition = _preferredPosition;
    _preferredPosition = TBTabBarControllerTabBarPositionUndefined;
}

- (void)didPresentTabBar {
    
    _didPresentTabBarOnce = true;
    
    self.selectedIndex = self.startingIndex;
}

- (void)currentlyVisibleTabBar:(TBTabBar **)visibleTabBar hiddenTabBar:(TBTabBar **)hiddenTabBar {
    
    switch (_currentPosition) {
        case TBTabBarControllerTabBarPositionHidden:
            if (_preferredPosition > TBTabBarControllerTabBarPositionHidden) {
                switch (_preferredPosition) {
                    case TBTabBarControllerTabBarPositionLeading:
                        if (hiddenTabBar != nil) {
                            *hiddenTabBar = self.verticalTabBar;
                        }
                        break;
                    case TBTabBarControllerTabBarPositionBottom:
                        if (hiddenTabBar != nil) {
                            *hiddenTabBar = self.horizontalTabBar;
                        }
                        break;
                    default:
                        break;
                }
            }
            break;
        case TBTabBarControllerTabBarPositionLeading:
            if (visibleTabBar != nil) {
                *visibleTabBar = self.verticalTabBar;
            }
            if (hiddenTabBar != nil) {
                *hiddenTabBar = self.horizontalTabBar;
            }
            break;
        case TBTabBarControllerTabBarPositionBottom:
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

- (void)beginUpdateTabBarPosition {
    
    tbtbbrcntrlr_selectedViewControllerNeedsLayout = true;
    
    [self tbtbbrcntrlr_beginUpdateTabBarPosition];
}

- (void)endUpdateTabBarPosition {
    
    tbtbbrcntrlr_selectedViewControllerNeedsLayout = false;
    
    [self tbtbbrcntrlr_endUpdateTabBarPosition];
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
    
#if TB_AT_LEAST_IOS13
    if (!_didPresentTabBarOnce) {
        [self tbtbbrcntrlr_presentTabBar];
    }
#endif
    
    if (!tbtbbrcntrlr_needsLayout) {
        return;
    }
    
    CGRect const bounds = self.view.bounds;
    
    TBTabBar *hTabBar = self.horizontalTabBar;
    TBTabBar *vTabBar = self.verticalTabBar;
    TBDummyBar *dummyBar = self.dummyBar;
    
    if (_preferredPosition != TBTabBarControllerTabBarPositionUndefined) {
        switch (_preferredPosition) {
            case TBTabBarControllerTabBarPositionHidden:
                hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:true];
                vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:true];
                dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:true];
                break;
            case TBTabBarControllerTabBarPositionLeading:
                switch (_currentPosition) {
                    case TBTabBarControllerTabBarPositionHidden:
                        hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:true];
                        vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:false];
                        dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:false];
                        break;
                    case TBTabBarControllerTabBarPositionLeading:
                    case TBTabBarControllerTabBarPositionBottom:
                        hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:true];
                        CGRect vTabBarFrame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:false];
                        if (tbtbbrcntrlr_isTransitioning) {
                            vTabBarFrame.size.height += hTabBar.frame.size.height;
                        }
                        vTabBar.frame = vTabBarFrame;
                        dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:false];
                        break;
                    default:
                        break;
                }
                break;
            case TBTabBarControllerTabBarPositionBottom:
                switch (_currentPosition) {
                    case TBTabBarControllerTabBarPositionHidden:
                        hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:false];
                        vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:true];
                        dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:true];
                        break;
                    case TBTabBarControllerTabBarPositionLeading:
                    case TBTabBarControllerTabBarPositionBottom:
                        hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:false];
                        vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:true];
                        dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:true];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    } else if (_currentPosition != TBTabBarControllerTabBarPositionUndefined) {
        switch (_currentPosition) {
            case TBTabBarControllerTabBarPositionHidden:
                hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:true];
                vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:true];
                dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:true];
                break;
            case TBTabBarControllerTabBarPositionLeading:
                hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:true];
                vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:false];
                dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:false];
                break;
            case TBTabBarControllerTabBarPositionBottom:
                hTabBar.frame = [self tbtbbrcntrlr_horizontalTabBarFrameForBounds:bounds hidden:false];
                vTabBar.frame = [self tbtbbrcntrlr_verticalTabBarFrameForBounds:bounds hidden:true];
                dummyBar.frame = [self tbtbbrcntrlr_dummyBarFrameForBounds:bounds hidden:true];
                break;
            default:
                break;
        }
    }
    
    tbtbbrcntrlr_needsLayout = false;
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

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    UIUserInterfaceSizeClass const newHorizontalSizeClass = newCollection.horizontalSizeClass;
    
    if (self.traitCollection.horizontalSizeClass != newHorizontalSizeClass) {
        
        _preferredPosition = [self tbtbbrcntrlr_preferredTabBarPositionForSizeClass:newHorizontalSizeClass];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    if (CGSizeEqualToSize(self.view.frame.size, size) == false) {
        
        __weak typeof(self) weakSelf = self;
        
        [self _specifyPreferredTabBarPositionForHorizontalSizeClass:self.traitCollection.horizontalSizeClass size:size];
        
        // Adjust the vertical tab bar height to make it look good during the transition
        [self tbtbbrcntrlr_adjustVerticalTabBarHeightIfNeeded];
        
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            if (weakSelf == nil) {
                return;
            }
            typeof(self) strongSelf = weakSelf;
            strongSelf->tbtbbrcntrlr_isTransitioning = true;
            [strongSelf beginUpdateTabBarPosition];
        } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
            if (weakSelf == nil) {
                return;
            }
            typeof(self) strongSelf = weakSelf;
            [strongSelf endUpdateTabBarPosition];
            strongSelf->tbtbbrcntrlr_isTransitioning = false;
        }];
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#if !TB_AT_LEAST_IOS13
#pragma mark UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (_didPresentTabBarOnce == false) {
        [self tbtbbrcntrlr_presentTabBar];
    }
    
    [super traitCollectionDidChange:previousTraitCollection];
}
#endif

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary <NSKeyValueChangeKey, id> *)change context:(void *)context {
    
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

    [tabBar _setSelectedIndex:index quitly:true];

    if (otherTabBar.visibleItems.count > 0) {
        [otherTabBar _setSelectedIndex:[otherTabBar.visibleItems indexOfObject:item] quitly:true];
    }

    if (_delegateFlags.didSelectViewController) {
        [self.delegate tabBarController:self didSelectViewController:_selectedViewController];
    }
}

#pragma mark - Private

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

- (void)tbtbbrcntrlr_beginUpdateTabBarPosition {
    
    if (_preferredPosition == _currentPosition || _preferredPosition == TBTabBarControllerTabBarPositionUndefined) {
        [self _specifyPreferredTabBarPositionForHorizontalSizeClass:self.traitCollection.horizontalSizeClass size:self.view.bounds.size];
    }
    
    tbtbbrcntrlr_needsUpdateTabBarPosition = true;
    
    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];
    
    if (_preferredPosition != TBTabBarControllerTabBarPositionHidden) {
        if (tbtbbrcntrlr_nestedNavigationController != nil) {
            // When there is no transition between the view controllers we can user the currently visible view controller to look up whether we should hide the tab bar or not.
            BOOL const shouldHideTabBar = tbtbbrcntrlr_transitionContext != nil ? _visibleViewControllerWantsHideTabBar : [self _visibleViewController].tb_hidesTabBarWhenPushed;
            if (shouldHideTabBar) {
                _preferredPosition = TBTabBarControllerTabBarPositionHidden;
                _visibleViewControllerWantsHideTabBar = true;
            } else {
                _visibleViewControllerWantsHideTabBar = false;
            }
        }
    }
    
    if (_preferredPosition != _currentPosition) {
        id<TBTabBarControllerDelegate> delegate = self.delegate;
        switch (_preferredPosition) {
            case TBTabBarControllerTabBarPositionHidden:
                if (visibleTabBar != nil && _delegateFlags.willHideTabBar) {
                    [delegate tabBarController:self willHideTabBar:visibleTabBar];
                }
                break;
            case TBTabBarControllerTabBarPositionLeading:
            case TBTabBarControllerTabBarPositionBottom:
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
    
    [self _setNeedsLayoutView];
    [self.view layoutIfNeeded];
}

- (void)tbtbbrcntrlr_endUpdateTabBarPosition {
    
    if (!tbtbbrcntrlr_needsUpdateTabBarPosition) {
        _preferredPosition = TBTabBarControllerTabBarPositionUndefined;
        return;
    }
    
    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self currentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];
    
    if (_preferredPosition != _currentPosition) {
        id<TBTabBarControllerDelegate> delegate = self.delegate;
        switch (_preferredPosition) {
            case TBTabBarControllerTabBarPositionHidden:
                if (visibleTabBar != nil && _delegateFlags.didHideTabBar) {
                    [delegate tabBarController:self didHideTabBar:visibleTabBar];
                }
                break;
            case TBTabBarControllerTabBarPositionLeading:
            case TBTabBarControllerTabBarPositionBottom:
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
    
    _preferredPosition = TBTabBarControllerTabBarPositionUndefined;
    
    tbtbbrcntrlr_needsUpdateTabBarPosition = false;
    
    [self _setNeedsLayoutView];
    [self.view layoutIfNeeded];
}


- (void)tbtbbrcntrlr_updateAdditionalSafeAreaInsets:(BOOL)shouldLayoutManually {
    
    UIViewController *selectedViewController = self.selectedViewController;
    
    if (_preferredPosition == TBTabBarControllerTabBarPositionLeading) {
        selectedViewController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0);
    } else if (_preferredPosition == TBTabBarControllerTabBarPositionBottom) {
        selectedViewController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0);
    } else if (_preferredPosition == TBTabBarControllerTabBarPositionHidden) {
        selectedViewController.additionalSafeAreaInsets = UIEdgeInsetsZero;
    }
    
    if (shouldLayoutManually) {
        [selectedViewController.view setNeedsLayout];
        [selectedViewController.view layoutIfNeeded];
    }
}

- (void)tbtbbrcntrlr_showTabBarIfNeeded:(nullable TBTabBar *)tabBarToShow tabBarToHide:(nullable TBTabBar *)tabBarToHide {
    
    if (_preferredPosition == _currentPosition) {
        return;
    }
    
    if (tbtbbrcntrlr_isTransitioning) {
        // Adjust content insets only if the device is transitioning to the ...
        if (tabBarToShow != nil) {
            if (tabBarToShow.isVertical) {
                [tabBarToShow _setAdditionalContentInsets:UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight + self.view.safeAreaInsets.bottom, 0.0)];
            } else {
                [tabBarToShow _setAdditionalContentInsets:UIEdgeInsetsZero];
            }
        }
        if (tabBarToHide != nil && !tabBarToHide.isVertical) {
            [tabBarToHide _setAdditionalContentInsets:UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0)];
        }
    }
    
    if (_preferredPosition != TBTabBarControllerTabBarPositionHidden) {
        [self tbtbbrcntrlr_showTabBar:tabBarToShow];
    }
}

- (void)tbtbbrcntrlr_hideTabBarIfNeeded:(nullable TBTabBar *)tabBarToHide tabBarToShow:(nullable TBTabBar *)tabBarToShow {
    
    if (_preferredPosition == _currentPosition) {
        return;
    }
    
    if (tbtbbrcntrlr_isTransitioning) {
        if (tabBarToShow != nil && tabBarToShow.isVertical) {
            [tabBarToShow _setAdditionalContentInsets:UIEdgeInsetsZero];
        }
    }
    
    if (_currentPosition != TBTabBarControllerTabBarPositionHidden) {
        [self tbtbbrcntrlr_hideTabBar:tabBarToHide];
    }
    
    _currentPosition = _preferredPosition;
}

- (void)tbtbbrcntrlr_presentTabBar {
    
    [self willPresentTabBar];
    
    if (_currentPosition != TBTabBarControllerTabBarPositionHidden) {
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
            [self.view insertSubview:_dummyBar aboveSubview:tabBar];
        } else {
            [self.view addSubview:tabBar];
            [self.view addSubview:_dummyBar];
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
        [_dummyBar removeFromSuperview];
    }
    
    [tabBar removeFromSuperview];
    
    [tabBar _setVisible:false];
    
    if ([self.visibleTabBar isEqual:tabBar]) {
        self.visibleTabBar = nil;
    }
}

#pragma mark Layout

- (CGRect)tbtbbrcntrlr_horizontalTabBarFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden {
    
    CGFloat const width = CGRectGetWidth(bounds);
    CGFloat const height = CGRectGetHeight(bounds);
    
    CGFloat const hTabBarHeight = self.horizontalTabBarHeight + self.view.safeAreaInsets.bottom;
    
    if (hidden) {
        return (CGRect){{0.0, height}, {width, hTabBarHeight}};
    } else {
        return (CGRect){{0.0, height - hTabBarHeight}, {width, hTabBarHeight}};
    }
}

- (CGRect)tbtbbrcntrlr_verticalTabBarFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden {
    
    CGFloat const height = CGRectGetHeight(bounds);
    
    CGFloat const vTabBarWidth = self.verticalTabBarWidth + self.view.safeAreaInsets.left;
    
    if (hidden) {
        return (CGRect){{-vTabBarWidth, tbtbbrcntrlr_dummyBarInternalHeight}, {vTabBarWidth, height - tbtbbrcntrlr_dummyBarInternalHeight}};
    } else {
        return (CGRect){{0.0, tbtbbrcntrlr_dummyBarInternalHeight}, {vTabBarWidth, height - tbtbbrcntrlr_dummyBarInternalHeight}};
    }
}

- (CGRect)tbtbbrcntrlr_dummyBarFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden {
    
    CGFloat const vTabBarWidth = self.verticalTabBarWidth + self.view.safeAreaInsets.left;
    
    if (hidden) {
        return (CGRect){{-vTabBarWidth, 0.0}, {vTabBarWidth, tbtbbrcntrlr_dummyBarInternalHeight}};
    } else {
        return (CGRect){CGPointZero, {vTabBarWidth, tbtbbrcntrlr_dummyBarInternalHeight}};
    }
}

- (void)tbtbbrcntrlr_adjustVerticalTabBarHeightIfNeeded {
    
    if (_preferredPosition == TBTabBarControllerTabBarPositionBottom && _currentPosition == TBTabBarControllerTabBarPositionLeading) {
        TBTabBar *verticalTabBar = self.verticalTabBar;
        CGRect frame = verticalTabBar.frame;
        frame.size.height = CGRectGetHeight(frame) + self.horizontalTabBar.frame.size.height;
        verticalTabBar.frame = frame;
    }
}

#pragma mark Transitions

- (void)tbtbbrcntrlr_moveToViewControllerAtIndex:(NSUInteger)index {
    
    NSArray<UIViewController *> *viewControllers = self.viewControllers;
    
    if (index == NSNotFound || viewControllers.count <= index) {
        return;
    }
    
    [self tbtbbrcntrlr_removeChildViewControllerIfExists];
    
    _selectedViewController = viewControllers[index];
    
    [self tb_addContainerViewController:_selectedViewController atSubviewsIndex:0];
    
    [self tbtbbrcntrlr_captureNestedNavigationControllerIfExsists];
    
    switch (_currentPosition) {
        case TBTabBarControllerTabBarPositionLeading:
            tbtbbrcntrlr_nestedNavigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0);
            break;
        case TBTabBarControllerTabBarPositionBottom:
            tbtbbrcntrlr_nestedNavigationController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0);
            break;
        default:
            break;
    }
}

#pragma mark Observing

- (void)tbtbbrcntrlr_observeItems {
    
    for (TBTabBarItem *item in _items) {
        [self tbtbbrcntrlr_observeItem:item];
    }
}

- (void)tbtbbrcntrlr_observeItem:(TBTabBarItem *)item {
    
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:tbtbbrcntrlr_tabBarItemTitleContext];
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(image)) options:NSKeyValueObservingOptionNew context:tbtbbrcntrlr_tabBarItemImageContext];
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedImage)) options:NSKeyValueObservingOptionNew context:tbtbbrcntrlr_tabBarItemSelectedImageContext];
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(notificationIndicator)) options:NSKeyValueObservingOptionNew context:tbtbbrcntrlr_tabBarItemNotificationIndicatorContext];
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(showsNotificationIndicator)) options:NSKeyValueObservingOptionNew context:tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext];
    [item addObserver:self forKeyPath:NSStringFromSelector(@selector(isEnabled)) options:NSKeyValueObservingOptionNew context:tbtbbrcntrlr_tabBarItemEnabledContext];
}

- (void)tbtbbrcntrlr_removeItemObservers {
    
    for (TBTabBarItem *item in _items) {
        [self tbtbbrcntrlr_removeObserverForItem:item];
    }
}

- (void)tbtbbrcntrlr_removeObserverForItem:(TBTabBarItem *)item {
    
    [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(title)) context:tbtbbrcntrlr_tabBarItemTitleContext];
    [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(image)) context:tbtbbrcntrlr_tabBarItemImageContext];
    [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedImage)) context:tbtbbrcntrlr_tabBarItemSelectedImageContext];
    [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(notificationIndicator)) context:tbtbbrcntrlr_tabBarItemNotificationIndicatorContext];
    [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(showsNotificationIndicator)) context:tbtbbrcntrlr_tabBarItemShowsNotificationIndicatorContext];
    [item removeObserver:self forKeyPath:NSStringFromSelector(@selector(isEnabled)) context:tbtbbrcntrlr_tabBarItemEnabledContext];
}

#pragma mark Helpers

- (void)tbtbbrcntrlr_specifyPreferredPositionIfUndefinedForHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass {
    
    if (_preferredPosition == TBTabBarControllerTabBarPositionUndefined) {
        _preferredPosition = [self tbtbbrcntrlr_preferredTabBarPositionForSizeClass:horizontalSizeClass];
    }
}

- (TBTabBarControllerTabBarPosition)tbtbbrcntrlr_preferredTabBarPositionForSizeClass:(UIUserInterfaceSizeClass)sizeClass  {
    
    return sizeClass == UIUserInterfaceSizeClassRegular ? TBTabBarControllerTabBarPositionLeading : TBTabBarControllerTabBarPositionBottom;
}

- (void)tbtbbrcntrlr_removeChildViewControllerIfExists {
    
    UIViewController *selectedViewController = self.selectedViewController;
    
    if (selectedViewController == nil) {
        return;
    }
    
    [self tb_removeContainerViewController:selectedViewController];
    
    _selectedViewController = nil;
    tbtbbrcntrlr_nestedNavigationController = nil;
}

- (void)tbtbbrcntrlr_captureNestedNavigationControllerIfExsists {
    
    // This solution was borrowed from TOTabBarController (https://github.com/TimOliver/TOTabBarController)
    
    UIViewController *viewController = _selectedViewController;
    
    do {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            tbtbbrcntrlr_nestedNavigationController = (UINavigationController *)viewController;
            break;
        }
    } while ((viewController = viewController.childViewControllers.firstObject));
}

- (void)tbtbbrcntrlr_processViewControllersWithValue:(id)value {
    
    for (UIViewController *viewController in self.viewControllers) {
        [self tbtbbrcntrlr_processViewControllerChildren:viewController withValue:value];
    }
}

- (void)tbtbbrcntrlr_processViewControllerChildren:(__kindof UIViewController *)viewController withValue:(id)value {
    
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
        // If the current tab bar position is .hidden there will be no visible tab bar
        // This means that the logic that responds for item selection won't be called
        // This is a workaround
        if (_delegateFlags.shouldSelectViewController && ![self.delegate tabBarController:self shouldSelectViewController:self.viewControllers[index]]) {
            return;
        }
        [self tbtbbrcntrlr_moveToViewControllerAtIndex:index];
        [self.horizontalTabBar _setSelectedIndex:index quitly:true];
        [self.verticalTabBar _setSelectedIndex:index quitly:true];
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
    
    Class const horizontalTabBarClass = [[self class] horizontalTabBarClass];
    
    NSAssert([horizontalTabBarClass isSubclassOfClass:[TBTabBar class]], @"Horizontal tab bar must be of type `%@`", NSStringFromClass([TBTabBar class]));
    
    if (_horizontalTabBar == nil) {
        _horizontalTabBar = [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
        _horizontalTabBar.delegate = self;
    }
    
    return _horizontalTabBar;
}

- (TBTabBar *)verticalTabBar {
    
    Class const verticalTabBarClass = [[self class] verticalTabBarClass];
    
    NSAssert([verticalTabBarClass isSubclassOfClass:[TBTabBar class]], @"Vertical tab bar must be of type `%@`", NSStringFromClass([TBTabBar class]));
    
    if (_verticalTabBar == nil) {
        _verticalTabBar = [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationVertical];
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

#pragma mark Setters

- (void)setViewControllers:(NSArray <__kindof UIViewController *> *)viewControllers {
    
    if (_viewControllers != nil && _viewControllers.count > 0) {
        [self tbtbbrcntrlr_removeChildViewControllerIfExists];
        [self tbtbbrcntrlr_removeItemObservers];
        [self tbtbbrcntrlr_processViewControllersWithValue:nil];
        [_items removeAllObjects];
    }
    
    if (viewControllers != nil) {
        _viewControllers = [viewControllers copy];
        if (_viewControllers.count > 0) {
            [self tbtbbrcntrlr_captureItems];
            [self tbtbbrcntrlr_observeItems];
            [self tbtbbrcntrlr_processViewControllersWithValue:self];
        }
    } else {
        _viewControllers = nil;
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
    
    [self _setNeedsLayoutView];
}

- (void)setHorizontalTabBarHeight:(CGFloat)horizontalTabBarHeight {
    
    _horizontalTabBarHeight = horizontalTabBarHeight;
    
    [self _setNeedsLayoutView];
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
}

@end

#pragma mark - Subclassing

@implementation TBTabBarController (Subclassing)

#pragma mark - Public

#pragma mark Interface

- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass {
    
    return [self tbtbbrcntrlr_preferredTabBarPositionForSizeClass:sizeClass];
}

- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForViewSize:(CGSize)size {
    
    return _preferredPosition;
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

#pragma mark - Public

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TBSwizzleMethod([self class], @selector(setTitle:), @selector(_setTitle:));
    });
}

#pragma mark - Private

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
    
    objc_setAssociatedObject(self, &_tabBarItemPropertyKey, tabBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTb_tabBarController:(TBTabBarController * _Nullable)tb_tabBarController {
    
    objc_setAssociatedObject(self, &_tabBarControllerPropertyKey, tb_tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

- (void)tb_setHidesTabBarWhenPushed:(BOOL)_hidesTabBarWhenPushed {
    
    objc_setAssociatedObject(self, &_tabBarControllerCategoryHidesTabBarWhenPushedKey, @(_hidesTabBarWhenPushed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - Tab bar controller private

@implementation TBTabBarController (Private)

#pragma mark - Public

#pragma mark Interface

- (void)_setNeedsLayoutView {
    
    if (!tbtbbrcntrlr_needsLayout) {
        tbtbbrcntrlr_needsLayout = true;
        [self.view setNeedsLayout];
    }
}

- (void)_specifyPreferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass size:(CGSize)size {
    
    [self tbtbbrcntrlr_specifyPreferredPositionIfUndefinedForHorizontalSizeClass:horizontalSizeClass];
    
    if (tbtbbrcntrlr_methodOverridesFlag & _TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize) {
        TBTabBarControllerTabBarPosition const preferredPosition = [self preferredTabBarPositionForViewSize:size];
        if (preferredPosition != _preferredPosition && preferredPosition != TBTabBarControllerTabBarPositionUndefined) {
            _preferredPosition = preferredPosition;
        }
    } else if (tbtbbrcntrlr_methodOverridesFlag & _TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass) {
        TBTabBarControllerTabBarPosition const preferredPosition = [self preferredTabBarPositionForHorizontalSizeClass:horizontalSizeClass];
        if (preferredPosition != _preferredPosition && preferredPosition != TBTabBarControllerTabBarPositionUndefined) {
            _preferredPosition = preferredPosition;
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
    
    return tbtbbrcntrlr_nestedNavigationController != nil ? tbtbbrcntrlr_nestedNavigationController.visibleViewController : self.selectedViewController;
}

@end

#pragma mark - Navigation controller private delegate

@implementation TBTabBarController (TBNavigationControllerExtensionDefaultDelegate)

#pragma mark - Public

#pragma mark _TBNavigationControllerDelegate

- (void)tb_navigationController:(UINavigationController *)navigationController navigationBarDidChangeHeight:(CGFloat)height {
    
    if (tbtbbrcntrlr_dummyBarInternalHeight == height) {
        return;
    }
    
    tbtbbrcntrlr_dummyBarInternalHeight = height;
    
    [self _setNeedsLayoutView];
}

- (void)tb_navigationController:(UINavigationController *)navigationController didBeginTransitionFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController backwards:(BOOL)backwards {
    
    if (tbtbbrcntrlr_transitionContext != nil) {
        return;
    }
    
    TBTabBar *tabBar;
    [self currentlyVisibleTabBar:&tabBar hiddenTabBar:nil];
    
    UIViewController *viewController;
    
    if (backwards) {
        if (navigationController.viewControllers.count < 2) {
            if (tabBar == nil) {
                [self _specifyPreferredTabBarPositionForHorizontalSizeClass:self.traitCollection.horizontalSizeClass size:self.view.bounds.size];
                [self currentlyVisibleTabBar:nil hiddenTabBar:&tabBar];
            } else {
                _preferredPosition = _currentPosition;
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
                _preferredPosition = _currentPosition;
            } else {
                [self _specifyPreferredTabBarPositionForHorizontalSizeClass:self.traitCollection.horizontalSizeClass size:self.view.bounds.size];
                [self currentlyVisibleTabBar:nil hiddenTabBar:&tabBar];
            }
        } else {
            if (shouldHideTabBar) {
                _preferredPosition = TBTabBarControllerTabBarPositionHidden;
            } else {
                _preferredPosition = _currentPosition;
            }
        }
    }
    
    if (tabBar != nil) {
        
        if (_visibleViewControllerWantsHideTabBar) {
            [self tbtbbrcntrlr_showTabBarIfNeeded:tabBar tabBarToHide:nil];
        }
        
        tbtbbrcntrlr_transitionContext = [_TBTabBarControllerTransitionContext contextWithManipulatedTabBar:tabBar initialPosition:_currentPosition targetPosition:_preferredPosition backwards:backwards];
        
    } else {
        
        tbtbbrcntrlr_transitionContext = [_TBTabBarControllerTransitionContext contextWithInitialPosition:TBTabBarControllerTabBarPositionHidden targetPosition:_currentPosition backwards:backwards];
    }
    
    _preferredPosition = TBTabBarControllerTabBarPositionUndefined;
}

- (void)tb_navigationController:(UINavigationController *)navigationController didUpdateInteractiveFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController percentComplete:(CGFloat)percentComplete {
    
    if (tbtbbrcntrlr_transitionContext == nil) {
        return;
    }
    
    TBTabBar *tabBar = tbtbbrcntrlr_transitionContext.manipulatedTabBar;
    
    if (tabBar == nil) {
        return;
    }
    
    if (tabBar.isVertical) {
        CGFloat const tabBarWidth = self.verticalTabBarWidth + self.view.safeAreaInsets.left;
        CGRect frame = tabBar.frame;
        if (tbtbbrcntrlr_transitionContext.isShowing) {
            CGFloat const offset = -(tabBarWidth * MAX(0.0, (1.0 - percentComplete)));
            frame.origin.x = offset;
            tabBar.frame = frame;
            CGRect dummyBarFrame = _dummyBar.frame;
            dummyBarFrame.origin.x = offset;
            _dummyBar.frame = dummyBarFrame;
        } else if (tbtbbrcntrlr_transitionContext.isHiding) {
            frame.origin.x = -(tabBarWidth * percentComplete);
            tabBar.frame = frame;
        }
    } else {
        CGFloat const tabBarHeight = self.horizontalTabBarHeight + self.view.safeAreaInsets.bottom;
        CGRect frame = tabBar.frame;
        if (tbtbbrcntrlr_transitionContext.isShowing) {
            frame.origin.y = CGRectGetHeight(self.view.bounds) - (tabBarHeight * percentComplete);
            tabBar.frame = frame;
        } else if (tbtbbrcntrlr_transitionContext.isHiding) {
            frame.origin.y = CGRectGetHeight(self.view.bounds) - (tabBarHeight * MAX(0.0, (1.0 - percentComplete)));
            tabBar.frame = frame;
        }
    }
}

- (void)tb_navigationController:(UINavigationController *)navigationController willEndTransitionFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController cancelled:(BOOL)cancelled {
    
    if (tbtbbrcntrlr_transitionContext == nil) {
        return;
    }
    
    if (cancelled) {
        _preferredPosition = tbtbbrcntrlr_transitionContext.initialPosition;
    } else {
        _preferredPosition = tbtbbrcntrlr_transitionContext.targetPosition;
    }
    
    UIViewController *visibleViewController = tbtbbrcntrlr_transitionContext.backwards ? cancelled ? prevViewController : destinationViewController : destinationViewController;
    
    _visibleViewControllerWantsHideTabBar = visibleViewController.tb_hidesTabBarWhenPushed;
    
    [self tbtbbrcntrlr_beginUpdateTabBarPosition];
}

- (void)tb_navigationController:(UINavigationController *)navigationController didEndTransitionFrom:(UIViewController *)prevViewController to:(UIViewController *)destinationViewController cancelled:(BOOL)cancelled {
    
    [self tbtbbrcntrlr_endUpdateTabBarPosition];
    
    tbtbbrcntrlr_transitionContext = nil;
}

@end
