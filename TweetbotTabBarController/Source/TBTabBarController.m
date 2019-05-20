//
//  TBTabBarController.m
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

#import "TBTabBarController.h"

#import "TBTabBar+Private.h"
#import "_TBTabBarButton.h"
#import "TBDotLayer.h"

#import "TBUtils.h"

#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, TBTabBarControllerMethodOverrides) {
    TBTabBarControllerMethodOverrideNone = 0,
    TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass = 1 << 0,
    TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize = 1 << 1
};

const CGFloat TBFakeNavigationBarAutomaticDimension = 10000.0;

@interface TBTabBarController ()

@property (strong, nonatomic, readwrite) TBTabBar *leftTabBar;
@property (strong, nonatomic, readwrite) TBTabBar *bottomTabBar;
@property (weak, nonatomic, readwrite) TBTabBar *visibleTabBar;
@property (weak, nonatomic, readwrite) TBTabBar *hiddenTabBar;

@property (strong, nonatomic, readwrite) TBFakeNavigationBar *fakeNavigationBar;

@property (strong, nonatomic) UIStackView *containerView;

@property (strong, nonatomic) NSArray <TBTabBarItem *> *items; // since we are not operating with only one tab bar, we have to keep all the items here

@property (weak, nonatomic) UINavigationController *childNavigationController;

@property (strong, nonatomic) NSLayoutConstraint *bottomTabBarBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomTabBarHeightConstraint;

@property (strong, nonatomic) NSLayoutConstraint *containerViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewBottomConstraint;

@property (strong, nonatomic) NSLayoutConstraint *fakeNavBarHeightConstraint;

@end

static TBTabBarControllerMethodOverrides tb_methodOverridesFlags;

@implementation TBTabBarController {
    
    TBTabBarControllerTabBarPosition tb_currentPosition;
    TBTabBarControllerTabBarPosition tb_preferredPosition;
    
    struct {
        unsigned int shouldSelectViewController:1;
        unsigned int didSelectViewController:1;
    } tb_delegateFlags;
    
    BOOL tb_needsUpdateViewConstraints;
}

static void *tb_tabBarItemImageContext = &tb_tabBarItemImageContext;
static void *tb_tabBarItemSelectedImageContext = &tb_tabBarItemSelectedImageContext;
static void *tb_tabBarItemEnabledContext = &tb_tabBarItemEnabledContext;
static void *tb_tabBarItemShowDotContext = &tb_tabBarItemShowDotContext;

@synthesize popGestureRecognizer = _popGestureRecognizer;

#pragma mark - Public

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self tb_commonInit];
    }
    
    return self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self tb_commonInit];
    }
    
    return self;
}


#pragma mark Lifecycle

+ (void)initialize {
    
    [super initialize];
    
    if (self != [TBTabBarController class]) {
        
        if (TBSubclassOverridesMethod([TBTabBarController class], self, @selector(preferredTabBarPositionForHorizontalSizeClass:))) {
            tb_methodOverridesFlags |= TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass;
        }
        if (TBSubclassOverridesMethod([TBTabBarController class], self, @selector(preferredTabBarPositionForViewSize:))) {
            tb_methodOverridesFlags |= TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize;
        }
        
        NSAssert(tb_methodOverridesFlags <= TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize, @"The %@ subclass overrides both methods of the Subclasses category.", NSStringFromClass(self));
    }
}


- (void)dealloc {
    
    [self tb_stopObservingTabBarItems];
}


#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self tb_setup];
}


- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (self.selectedViewController != nil) {
        self.selectedViewController.view.frame = self.view.frame;
    }
}


#pragma mark UIContainerViewControllerProtectedMethods

- (UIViewController *)childViewControllerForStatusBarStyle {
    
    return [self tb_currentlyVisibleViewController];
}


- (UIViewController *)childViewControllerForStatusBarHidden {
    
    return [self tb_currentlyVisibleViewController];
}


#pragma mark Status bar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return [self tb_currentlyVisibleViewController].preferredStatusBarUpdateAnimation;
}


#pragma mark UIViewControllerRotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return [self tb_currentlyVisibleViewController].supportedInterfaceOrientations;
}


#pragma mark UIHomeIndicatorAutoHidden

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    
    return [self tb_currentlyVisibleViewController];
}


#pragma mark UIConstraintBasedLayoutCoreMethods

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    if (tb_needsUpdateViewConstraints == true) {
        tb_needsUpdateViewConstraints = false;
        [self tb_updateViewConstraints];
        [self tb_updateFakeNavBarHeightConstraintConstant];
        tb_preferredPosition = TBTabBarControllerTabBarPositionUnspecified; // An unspecified position means that the trait collection has not been changed, so we have to rely on the current one
    }
}


#pragma mark Subclasses

- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass {
    
    return [self tb_preferredTabBarPositionForSizeClass:sizeClass];
}


- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForViewSize:(CGSize)size {
    
    return tb_preferredPosition;
}


#pragma mark UIContentContainer

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    UIUserInterfaceSizeClass const newHorizontalSizeClass = newCollection.horizontalSizeClass;
    
    if (self.traitCollection.horizontalSizeClass != newHorizontalSizeClass) {
        
        if ((tb_methodOverridesFlags & TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize) == false) {
            tb_preferredPosition = [self preferredTabBarPositionForHorizontalSizeClass:newHorizontalSizeClass];
            [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNecessary:newHorizontalSizeClass]; // Subclasses may return an unspecified position
        } else {
            // In case where a subclass overrides the -preferredTabBarPositionForViewSize: method, we should capture new preferred position for a new horizontal size class since a subclass may return either an unspecified position or call super.
            tb_preferredPosition = [self tb_preferredTabBarPositionForSizeClass:newHorizontalSizeClass];
        }
    }
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    if (CGSizeEqualToSize(self.view.frame.size, size) == false) {
        
        // By default the preferredTabBarPositionForViewSize: method returns tb_preferredPosition property, so we have to capture it before a subclass will call super
        // An unspecified position means that trait collection has not been changed in a while
        [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNecessary:self.traitCollection.horizontalSizeClass];
        
        if ((tb_methodOverridesFlags & TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize) == true) {
            TBTabBarControllerTabBarPosition preferredPosition = [self preferredTabBarPositionForViewSize:size];
            if (preferredPosition != tb_preferredPosition && preferredPosition != TBTabBarControllerTabBarPositionUnspecified) {
                tb_preferredPosition = preferredPosition;
            }
        }
        
        [self tb_updateTabBarsVisibilityWithTransitionCoordinator:coordinator];
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (previousTraitCollection == nil) {
        UIUserInterfaceSizeClass const horizontalSizeClass = self.traitCollection.horizontalSizeClass;
        // Capture preferred position for subclasses
        tb_preferredPosition = [self tb_preferredTabBarPositionForSizeClass:horizontalSizeClass];
        // Capture preferred position
        if (tb_methodOverridesFlags & TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize) {
            tb_preferredPosition = [self preferredTabBarPositionForViewSize:self.view.frame.size];
        } else {
            tb_preferredPosition = [self preferredTabBarPositionForHorizontalSizeClass:horizontalSizeClass];
        }
        [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNecessary:horizontalSizeClass];
        // Capture current position
        tb_currentPosition = tb_preferredPosition;
        // Update tab bars visibility
        TBTabBar *tabBarToShow, *tabBarToHide;
        [self tb_getCurrentlyVisibleTabBar:&tabBarToShow hiddenTabBar:&tabBarToHide];
        [self tb_makeTabBarVisible:tabBarToShow];
        [self tb_makeTabBarHidden:tabBarToHide];
        // Update constraints
        tb_needsUpdateViewConstraints = true;
        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
        // Make the vertical tab bar look good
        [self tb_setVerticalTabBarBottomContentInset:self.leftTabBar.contentInsets.bottom];
        [self tb_setContainerViewBottomConstraintConstant:-(_bottomTabBarHeightConstraint.constant)];
    }
    
    [super traitCollectionDidChange:previousTraitCollection];
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary <NSKeyValueChangeKey, id> *)change context:(void *)context {
    
    NSUInteger const itemIndex = [self.items indexOfObject:object];
    
    if (itemIndex == NSNotFound) {
        return;
    }
    
    _TBTabBarButton *bottomTabBarButtonAtIndex = self.bottomTabBar.buttons[itemIndex];
    _TBTabBarButton *leftTabBarButtonAtIndex = self.leftTabBar.buttons[itemIndex];
    
    if (context == tb_tabBarItemImageContext) {
        UIImage *newImage = (UIImage *)change[NSKeyValueChangeNewKey];
        [bottomTabBarButtonAtIndex setImage:newImage forState:UIControlStateNormal];
        [leftTabBarButtonAtIndex setImage:newImage forState:UIControlStateNormal];
    } else if (context == tb_tabBarItemSelectedImageContext) {
        UIImage *newSelectedImage = (UIImage *)change[NSKeyValueChangeNewKey];
        [bottomTabBarButtonAtIndex setImage:newSelectedImage forState:UIControlStateSelected];
        [leftTabBarButtonAtIndex setImage:newSelectedImage forState:UIControlStateSelected];
    } else if (context == tb_tabBarItemEnabledContext) {
        BOOL const enabled = [(NSNumber *)change[NSKeyValueChangeNewKey] boolValue];
        bottomTabBarButtonAtIndex.enabled = enabled;
        leftTabBarButtonAtIndex.enabled = enabled;
    } else if (context == tb_tabBarItemShowDotContext) {
        BOOL const showDot = ![(NSNumber *)change[NSKeyValueChangeNewKey] boolValue];
        [self.bottomTabBar tb_setDotHidden:showDot atTabIndex:itemIndex];
        [self.leftTabBar tb_setDotHidden:showDot atTabIndex:itemIndex];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark TBTabBarDelegate

- (BOOL)isTabBarCurrentlyVisible:(TBTabBar *)tabBar {
    
    return [tabBar isEqual:self.self.visibleTabBar];
}


- (void)tabBar:(TBTabBar *)tabBar didSelectItem:(TBTabBarItem *)item {
    
    NSUInteger const itemIndex = [_items indexOfObject:item];
    
    BOOL shouldSelectViewController = (itemIndex == self.selectedIndex) ? false : true;
    
    __kindof UIViewController *childViewController = self.viewControllers[itemIndex];
    
    id <TBTabBarControllerDelegate> delegate = self.delegate;
    
    if (tb_delegateFlags.shouldSelectViewController) {
        shouldSelectViewController = [delegate tabBarController:self shouldSelectViewController:childViewController];
    }
    
    if (shouldSelectViewController == false) {
        return;
    }
    
    self.selectedIndex = itemIndex;
    
    if (tb_delegateFlags.didSelectViewController) {
        [delegate tabBarController:self didSelectViewController:childViewController];
    }
}


#pragma mark - Private

- (void)tb_commonInit {
    
    // UINavigationBar
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]].translucent = false;
    
    // Public
    self.startingIndex = 0;
    
    _horizontalTabBarHeight = 49.0;
    _verticalTabBarWidth = 60.0;
    _fakeNavigationBarHeight = TBFakeNavigationBarAutomaticDimension;
}


- (void)tb_setup {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Horizontal tab bar
    [self.view addSubview:self.bottomTabBar];
    
    // Container view
    _containerView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _containerView.axis = UILayoutConstraintAxisVertical;
    _containerView.alignment = UIStackViewAlignmentCenter;
    _containerView.distribution = UIStackViewDistributionFill;
    _containerView.spacing = 0.0;
    _containerView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addSubview:_containerView];
    
    // Verical tab bar
    [_containerView addArrangedSubview:self.fakeNavigationBar];
    [_containerView addArrangedSubview:self.leftTabBar];
    
    [self.leftTabBar addGestureRecognizer:self.popGestureRecognizer];
    
    // Constraints
    [self tb_setupConstraints];
}


#pragma mark Layout

- (void)tb_setupConstraints {
    
    UIView *view = self.view;
    
    UIStackView *containerView = self.containerView;
    
    TBTabBar *bottomTabBar = self.bottomTabBar;
    
    // Container view
    _containerViewLeftConstraint = [containerView.leftAnchor constraintEqualToAnchor:view.leftAnchor];
    NSLayoutConstraint *containerViewTopConstraint = [containerView.topAnchor constraintEqualToAnchor:view.topAnchor];
    _containerViewBottomConstraint = [containerView.bottomAnchor constraintEqualToAnchor:bottomTabBar.bottomAnchor];
    _containerViewWidthConstraint = [containerView.widthAnchor constraintEqualToConstant:self.verticalTabBarWidth];
    
    TBFakeNavigationBar *fakeNavBar = self.fakeNavigationBar;
    
    // Fake navigation bar
    NSLayoutConstraint *fakeNavBarWidthConstraint = [fakeNavBar.widthAnchor constraintEqualToAnchor:containerView.widthAnchor];
    _fakeNavBarHeightConstraint = [fakeNavBar.heightAnchor constraintEqualToConstant:0.0];
    
    TBTabBar *leftTabBar = self.leftTabBar;
    
    // Left tab bar
    NSLayoutConstraint *leftTabBarWidthConstraint = [leftTabBar.widthAnchor constraintEqualToAnchor:self.containerView.widthAnchor];
    
    // Bottom tab bar
    NSLayoutConstraint *bottomTabBarLeftConstraint = [bottomTabBar.leftAnchor constraintEqualToAnchor:containerView.rightAnchor];
    NSLayoutConstraint *bottomTabBarRightConstraint = [bottomTabBar.rightAnchor constraintEqualToAnchor:view.rightAnchor];
    _bottomTabBarBottomConstraint = [bottomTabBar.bottomAnchor constraintEqualToAnchor:view.bottomAnchor];
    _bottomTabBarHeightConstraint = [bottomTabBar.heightAnchor constraintEqualToConstant:self.horizontalTabBarHeight];
    
    // Activation
    [NSLayoutConstraint activateConstraints:@[_containerViewLeftConstraint, containerViewTopConstraint, _containerViewBottomConstraint, _containerViewWidthConstraint, fakeNavBarWidthConstraint, _fakeNavBarHeightConstraint, leftTabBarWidthConstraint, bottomTabBarLeftConstraint, bottomTabBarRightConstraint, _bottomTabBarBottomConstraint, _bottomTabBarHeightConstraint]];
}


- (void)tb_updateViewConstraints {
    
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    UIEdgeInsets bottomTabBarContentInsets = self.bottomTabBar.contentInsets;
    UIEdgeInsets leftTabBarContentInsets = self.leftTabBar.contentInsets;
    
    CGFloat const minBottomTabBarHeight = self.horizontalTabBarHeight + safeAreaInsets.bottom;
    CGFloat const minLeftTabBarWidth = self.verticalTabBarWidth + safeAreaInsets.left;
    CGFloat const bottomTabBarHeight = MAX(minBottomTabBarHeight + bottomTabBarContentInsets.top + bottomTabBarContentInsets.bottom, minBottomTabBarHeight);
    CGFloat const leftTabBarWidth = MAX(minLeftTabBarWidth + leftTabBarContentInsets.left + leftTabBarContentInsets.right, minLeftTabBarWidth);
    
    _bottomTabBarHeightConstraint.constant = bottomTabBarHeight;
    _containerViewWidthConstraint.constant = leftTabBarWidth;
    
    if (tb_preferredPosition == TBTabBarControllerTabBarPositionLeft) {
        _bottomTabBarBottomConstraint.constant = bottomTabBarHeight;
        _containerViewLeftConstraint.constant = 0.0;
    } else {
        _bottomTabBarBottomConstraint.constant = 0.0;
        _containerViewLeftConstraint.constant = -leftTabBarWidth;
    }
}


- (void)tb_updateFakeNavBarHeightConstraintConstant {
    
    CGFloat const separatorHeight = (1.0 / self.traitCollection.displayScale);
    CGFloat const preferredHeight = self.fakeNavigationBarHeight;
    CGFloat const height = preferredHeight != TBFakeNavigationBarAutomaticDimension ? preferredHeight: CGRectGetMaxY(_childNavigationController.navigationBar.frame);
    
    _fakeNavBarHeightConstraint.constant = height + separatorHeight;
}


- (void)tb_setVerticalTabBarBottomContentInset:(CGFloat)value {
    
    TBTabBar *tabBar = self.leftTabBar;
    
    UIEdgeInsets contentInsets = tabBar.contentInsets;
    contentInsets.bottom = value;
    
    tabBar.contentInsets = contentInsets;
}


- (void)tb_setContainerViewBottomConstraintConstant:(CGFloat)constant {
    
    _containerViewBottomConstraint.constant = constant;
}


- (void)tb_updateTabBarsVisibilityWithTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    __weak typeof(self) weakSelf = self;
    
    if (tb_preferredPosition == TBTabBarControllerTabBarPositionUnspecified || tb_preferredPosition == tb_currentPosition) {
        tb_needsUpdateViewConstraints = true;
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            [weakSelf.view setNeedsUpdateConstraints];
            [weakSelf.view updateConstraintsIfNeeded];
            [weakSelf.view layoutIfNeeded];
        } completion:nil];
        return;
    }
    
    TBTabBar *visibleTabBar, *hiddenTabBar;
    [self tb_getCurrentlyVisibleTabBar:&visibleTabBar hiddenTabBar:&hiddenTabBar];
    
    [self tb_makeTabBarVisible:hiddenTabBar]; // Show the currently hidden tab bar
    
    tb_currentPosition = tb_preferredPosition;
    
    CGFloat const previousVerticalTabBarBottomInset = self.leftTabBar.contentInsets.bottom;
    
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        typeof(self) strongSelf = weakSelf;
        strongSelf->tb_needsUpdateViewConstraints = true;
        [weakSelf.view setNeedsUpdateConstraints];
        [weakSelf.view updateConstraintsIfNeeded];
        [weakSelf.view layoutIfNeeded];
        [weakSelf tb_setVerticalTabBarBottomContentInset:-(weakSelf.bottomTabBarHeightConstraint.constant)];
        [weakSelf tb_setContainerViewBottomConstraintConstant:0.0];
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        [weakSelf tb_makeTabBarHidden:visibleTabBar]; // Hide the previously visible tab bar
        [weakSelf tb_setVerticalTabBarBottomContentInset:previousVerticalTabBarBottomInset];
        [weakSelf tb_setContainerViewBottomConstraintConstant:-(weakSelf.bottomTabBarHeightConstraint.constant)];
    }];
}


- (void)tb_makeTabBarVisible:(TBTabBar *)tabBar {
    
    _visibleTabBar = tabBar;
    
    if (_visibleTabBar.isVertical) {
        self.containerView.hidden = false;
        [self tb_setAdditionalSafeAreaInsets: UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0)];
    } else {
        _visibleTabBar.hidden = false;
        [self tb_setAdditionalSafeAreaInsets: UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0)];
    }
}


- (void)tb_makeTabBarHidden:(TBTabBar *)tabBar {
    
    _hiddenTabBar = tabBar;
    
    if (_hiddenTabBar.isVertical) {
        self.containerView.hidden = true;
    } else {
        _hiddenTabBar.hidden = true;
    }
}


- (void)tb_setAdditionalSafeAreaInsets:(UIEdgeInsets)additionalSafeAreaInsets {
    
    self.selectedViewController.additionalSafeAreaInsets = additionalSafeAreaInsets;
}


#pragma mark Transitions

- (void)tb_transitionToViewControllerAtIndex:(NSUInteger)index {
    
    NSArray <__kindof UIViewController *> *const viewControllers = self.viewControllers;
    
    if (index > viewControllers.count) {
        index = viewControllers.count - 1;
    }
    
    [self tb_removeChildViewControllerIfExists];
    [self tb_presentChildViewController:viewControllers[index]];
    [self tb_captureChildNavigationControllerIfExsists];
    
    self.bottomTabBar.selectedIndex = index;
    self.leftTabBar.selectedIndex = index;
    
    if (tb_preferredPosition == TBTabBarControllerTabBarPositionUnspecified) {
        tb_preferredPosition = tb_currentPosition;
    }
    
    if (self.visibleTabBar.isVertical) {
        [self tb_setAdditionalSafeAreaInsets:UIEdgeInsetsMake(0.0, self.verticalTabBarWidth, 0.0, 0.0)];
    } else {
        [self tb_setAdditionalSafeAreaInsets:UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0)];
    }
    
    [self.view setNeedsUpdateConstraints];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)tb_presentChildViewController:(__kindof UIViewController *)viewController {
    
    _selectedViewController = viewController;
    
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view insertSubview:viewController.view atIndex:0];
    [viewController didMoveToParentViewController:self];
}


- (void)tb_removeChildViewControllerIfExists {
    
    if (self.selectedViewController == nil) {
        return;
    }
    
    [self.selectedViewController willMoveToParentViewController:nil];
    [self.selectedViewController removeFromParentViewController];
    [self.selectedViewController.view removeFromSuperview];
    [self.selectedViewController didMoveToParentViewController:nil];
    
    _selectedViewController = nil;
    _childNavigationController = nil;
}


#pragma mark Observing

- (void)tb_startObservingTabBarItems {
    
    for (TBTabBarItem *item in _items) {
        [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:tb_tabBarItemImageContext];
        [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:tb_tabBarItemSelectedImageContext];
        [item addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:tb_tabBarItemEnabledContext];
        [item addObserver:self forKeyPath:@"showDot" options:NSKeyValueObservingOptionNew context:tb_tabBarItemShowDotContext];
    }
}

- (void)tb_stopObservingTabBarItems {
    
    for (TBTabBarItem *item in _items) {
        [item removeObserver:self forKeyPath:@"image" context:tb_tabBarItemImageContext];
        [item removeObserver:self forKeyPath:@"selectedImage" context:tb_tabBarItemSelectedImageContext];
        [item removeObserver:self forKeyPath:@"enabled" context:tb_tabBarItemEnabledContext];
        [item removeObserver:self forKeyPath:@"showDot" context:tb_tabBarItemShowDotContext];
    }
}


#pragma mark Utils

- (void)tb_specifyPreferredPositionWithHorizontalSizeClassIfNecessary:(UIUserInterfaceSizeClass)sizeClass {
    
    if (tb_preferredPosition == TBTabBarControllerTabBarPositionUnspecified) {
        tb_preferredPosition = [self tb_preferredTabBarPositionForSizeClass:sizeClass];
    }
}


- (TBTabBarControllerTabBarPosition)tb_preferredTabBarPositionForSizeClass:(UIUserInterfaceSizeClass)sizeClass  {
    
    if (sizeClass == UIUserInterfaceSizeClassRegular) {
        return TBTabBarControllerTabBarPositionLeft;
    }
    
    return TBTabBarControllerTabBarPositionBottom;
}


- (__kindof UIViewController *)tb_currentlyVisibleViewController {
    
    return _childNavigationController ? _childNavigationController.visibleViewController : self.selectedViewController;
}


- (void)tb_captureChildNavigationControllerIfExsists {
    
    // This solution was borrowed from TOTabBarController (https://github.com/TimOliver/TOTabBarController)
    
    UIViewController *viewController = self.selectedViewController;
    
    do {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            _childNavigationController = (UINavigationController *)viewController;
            break;
        }
    } while ((viewController = viewController.childViewControllers.firstObject));
}


- (void)tb_processChildrenOfViewControllersWithValue:(id)value {
    
    for (UIViewController *viewController in _viewControllers) {
        [self tb_processChildrenOfViewController:viewController withValue:value];
    }
}


- (void)tb_processChildrenOfViewController:(__kindof UIViewController *)viewController withValue:(id)value {
    
    for (__kindof UIViewController *childViewController in viewController.childViewControllers) {
        [self tb_processChildrenOfViewController:childViewController withValue:value];
    }
    
    [viewController setValue:value forKey:@"tb_tabBarController"];
}


- (void)tb_captureTabBarItems {
    
    self.items = [_viewControllers valueForKeyPath:@"@unionOfObjects.tb_tabBarItem"];
}


- (void)tb_getCurrentlyVisibleTabBar:(TBTabBar **)visibleTabBar hiddenTabBar:(TBTabBar **)hiddenTabBar {
    
    switch (tb_currentPosition) {
        case TBTabBarControllerTabBarPositionBottom:
            *visibleTabBar = self.bottomTabBar;
            *hiddenTabBar = self.leftTabBar;
            break;
        case TBTabBarControllerTabBarPositionLeft:
            *visibleTabBar = self.leftTabBar;
            *hiddenTabBar = self.bottomTabBar;
            break;
        default:
            break;
    }
}


#pragma mark Actions

- (void)tb_handlePopGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    if (_childNavigationController == nil || _childNavigationController.viewControllers.count < 2) {
        return;
    }
    
    [_childNavigationController popViewControllerAnimated:true];
}


#pragma mark Getters

- (TBTabBar *)bottomTabBar {
    
    if (_bottomTabBar == nil) {
        _bottomTabBar = [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
        _bottomTabBar.delegate = self;
        _bottomTabBar.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    return _bottomTabBar;
}


- (TBTabBar *)leftTabBar {
    
    if (_leftTabBar == nil) {
        _leftTabBar = [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationVertical];
        _leftTabBar.delegate = self;
    }
    
    return _leftTabBar;
}


- (TBFakeNavigationBar *)fakeNavigationBar {
    
    if (_fakeNavigationBar == nil) {
        _fakeNavigationBar = [[TBFakeNavigationBar alloc] init];
    }
    
    return _fakeNavigationBar;
}


- (UISwipeGestureRecognizer *)popGestureRecognizer {
    
    if (_popGestureRecognizer == nil) {
        _popGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tb_handlePopGestureRecognizer:)];
        _popGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    
    return _popGestureRecognizer;
}


#pragma mark Setters

- (void)setViewControllers:(NSArray <__kindof UIViewController *> *)viewControllers {
    
    if ([viewControllers isEqual:_viewControllers]) {
        return;
    }
    
    if (viewControllers.count == 0) {
        [self tb_stopObservingTabBarItems];
        [self tb_processChildrenOfViewControllersWithValue:nil];
        [self tb_removeChildViewControllerIfExists];
        self.items = nil;
        _viewControllers = nil;
        return;
    }
    
    if (_viewControllers.count > 0) {
        [self tb_stopObservingTabBarItems];
        [self tb_processChildrenOfViewControllersWithValue:nil];
    }
    
    _viewControllers = [viewControllers copy];
    
    [self tb_processChildrenOfViewControllersWithValue:self];
    [self tb_captureTabBarItems];
    [self tb_transitionToViewControllerAtIndex:self.startingIndex];
}


- (void)setSelectedViewController:(__kindof UIViewController *)visibleViewController {
    
    NSUInteger index = [self.viewControllers indexOfObject:visibleViewController];
    
    if (index == NSNotFound) {
        return;
    }
    
    self.selectedIndex = index;
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    
    if (selectedIndex == _selectedIndex || selectedIndex >= self.viewControllers.count) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    
    [self tb_transitionToViewControllerAtIndex:_selectedIndex];
}


- (void)setVerticalTabBarWidth:(CGFloat)verticalTabBarWidth {
    
    _verticalTabBarWidth = verticalTabBarWidth;
    
    _containerViewWidthConstraint.constant = _verticalTabBarWidth;
}


- (void)setHorizontalTabBarHeight:(CGFloat)horizontalTabBarHeight {
    
    _horizontalTabBarHeight = horizontalTabBarHeight;
    
    _bottomTabBarHeightConstraint.constant = _horizontalTabBarHeight;
}


- (void)setFakeNavigationBarHeight:(CGFloat)fakeNavigationBarHeight {
    
    _fakeNavigationBarHeight = fakeNavigationBarHeight;
    
    _fakeNavBarHeightConstraint.constant = _fakeNavigationBarHeight;
}


- (void)setItems:(NSArray <TBTabBarItem *> *)items {
    
    if ([items isEqual:_items]) {
        return;
    }
    
    _items = items;
    
    self.bottomTabBar.items = _items;
    self.leftTabBar.items = _items;
    
    [self tb_startObservingTabBarItems];
}


- (void)setDelegate:(id<TBTabBarControllerDelegate>)delegate {
    
    _delegate = delegate;
    
    tb_delegateFlags.shouldSelectViewController = [_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)];
    tb_delegateFlags.didSelectViewController = [_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)];
}

@end

#pragma mark -

@implementation UIViewController (TBTabBarControllerItem)

static char *tb_tabBarItemPropertyKey;
static char *tb_tabBarControllerPropertyKey;

#pragma mark - Private

#pragma mark Getters

- (TBTabBarItem *)tb_tabBarItem {
    
    TBTabBarItem *item = objc_getAssociatedObject(self, &tb_tabBarItemPropertyKey);
    
    if (item == nil) {
        item = [[TBTabBarItem alloc] init];
        objc_setAssociatedObject(self, &tb_tabBarItemPropertyKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return item;
}


- (TBTabBarController *)tb_tabBarController {
    
    return objc_getAssociatedObject(self, &tb_tabBarControllerPropertyKey);
}


#pragma mark Setters

- (void)setTb_tabBarItem:(TBTabBarItem * _Nonnull)tb_tabBarItem {
    
    objc_setAssociatedObject(self, &tb_tabBarItemPropertyKey, tb_tabBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setTb_tabBarController:(TBTabBarController * _Nullable)tb_tabBarController {
    
    objc_setAssociatedObject(self, &tb_tabBarControllerPropertyKey, tb_tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

@end
