//
//  TBTabBar.m
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


#import "TBTabBar.h"
#import "TBTabBar+Private.h"
#import "TBTabBarController.h"
#import "TBTabBarItem.h"
#import "TBTabBarButton.h"
#import "UIView+Extensions.h"
#import "TBTabBarItemsDifference.h"
#import "TBTabBarItemChange.h"
#import "_TBUtils.h"
#import "_TBStackView.h"
#import <objc/runtime.h>

@interface TBTabBar()

@property (strong, nonatomic) _TBStackView *stackView;
@property (assign, nonatomic) TBTabBarControllerTabBarPlacement currentPlacement;

@end

@implementation TBTabBar {

    TBTabBarLayoutOrientation _layoutOrientation;
}

@synthesize defaultTintColor = _defaultTintColor;
@synthesize notificationIndicatorTintColor = _notificationIndicatorTintColor;

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)init {

    self = [super initWithFrame:CGRectZero];

    if (self) {
        [self tbtbbr_commonInitWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (self) {
        [self tbtbbr_commonInitWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
        [self tbtbbr_setup];
    }

    return self;
}

- (instancetype)initWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation {

    self = [super initWithFrame:CGRectZero];

    if (self) {
        [self tbtbbr_commonInitWithLayoutOrientation:layoutOrientation];
        [self tbtbbr_setup];
    }

    return self;
}

+ (instancetype)horizontal {

    return [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
}

+ (instancetype)vertical {

    return [[TBTabBar alloc] initWithLayoutOrientation:TBTabBarLayoutOrientationVertical];
}

#pragma mark Interface

- (void)selectItem:(__kindof TBTabBarItem *)item {

    BOOL isHidden = false;

    NSUInteger itemIndexToSelect = [self.visibleItems indexOfObject:item];

    if (itemIndexToSelect == NSNotFound) {
        itemIndexToSelect = [self.hiddenItems indexOfObject:item];
        if (itemIndexToSelect == NSNotFound) {
            return;
        }
        isHidden = true;
    }

    if (_delegateFlags.shouldSelectItemAtIndex) {
        BOOL const shouldSelectItem = [self.delegate tabBar:self shouldSelectItem:item atIndex:itemIndexToSelect];
        if (shouldSelectItem == false) {
            return;
        }
    }

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;

    if (self.selectedIndex != NSNotFound) {
        NSUInteger const prevIndex = self.selectedIndex;
        buttons[prevIndex].tintColor = self.defaultTintColor;
        buttons[prevIndex].selected = false;
    }

    _selectedIndex = itemIndexToSelect;

    if (!isHidden) {
        TBTabBarButton *buttonToSelect = buttons[itemIndexToSelect];
        buttonToSelect.selected = true;
        buttonToSelect.tintColor = self.selectedTintColor;
    }

    if (_delegateFlags.didSelectItemAtIndex) {
        [self.delegate tabBar:self didSelectItem:item atIndex:itemIndexToSelect];
    }
}

- (nullable TBTabBarButton *)buttonAtTabIndex:(NSUInteger)tabIndex {

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;

    if (tabIndex >= buttons.count) {
        return nil;
    }

    return buttons[tabIndex];
}

#pragma mark Overrides

- (NSString *)description {

    return [NSString stringWithFormat:@"%@, items count: %lu, visible items count: %lu, selected index: %lu, layout orientation: %@", [super description], _itemsCount, self.visibleItems.count, self.selectedIndex, (self.isVertical ? @"vertical" : @"horizontal")];
}

- (void)layoutSubviews {

    [super layoutSubviews];

    UIEdgeInsets const safeAreaInsets = self.safeAreaInsets;
    UIEdgeInsets const contentInsets = self.contentInsets;
    UIEdgeInsets const additionalContentInsets = _additionalContentInsets;

    CGFloat const width = CGRectGetWidth(self.bounds);
    CGFloat const height = CGRectGetHeight(self.bounds);
    CGFloat const displayScale = self.tb_displayScale;

    // Stack view

    self.stackView.frame = _TBPixelAccurateRect((CGRect){
        (CGPoint){
            safeAreaInsets.left + contentInsets.left + additionalContentInsets.left,
            contentInsets.top + additionalContentInsets.top
        },
        (CGSize){
            width - safeAreaInsets.left - safeAreaInsets.right - contentInsets.left - contentInsets.right - additionalContentInsets.left - additionalContentInsets.right,
            height - safeAreaInsets.bottom - contentInsets.top - contentInsets.bottom - additionalContentInsets.top - additionalContentInsets.bottom
        }
    }, displayScale, true);
}

- (void)tintColorDidChange {

    [super tintColorDidChange];

    UIColor *const tintColor = self.tintColor;

    self.selectedTintColor = tintColor;
    self.notificationIndicatorTintColor = tintColor;
}

#pragma mark Private Methods

#pragma mark Setup

- (void)tbtbbr_commonInitWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation {

    _itemsCount = 0;
    _layoutOrientation = layoutOrientation;
    _visibleItems = [NSMutableArray array];
    _hiddenItems = [NSMutableArray array];
    _shouldSelectItem = true;
    _maxNumberOfVisibleTabs = 5;
    _vertical = (_layoutOrientation == TBTabBarLayoutOrientationVertical);

    self.separatorPosition = _vertical ?
        TBSimpleBarSeparatorPositionRight :
        TBSimpleBarSeparatorPositionTop;

    self.contentInsets = _vertical ?
        UIEdgeInsetsMake(2.0, 1.0, 2.0, 1.0) :
        UIEdgeInsetsMake(1.0, 2.0, 1.0, 2.0);
}

- (void)tbtbbr_setup {

    // View
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    // Stack view
    [self addSubview:self.stackView];
}

#pragma mark Actions

- (void)tbtbbr_willSelectButton:(TBTabBarButton *)button {

    if (_delegateFlags.shouldSelectItemAtIndex) {
        _shouldSelectItem = [self.delegate tabBar:self
                                 shouldSelectItem:button.tabBarItem
                                          atIndex:[self.stackView.subviews indexOfObject:button]];
    }
}

- (void)tbtbbr_didSelectButton:(TBTabBarButton *)button {

    if (_shouldSelectItem && _delegateFlags.didSelectItemAtIndex) {
        [self.delegate tabBar:self
                didSelectItem:button.tabBarItem
                      atIndex:[self.stackView.subviews indexOfObject:button]];
    }

    _shouldSelectItem = true;
}

#pragma mark Getters

- (NSArray<__kindof TBTabBarItem *> *)visibleItems {

    return [_visibleItems copy];
}

- (NSArray<__kindof TBTabBarItem *> *)hiddenItems {

    return [_hiddenItems copy];
}

- (_TBStackView *)stackView {

    if (_stackView == nil) {
        _stackView = [[_TBStackView alloc] initWithAxis:self.isVertical ? TBStackedTabsViewAxisVertical : TBStackedTabsViewAxisHorizontal];
        _stackView.spacing = 4.0;
    }

    return _stackView;
}

- (UIColor *)defaultTintColor {

    if (_defaultTintColor == nil) {
        _defaultTintColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    }

    return _defaultTintColor;
}

- (UIColor *)notificationIndicatorTintColor {

    if (_notificationIndicatorTintColor == nil) {
        _notificationIndicatorTintColor = self.tintColor;
    }

    return _notificationIndicatorTintColor;
}

- (CGFloat)spaceBetweenTabs {

    return self.stackView.spacing;
}

#pragma mark Setters

- (void)setItems:(NSArray <TBTabBarItem *> *)items {

    [self _setItems:items];
}

- (void)setDefaultTintColor:(UIColor *)defaultTintColor {

    if (defaultTintColor != nil) {
        _defaultTintColor = defaultTintColor;
    } else {
        _defaultTintColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    }

    NSUInteger const selectedIndex = self.selectedIndex;

    [self.stackView.subviews enumerateObjectsUsingBlock:^(TBTabBarButton *button, NSUInteger index, BOOL *stop) {
        if (index != selectedIndex) {
            button.tintColor = defaultTintColor;
        }
    }];
}

- (void)setSelectedTintColor:(UIColor *)selectedTintColor {

    if (selectedTintColor != nil) {
        _selectedTintColor = selectedTintColor;
    } else {
        _selectedTintColor = self.tintColor;
    }

    if (self.selectedIndex >= self.stackView.subviews.count) {
        return;
    }

    TBTabBarButton *buttonToSelect = self.stackView.subviews[self.selectedIndex];
    buttonToSelect.selected = true;
    buttonToSelect.tintColor = self.selectedTintColor;
}

- (void)setNotificationIndicatorTintColor:(UIColor *)notificationIndicatorTintColor {

    if (notificationIndicatorTintColor != nil) {
        _notificationIndicatorTintColor = notificationIndicatorTintColor;
    } else {
        _notificationIndicatorTintColor = self.tintColor;
    }

    for (TBTabBarButton *button in self.stackView.subviews) {
        button.notificationIndicatorView.tintColor = _notificationIndicatorTintColor;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {

    if (self.visibleItems.count == 0) {
        return [self _deselect];
    }

    NSUInteger const index = MIN(MAX(0, _itemsCount - 1), selectedIndex);

    __kindof TBTabBarItem *itemToSelect = self.visibleItems[index];

    if (_delegateFlags.shouldSelectItemAtIndex && ![self.delegate tabBar:self shouldSelectItem:itemToSelect atIndex:index]) {
        return;
    }

    if (_delegateFlags.didSelectItemAtIndex) {
        [self.delegate tabBar:self didSelectItem:self.visibleItems[index] atIndex:index];
    }
}

- (void)setMaxNumberOfVisibleTabs:(NSUInteger)maxNumberOfVisibleTabs {

    BOOL const shouldUpdateVisibleItems = _maxNumberOfVisibleTabs != maxNumberOfVisibleTabs;

    _maxNumberOfVisibleTabs = maxNumberOfVisibleTabs;

    if (shouldUpdateVisibleItems) {
        [self updateItems];
    }
}

- (void)setSpaceBetweenTabs:(CGFloat)spaceBetweenTabs {

    self.stackView.spacing = spaceBetweenTabs;

    [self setNeedsLayout];
}

- (void)setDelegate:(id <TBTabBarDelegate>)delegate {

    _delegate = delegate;

    _delegateFlags.shouldSelectItemAtIndex = [delegate respondsToSelector:@selector(tabBar:shouldSelectItem:atIndex:)];
    _delegateFlags.didSelectItemAtIndex = [delegate respondsToSelector:@selector(tabBar:didSelectItem:atIndex:)];
}

@end

#pragma mark Subclassing

@implementation TBTabBar (Subclassing)

- (void)updateItems {

    NSIndexSet *const visibleItemIndexes = [self visibleItemIndexes];

    NSAssert(visibleItemIndexes != nil, @"Visible item indexes of `%@` must not be nil", [self class]);

    NSArray<TBTabBarItem *> *items = self.items;

    if (items != nil && items.count > 0) {
        // Visible items
        NSArray *const newVisibleItems = [items objectsAtIndexes:visibleItemIndexes];
        TBTabBarItemsDifference *const visibleItemsDifference = [TBTabBarItemsDifference differenceWithItems:newVisibleItems from:_visibleItems];
        // Hidden items
        NSMutableIndexSet *const hiddenItemIndexes = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, _itemsCount)];
        [hiddenItemIndexes removeIndexes:visibleItemIndexes];
        NSArray *const newHiddenItems = [items objectsAtIndexes:hiddenItemIndexes];
        TBTabBarItemsDifference *const hiddenItemsDifference = [TBTabBarItemsDifference differenceWithItems:newHiddenItems from:_hiddenItems];
        // Apply differences
        [self applyVisibleItemsDifference:visibleItemsDifference];
        [self applyHiddenItemsDifference:hiddenItemsDifference];
    } else {
        // Visible items
        NSMutableArray<TBTabBarItemChange *> *visibleItemsChanges = [NSMutableArray array];
        [_visibleItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof TBTabBarItem * _Nonnull item, NSUInteger index, BOOL * _Nonnull stop) {
            [visibleItemsChanges addObject:[[TBTabBarItemChange alloc] initWithItem:item type:TBTabBarItemChangeRemove index:index]];
        }];
        // Hidden items
        NSMutableArray<TBTabBarItemChange *> *hiddenItemsChanges = [NSMutableArray array];
        [_hiddenItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof TBTabBarItem * _Nonnull item, NSUInteger index, BOOL * _Nonnull stop) {
            [hiddenItemsChanges addObject:[[TBTabBarItemChange alloc] initWithItem:item type:TBTabBarItemChangeRemove index:index]];
        }];
        // Apply differences
        [self applyVisibleItemsDifference:[[TBTabBarItemsDifference alloc] initWithChanges:[visibleItemsChanges copy]]];
        [self applyHiddenItemsDifference:[[TBTabBarItemsDifference alloc] initWithChanges:[hiddenItemsChanges copy]]];
    }
}

- (void)applyVisibleItemsDifference:(TBTabBarItemsDifference *)difference {

    if (difference.hasChanges == false) {
        return;
    }

    _TBStackView *stackView = self.stackView;
    NSArray<TBTabBarButton *> *buttons = stackView.subviews;

    NSMutableArray<TBTabBarButton *> *removedButtons = [NSMutableArray array];

    for (TBTabBarItemChange *change in difference) {
        if (change.type == TBTabBarItemChangeRemove) {
            TBTabBarButton *buttonToRemove = buttons[change.index];
            [removedButtons addObject:buttonToRemove];
            [buttonToRemove removeFromSuperview];
            [_visibleItems removeObjectAtIndex:change.index];
        } else {
            TBTabBarButton *buttonToInsert;
            if (removedButtons.count > 0) {
                NSUInteger const removedButtonIndex = [removedButtons indexOfObjectPassingTest:^BOOL(TBTabBarButton * _Nonnull button, NSUInteger index, BOOL * _Nonnull stop) {
                    if ([button.tabBarItem isEqual:change.item]) {
                        *stop = true;
                        return true;
                    }
                    return false;
                }];
                if (removedButtonIndex != NSNotFound) {
                    buttonToInsert = removedButtons[removedButtonIndex];
                    [removedButtons removeObjectAtIndex:removedButtonIndex];
                } else {
                    buttonToInsert = [self _makeButtonWithItem:change.item];
                }
            } else {
                buttonToInsert = [self _makeButtonWithItem:change.item];
            }
            [stackView insertSubview:buttonToInsert atIndex:change.index];
            [_visibleItems insertObject:change.item atIndex:change.index];
        }
    }

    [stackView setNeedsLayout];
    [self setNeedsLayout];
}

- (void)applyHiddenItemsDifference:(TBTabBarItemsDifference *)difference {

    if (difference.hasChanges == false) {
        return;
    }

    for (TBTabBarItemChange *change in difference) {
        switch (change.type) {
            case TBTabBarItemChangeRemove:
                [_hiddenItems removeObjectAtIndex:change.index];
                break;
            case TBTabBarItemChangeInsert:
                [_hiddenItems insertObject:change.item atIndex:change.index];
                break;
        }
    }
}

- (NSIndexSet *)visibleItemIndexes {

    NSUInteger const maxNumberOfVisibleTabs = self.maxNumberOfVisibleTabs;

    NSRange const range = NSMakeRange(0, maxNumberOfVisibleTabs == 0 ? _itemsCount : MIN(_itemsCount, maxNumberOfVisibleTabs));

    return [NSIndexSet indexSetWithIndexesInRange:range];
}

@end

#pragma mark Private Methods

@implementation TBTabBar (Private)

- (void)_setItems:(NSArray<__kindof TBTabBarItem *> *)items {

    BOOL const shouldNotifyDelegate =  (_items != nil && items != nil) ?
        ![_items isEqualToArray:items] :
        true;

    _items = items;

    if (items != nil) {
        _itemsCount = items.count;
    } else {
        _itemsCount = 0;
    }

    [self updateItems];

    if (shouldNotifyDelegate && _delegateFlags.didSelectItemAtIndex) {
        NSArray *visibleItems = self.visibleItems;
        if (visibleItems.count > 0) {
            NSUInteger const selectedIndex = self.selectedIndex;
            [self.delegate tabBar:self didSelectItem:visibleItems[selectedIndex] atIndex:selectedIndex];
        }
    }
}

- (void)_setSelectedIndex:(NSUInteger)selectedIndex quietly:(BOOL)quietly {

    NSUInteger const index = MIN(MAX(0, _itemsCount - 1), selectedIndex);

    __kindof TBTabBarItem *itemToSelect = self.visibleItems[index];

    if (quietly == false && _delegateFlags.shouldSelectItemAtIndex && ![self.delegate tabBar:self shouldSelectItem:itemToSelect atIndex:index]) {
        return;
    }

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;

    if (self.selectedIndex != NSNotFound) {
        NSUInteger const prevIndex = self.selectedIndex;
        buttons[prevIndex].tintColor = self.defaultTintColor;
        buttons[prevIndex].selected = false;
    }

    _selectedIndex = index;

    TBTabBarButton *buttonToSelect = buttons[index];
    buttonToSelect.selected = true;
    buttonToSelect.tintColor = self.selectedTintColor;

    if (quietly == false && _delegateFlags.didSelectItemAtIndex) {
        [self.delegate tabBar:self didSelectItem:self.visibleItems[index] atIndex:index];
    }
}

- (void)_deselect {

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;
    NSUInteger const prevIndex = self.selectedIndex;

    if (prevIndex != NSNotFound && buttons.count >= prevIndex + 1) {
        buttons[prevIndex].tintColor = self.defaultTintColor;
        buttons[prevIndex].selected = false;
    }

    _selectedIndex = NSNotFound;
}

- (void)_setNormalImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index {

    [self.stackView.subviews[index] setImage:image forState:UIControlStateNormal];
}

- (void)_setSelectedImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index {

    [self.stackView.subviews[index] setImage:image forState:UIControlStateSelected];
}

- (__kindof TBTabBarButton *)_makeButtonWithItem:(__kindof TBTabBarItem *)item {

    TBTabBarButtonLayoutOrientation orientation = self.isVertical ?
        TBTabBarButtonLayoutOrientationHorizontal :
        TBTabBarButtonLayoutOrientationVertical;

    TBTabBarButton *button = [[item.buttonClass alloc] initWithTabBarItem:item layoutOrientation: orientation];
    button.notificationIndicatorView.tintColor = self.notificationIndicatorTintColor;
    button.tintColor = self.defaultTintColor;
    button.autoresizingMask = UIViewAutoresizingNone;

    [button addTarget:self
               action:@selector(tbtbbr_willSelectButton:)
     forControlEvents:UIControlEventTouchDown];

    [button addTarget:self
               action:@selector(tbtbbr_didSelectButton:)
     forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (NSArray<__kindof TBTabBarButton *> *)_buttons {

    return self.stackView.subviews;
}

- (void)_addButton:(TBTabBarButton *)button {

    [self.stackView addSubview:button];
}

- (void)_insertButton:(TBTabBarButton *)button atIndex:(NSUInteger)index {

    [self.stackView insertSubview:button atIndex:index];
}

- (void)_setButtonEnabled:(BOOL)enabled atIndex:(NSUInteger)index {

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;

    buttons[index].enabled = enabled;
}

- (void)_setNotificationIndicatorImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index {

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;

    ((UIImageView *)buttons[index].notificationIndicatorView).image = image;
}

- (void)_setNotificationIndicatorHidden:(BOOL)hidden forButtonAtIndex:(NSUInteger)index {

    NSArray<TBTabBarButton *> *buttons = self.stackView.subviews;

    if (buttons.count <= index) {
        return;
    }

    [buttons[index] setNotificationIndicatorHidden:hidden animated:self.isVisible];
}

- (void)_setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets {

    if (UIEdgeInsetsEqualToEdgeInsets(_additionalContentInsets, additionalContentInsets)) {
        return;
    }

    _additionalContentInsets = additionalContentInsets;

    [self setNeedsLayout];
}

- (void)_setVisible:(BOOL)visible {

    _visible = visible;
}

- (void)_prepareForTransitionToPlacement:(TBTabBarControllerTabBarPlacement)preferredTabBarPlacement {

    if (self.isVertical) {
        switch (preferredTabBarPlacement) {
            case TBTabBarControllerTabBarPlacementLeading:
            case TBTabBarControllerTabBarPlacementTrailing:
                self.currentPlacement = preferredTabBarPlacement;

            default:
                break;
        }
    } else {
        switch (preferredTabBarPlacement) {
            case TBTabBarControllerTabBarPlacementBottom:
                self.currentPlacement = preferredTabBarPlacement;

            default:
                break;
        }
    }

    if (self.separatorPosition != TBSimpleBarSeparatorPositionHidden && self.isVertical) {
        switch (self.currentPlacement) {
            case TBTabBarControllerTabBarPlacementLeading:
                self.separatorPosition = TBSimpleBarSeparatorPositionRight;
                break;

            case TBTabBarControllerTabBarPlacementTrailing:
                self.separatorPosition = TBSimpleBarSeparatorPositionLeft;
                break;

            default:
                break;
        }
    }
}

@end
