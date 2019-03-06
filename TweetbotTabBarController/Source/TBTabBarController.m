//
//  TBTabBarController.m
//  TBTabBarController
//
//  Created by Timur Ganiev on 03/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

#import "TBTabBarController.h"

#import "TBTabBar+Private.h"
#import "TBTabBarButton.h"
#import "TBFakeNavigationBar.h"

#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, TBTabBarControllerMethodOverrides) {
    TBTabBarControllerMethodOverrideNone = 0,
    TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass = 1 << 0,
    TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize = 1 << 1
};

@interface TBTabBarController ()

@property (strong, nonatomic, readwrite) TBTabBar *leftTabBar;
@property (strong, nonatomic, readwrite) TBTabBar *bottomTabBar;
@property (weak, nonatomic, readwrite) TBTabBar *visibleTabBar;
@property (weak, nonatomic, readwrite) TBTabBar *hiddenTabBar;

@property (strong, nonatomic) UIStackView *containerView; // contains the fake nav bar and the left tab bar

@property (strong, nonatomic) TBFakeNavigationBar *fakeNavigationBar;

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
    
    BOOL tb_needsLayout;
    TBTabBarControllerTabBarPosition tb_preferredPosition;
    // Erm, these variables are used to remove empty spaces when the device is rotated
    CGFloat tb_previousVerticalTabBarBottomInset;
    CGFloat tb_preferredVerticalTabBarBottomInset;
}

static void *tb_tabBarItemImageContext = &tb_tabBarItemImageContext;
static void *tb_tabBarItemSelectedImageContext = &tb_tabBarItemSelectedImageContext;
static void *tb_tabBarItemEnabledContext = &tb_tabBarItemEnabledContext;

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
        
        if ([self tb_doesSubclassOverrideMethod:@selector(preferredTabBarPositionForHorizontalSizeClass:)]) {
            tb_methodOverridesFlags |= TBTabBarControllerMethodOverridePreferredTabBarPositionForHorizontalSizeClass;
        }
        if ([self tb_doesSubclassOverrideMethod:@selector(preferredTabBarPositionForViewSize:)]) {
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
    
    if (tb_needsLayout == true) {
        [self tb_updateViewConstraints:tb_preferredPosition];
        [self tb_updateFakeNavigationBarHeightConstraint];
        // When the device is rotated, a black empty space appears
        [self tb_updateVerticalTabBarBottomContentInset];
        // An unspecified position means that the trait collection has not been changed, so we have to rely on the current one
        tb_preferredPosition = TBTabBarControllerTabBarPositionUnspecified;
        // Preparing for the next layout cycle
        tb_needsLayout = false;
    }
}


#pragma mark Status bar 

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return [self tb_getCurrentlyVisibleViewController].preferredStatusBarStyle;
}


- (BOOL)prefersStatusBarHidden {
    
    return [self tb_getCurrentlyVisibleViewController].prefersStatusBarHidden;
}


- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return [self tb_getCurrentlyVisibleViewController].preferredStatusBarUpdateAnimation;
}


#pragma mark UIViewControllerRotation

- (BOOL)shouldAutorotate {
    
    return [self tb_getCurrentlyVisibleViewController].shouldAutorotate;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return [self tb_getCurrentlyVisibleViewController].supportedInterfaceOrientations;
}



#pragma mark Subclasses

- (TBTabBarControllerTabBarPosition)preferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass {
    
    return [self tb_preferredTabBarPositionForHorizontalSizeClass:sizeClass];
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
            [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNeeded:newHorizontalSizeClass]; // Subclasses may return an unspecified position
            [self tb_updateTabBarsVisibilityWithTransitionCoordinator:coordinator];
        } else {
            // In case where a subclass overrides the -preferredTabBarPositionForViewSize: method, we should capture a new preferred position for a new horizontal size class since a subclass may return either an unspecified position or call super.
            tb_preferredPosition = [self tb_preferredTabBarPositionForHorizontalSizeClass:newHorizontalSizeClass];
        }
    }
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    // The horizontal size class doesn't change every time.
    // When the user rotates an iPad the view has the same horizontal size class, but its size will be changed.
    // The same happens when the user switches between 2/3 and 1/2 split screen modes.
    // Subclasses can rely on this change and show the tab bar on the other side.
    
    if (tb_methodOverridesFlags & TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize) {
        
        // UIKit calls this method even if the view size has not been changed
        if (CGSizeEqualToSize(self.view.frame.size, size) == false) {
            
            // By default the preferredTabBarPositionForViewSize: method returns tb_preferredPosition property, so we have to capture it before a subclass will call super
            // An unspecified position means that trait collection has not been changed in a while
            [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNeeded:self.traitCollection.horizontalSizeClass]; 
            
            TBTabBarControllerTabBarPosition preferredPosition = [self preferredTabBarPositionForViewSize:size];
            
            if (preferredPosition == TBTabBarControllerTabBarPositionUnspecified) {
                // Subclasses may return an unspecified position
                preferredPosition = tb_preferredPosition;
            } else if (preferredPosition != tb_preferredPosition) {
                // Capturing a new preferred position for the layout cycle
                tb_preferredPosition = preferredPosition;
            }
            
            [self tb_updateTabBarsVisibilityWithTransitionCoordinator:coordinator];
        }
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (previousTraitCollection == nil) {
        UIUserInterfaceSizeClass const horizontalSizeClass = self.traitCollection.horizontalSizeClass;
        // Capture a preferred position
        if (tb_methodOverridesFlags & TBTabBarControllerMethodOverridePreferredTabBarPositionForViewSize) {
            tb_preferredPosition = [self preferredTabBarPositionForViewSize:self.view.frame.size];
        } else {
            tb_preferredPosition = [self preferredTabBarPositionForHorizontalSizeClass:horizontalSizeClass];
        }
        [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNeeded:horizontalSizeClass];
        // Get a visible tab bar for a preferred position
        [self tb_updateTabBarsVisiblility];
    }
    
    [super traitCollectionDidChange:previousTraitCollection];
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary <NSKeyValueChangeKey, id> *)change context:(void *)context {
    
    NSUInteger const itemIndex = [self.visibleTabBar.items indexOfObject:object];
    
    if (itemIndex == NSNotFound) {
        return;
    }
    
    TBTabBarButton *bottomTabBarButtonAtIndex = self.bottomTabBar.buttons[itemIndex];
    TBTabBarButton *leftTabBarButtonAtIndex = self.leftTabBar.buttons[itemIndex];
    
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
    }
}


#pragma mark TBTabBarDelegate

- (void)tabBar:(TBTabBar *)tabBar didSelectItem:(TBTabBarItem *)item {
    
    NSUInteger const itemIndex = [_items indexOfObject:item];
    
    BOOL shouldSelectViewController = (itemIndex == self.selectedIndex) ? false : true;
    
    __kindof UIViewController *childViewController = self.viewControllers[itemIndex];
    
    id <TBTabBarControllerDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        shouldSelectViewController = [delegate tabBarController:self shouldSelectViewController:childViewController];
    }
    
    if (shouldSelectViewController == false) {
        return;
    }
    
    self.selectedIndex = itemIndex;
    
    if ([delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [delegate tabBarController:self didSelectViewController:childViewController];
    }
}


#pragma mark - Private

- (void)tb_commonInit {
    
    // UINavigationBar
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]].translucent = false;
    
    // Public
    self.startingIndex = 0;
    self.horizontalTabBarHeight = 49.0;
    self.verticalTabBarWidth = 60.0;
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
    
    // Constraints
    [self tb_setupConstraints];
    
    tb_needsLayout = true;
}


#pragma mark Layout

- (void)tb_setupConstraints {
    
    // Container view
    _containerViewLeftConstraint = [self.containerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
    NSLayoutConstraint *containerViewTopConstraint = [self.containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor];
    _containerViewBottomConstraint = [self.containerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.horizontalTabBarHeight];
    _containerViewWidthConstraint = [self.containerView.widthAnchor constraintEqualToConstant:self.verticalTabBarWidth];
    
    // Fake navingation bar
    NSLayoutConstraint *fakeNavBarWidthConstraint = [self.fakeNavigationBar.widthAnchor constraintEqualToAnchor:self.containerView.widthAnchor];
    _fakeNavBarHeightConstraint = [self.fakeNavigationBar.heightAnchor constraintEqualToConstant:40.0];
    
    // Left tab bar
    NSLayoutConstraint *leftTabBarWidthConstraint = [self.leftTabBar.widthAnchor constraintEqualToAnchor:self.containerView.widthAnchor];
    
    // Bottom tab bar
    NSLayoutConstraint *bottomTabBarLeftConstraint = [self.bottomTabBar.leftAnchor constraintEqualToAnchor:self.containerView.rightAnchor];
    NSLayoutConstraint *bottomTabBarRightConstraint = [self.bottomTabBar.rightAnchor constraintEqualToAnchor:self.view.rightAnchor];
    _bottomTabBarBottomConstraint = [self.bottomTabBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    _bottomTabBarHeightConstraint = [self.bottomTabBar.heightAnchor constraintEqualToConstant:self.horizontalTabBarHeight];
    
    // Activation
    [NSLayoutConstraint activateConstraints:@[_containerViewLeftConstraint, containerViewTopConstraint, _containerViewBottomConstraint, _containerViewWidthConstraint, fakeNavBarWidthConstraint, _fakeNavBarHeightConstraint, leftTabBarWidthConstraint, bottomTabBarLeftConstraint, bottomTabBarRightConstraint, _bottomTabBarBottomConstraint, _bottomTabBarHeightConstraint]];
}


- (void)tb_updateViewConstraints:(TBTabBarControllerTabBarPosition)layoutOrientation {
    
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    
    _bottomTabBarHeightConstraint.constant = self.horizontalTabBarHeight + safeAreaInsets.bottom + self.bottomTabBar.contentInsets.top + self.bottomTabBar.contentInsets.bottom;
    _containerViewWidthConstraint.constant = self.verticalTabBarWidth + safeAreaInsets.left + self.leftTabBar.contentInsets.left + self.leftTabBar.contentInsets.right;
    
    if (layoutOrientation == TBTabBarLayoutOrientationVertical) {
        _bottomTabBarBottomConstraint.constant = _bottomTabBarHeightConstraint.constant;
        _containerViewLeftConstraint.constant = 0.0;
    } else {
        _bottomTabBarBottomConstraint.constant = 0.0;
        _containerViewLeftConstraint.constant = -_containerViewWidthConstraint.constant;
    }
    
    tb_previousVerticalTabBarBottomInset = self.leftTabBar.contentInsets.bottom;
    tb_preferredVerticalTabBarBottomInset = _bottomTabBarBottomConstraint.constant;
}


- (void)tb_updateFakeNavigationBarHeightConstraint {
    
    _fakeNavBarHeightConstraint.constant = CGRectGetMaxY(_childNavigationController.navigationBar.frame) + (1.0 / self.traitCollection.displayScale);
}


- (void)tb_updateVerticalTabBarBottomContentInset {
    
    TBTabBar *tabBar = self.leftTabBar;
    UIEdgeInsets tabBarContentInsets = tabBar.contentInsets;
    CGFloat containerViewBottomInset = 0.0;
    
    if (tabBarContentInsets.bottom != tb_previousVerticalTabBarBottomInset) {
        containerViewBottomInset = 0.0;
        tabBarContentInsets.bottom = tb_previousVerticalTabBarBottomInset;
    } else {
        containerViewBottomInset = tb_preferredVerticalTabBarBottomInset;
        tabBarContentInsets.bottom = -tb_preferredVerticalTabBarBottomInset;
    }
    
    // Covering an empty space by stretching the container view...
    _containerViewBottomConstraint.constant = containerViewBottomInset;
    // ... and make a tab bar look like it's ok
    tabBar.contentInsets = tabBarContentInsets;
}


- (void)tb_updateTabBarsVisibilityWithTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    if ((self.visibleTabBar.layoutOrientation == TBTabBarLayoutOrientationHorizontal) && (tb_preferredPosition == TBTabBarControllerTabBarPositionBottom)) {
        // Do nothing when a new preferred positions equals to the current one
        return;
    }
    
    tb_needsLayout = true;
    
    TBTabBar *visibleTabBar, *hiddenTabBar;
    
    [self tb_getCurrentlyVisibleTabBar:&visibleTabBar andHiddenTabBar:&hiddenTabBar];
    
    // Showing the currently hidden tab bar
    [self tb_makeTabBarVisibile:visibleTabBar];
    
    __weak typeof(self) weakSelf = self;
    
    [coordinator animateAlongsideTransition:nil completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        // Getting everything back the way it was
        [weakSelf tb_updateVerticalTabBarBottomContentInset];
        // Hiding the previously visible tab bar when the transition is complete
        [weakSelf tb_makeTabBarHidden:hiddenTabBar];
    }];
}


- (void)tb_updateTabBarsVisiblility {
    
    TBTabBar *visibleTabBar, *hiddenTabBar;
    
    [self tb_getCurrentlyVisibleTabBar:&visibleTabBar andHiddenTabBar:&hiddenTabBar];
    
    [self tb_makeTabBarVisibile:visibleTabBar];
    [self tb_makeTabBarHidden:hiddenTabBar];
}


- (void)tb_makeTabBarVisibile:(TBTabBar *)tabBar {
    
    _visibleTabBar = tabBar;
    
    if (_visibleTabBar.layoutOrientation == TBTabBarLayoutOrientationVertical) {
        self.containerView.hidden = false;
        self.selectedViewController.additionalSafeAreaInsets = UIEdgeInsetsZero;
    } else {
        _visibleTabBar.hidden = false;
        self.selectedViewController.additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, self.horizontalTabBarHeight, 0.0);
    }
}


- (void)tb_makeTabBarHidden:(TBTabBar *)tabBar {
    
    _hiddenTabBar = tabBar;
    
    if (_hiddenTabBar.layoutOrientation == TBTabBarLayoutOrientationVertical) {
        self.containerView.hidden = true;
    } else {
        _hiddenTabBar.hidden = true;
    }
}


#pragma mark Transitions

- (void)tb_transitionToViewControllerAtIndex:(NSUInteger)index {
    
    NSArray <__kindof UIViewController *> *const children = self.viewControllers;
    
    if (index > children.count) {
        index = children.count - 1;
    }
    
    // Show a new view controller
    [self tb_removeChildViewControllerIfExists];
    [self tb_presentChildViewController:children[index]];
    [self tb_captureChildNavigationControllerIfExsists];
    
    // Update tab bars
    self.bottomTabBar.selectedIndex = index;
    self.leftTabBar.selectedIndex = index;
    
    // Layout everything
    tb_needsLayout = true;
    
    if (self.visibleTabBar == nil) {
        [self tb_specifyPreferredPositionWithHorizontalSizeClassIfNeeded:self.traitCollection.horizontalSizeClass];
    } else if (tb_preferredPosition == TBTabBarControllerTabBarPositionUnspecified) {
        tb_preferredPosition = (self.visibleTabBar.layoutOrientation == TBTabBarLayoutOrientationHorizontal) ? TBTabBarControllerTabBarPositionBottom : TBTabBarControllerTabBarPositionLeft;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)tb_presentChildViewController:(__kindof UIViewController *)viewController {
    
    _selectedViewController = viewController;
    
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    [self.view sendSubviewToBack:viewController.view];
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = false;
    
    [viewController.view.leftAnchor constraintEqualToAnchor:_containerView.rightAnchor].active = true;
    [viewController.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = true;
    [viewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = true;
    [viewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = true;
}


- (void)tb_removeChildViewControllerIfExists {
    
    if (self.selectedViewController == nil) {
        return;
    }
    
    [NSLayoutConstraint deactivateConstraints:self.selectedViewController.view.constraints];
    
    [self.selectedViewController willMoveToParentViewController:nil];
    [self.selectedViewController removeFromParentViewController];
    [self.selectedViewController.view removeFromSuperview];
    [self.selectedViewController didMoveToParentViewController:nil];
    
    _selectedViewController = nil;
    _childNavigationController = nil;
}


- (void)tb_captureChildNavigationControllerIfExsists {
    
    // This method was borrowed from TOTabBarController
    // https://github.com/TimOliver/TOTabBarController
    
    UIViewController *viewController = self.selectedViewController;
    
    do {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            _childNavigationController = (UINavigationController *)viewController;
            break;
        }
    } while ((viewController = viewController.childViewControllers.firstObject));
}


#pragma mark Observing

- (void)tb_startObservingTabBarItems {
    
    for (TBTabBarItem *item in _items) {
        [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:tb_tabBarItemImageContext];
        [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:tb_tabBarItemSelectedImageContext];
        [item addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:tb_tabBarItemEnabledContext];
    }
}

- (void)tb_stopObservingTabBarItems {
    
    for (TBTabBarItem *item in _items) {
        [item removeObserver:self forKeyPath:@"image" context:tb_tabBarItemImageContext];
        [item removeObserver:self forKeyPath:@"selectedImage" context:tb_tabBarItemSelectedImageContext];
        [item removeObserver:self forKeyPath:@"enabled" context:tb_tabBarItemEnabledContext];
    }
}


#pragma mark Utils

+ (BOOL)tb_doesSubclassOverrideMethod:(SEL)selector {
    
    Method superclassMethod = class_getInstanceMethod([TBTabBarController class], selector);
    Method subclassMethod = class_getInstanceMethod(self, selector);
    
    return superclassMethod != subclassMethod;
}


- (void)tb_specifyPreferredPositionWithHorizontalSizeClassIfNeeded:(UIUserInterfaceSizeClass)sizeClass {
    
    if (tb_preferredPosition == TBTabBarControllerTabBarPositionUnspecified) {
        tb_preferredPosition = [self tb_preferredTabBarPositionForHorizontalSizeClass:sizeClass];
    }
}


- (TBTabBarControllerTabBarPosition)tb_preferredTabBarPositionForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass  {
    
    if (sizeClass == UIUserInterfaceSizeClassRegular) {
        return TBTabBarControllerTabBarPositionLeft;
    }
    
    return TBTabBarControllerTabBarPositionBottom;
}


- (__kindof UIViewController *)tb_getCurrentlyVisibleViewController {
    
    return _childNavigationController ? _childNavigationController.visibleViewController : self.selectedViewController;
}


- (void)tb_getCurrentlyVisibleTabBar:(TBTabBar **)visibleTabBar andHiddenTabBar:(TBTabBar **)hiddenTabBar {
    
    // Yeah, it doesn't actually return CURRENTLY visible or hidden tab bars.
    // Instead, it returns bars for the current preferred position.
    
    if (tb_preferredPosition == TBTabBarControllerTabBarPositionBottom) {
        *visibleTabBar = self.bottomTabBar;
        *hiddenTabBar = self.leftTabBar;
    } else {
        *hiddenTabBar = self.bottomTabBar;
        *visibleTabBar = self.leftTabBar;
    }
}


#pragma mark Getters

- (TBTabBar *)bottomTabBar {
    
    if (!_bottomTabBar) {
        _bottomTabBar = [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
        _bottomTabBar.delegate = self;
        _bottomTabBar.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    return _bottomTabBar;
}


- (TBTabBar *)leftTabBar {
    
    if (!_leftTabBar) {
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


#pragma mark Setters

- (void)setViewControllers:(NSArray <__kindof UIViewController *> *)viewControllers {
    
    NSAssert(viewControllers.count <= 5, @"Bad ...");
    
    if ([viewControllers isEqual:_viewControllers]) {
        return;
    }
    
    if (_viewControllers.count > 0) {
        [self tb_stopObservingTabBarItems]; // Should we do this here?
    }
    
    _viewControllers = [viewControllers copy];
    
    self.items = [_viewControllers valueForKeyPath:@"@unionOfObjects.tb_tabBarItem"];
    
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
    
    if (selectedIndex >= self.viewControllers.count) {
        selectedIndex = 0;
    }
    
    if (selectedIndex == _selectedIndex) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    
    [self tb_transitionToViewControllerAtIndex:selectedIndex];
}


- (void)setItems:(NSArray <TBTabBarItem *> *)items {
    
    if ([items isEqual:_items]) {
        return;
    }
    
    _items = items;
    
    self.bottomTabBar.items = items;
    self.leftTabBar.items = items;
    
    [self tb_startObservingTabBarItems];
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
    
    objc_setAssociatedObject(self, &tb_tabBarControllerPropertyKey, tb_tabBarController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
