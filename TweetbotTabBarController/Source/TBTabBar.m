//
//  TBTabBar.m
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

#import "TBTabBar.h"

#import "TBTabBar+Private.h"
#import "_TBTabBarButton.h"
#import "_TBDotLayer.h"

#import "TBUtils.h"

@interface TBTabBar()

@property (strong, nonatomic) NSArray <_TBTabBarButton *> *buttons;

@end

@implementation TBTabBar

@synthesize defaultTintColor = _defaultTintColor;
@synthesize dotsFillColor = _dotsFillColor;

#pragma mark - Public

- (instancetype)init {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self tb_commonInitWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self tb_commonInitWithLayoutOrientation:TBTabBarLayoutOrientationHorizontal];
    }
    
    return self;
}


- (instancetype)initWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self tb_commonInitWithLayoutOrientation:layoutOrientation];
    }
    
    return self;
}


#pragma mark UIViewHierarchy

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSUInteger const numberOfButtons = self.buttons.count;
    
    if (numberOfButtons == 0) {
        return;
    }
    
    CGRect const frame = self.frame;
    
    UIEdgeInsets const contentInsets = self.contentInsets;
    UIEdgeInsets const safeAreaInsets = self.safeAreaInsets;
    
    CGPoint const originPoint = (CGPoint){contentInsets.left + safeAreaInsets.left, contentInsets.top + safeAreaInsets.top};
    
    CGFloat const displayScale = self.traitCollection.displayScale;
    CGFloat const fNumberOfButtons = (CGFloat)numberOfButtons;
    CGFloat const spaceBetween = self.spaceBetweenTabs * (fNumberOfButtons - 1.0) / fNumberOfButtons;
    
    if (self.isVertical) {
        CGSize const size = (CGSize){TBFloorValueWithScale((CGRectGetWidth(frame) - contentInsets.left - contentInsets.right - safeAreaInsets.left), displayScale), TBFloorValueWithScale(((CGRectGetHeight(frame) - contentInsets.top - contentInsets.bottom) / fNumberOfButtons) - spaceBetween, displayScale)};
        [self tb_layoutVerticalWith:originPoint size:size];
    } else {
        CGSize const size = (CGSize){TBFloorValueWithScale(((CGRectGetWidth(frame) - contentInsets.left - contentInsets.right - safeAreaInsets.left - safeAreaInsets.right) / fNumberOfButtons) - spaceBetween, displayScale), TBFloorValueWithScale((CGRectGetHeight(frame) - contentInsets.top - contentInsets.bottom - safeAreaInsets.bottom), displayScale)};
        [self tb_layoutHorizontalWith:originPoint size:size];
    }
}


#pragma mark - Private

- (void)tb_commonInitWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation {
    
    _layoutOrientation = layoutOrientation;
    _contentInsets = UIEdgeInsetsZero;
    _vertical = (_layoutOrientation == TBTabBarLayoutOrientationVertical);
    
    self.separatorPosition = self.isVertical ? TBSimpleBarSeparatorPositionRight : TBSimpleBarSeparatorPositionTop;
    
    [self tb_setup];
}


- (void)tb_setup {
    
    self.backgroundColor = [UIColor whiteColor];
    self.spaceBetweenTabs = 4.0;
}


#pragma mark Layout

- (void)tb_layoutVerticalWith:(CGPoint)originPoint size:(CGSize)size {
    
    CGFloat offset = originPoint.y;
    
    for (_TBTabBarButton *button in self.buttons) {
        button.frame = (CGRect){(CGPoint){originPoint.x, offset}, size};
        offset += size.height + self.spaceBetweenTabs;
    }
}

- (void)tb_layoutHorizontalWith:(CGPoint)originPoint size:(CGSize)size {
    
    CGFloat offset = originPoint.x;
    
    for (_TBTabBarButton *button in self.buttons) {
        button.frame = (CGRect){(CGPoint){offset, originPoint.y}, size};
        offset += size.width + self.spaceBetweenTabs;
    }
}


#pragma mark Callbacks

- (void)tb_didSelectItem:(_TBTabBarButton *)button {
    
    if (self.delegate == nil) {
        return;
    }
    
    NSUInteger const buttonIndex = [self.buttons indexOfObject:button];
    
    if (buttonIndex != NSNotFound) {
        [self.delegate tabBar:self didSelectItem:self.items[buttonIndex]];
    }
}


#pragma mark Getters

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@, layoutOrientation: %@, selectedIndex: %lu, contentInsets: %@", [super description], (self.layoutOrientation == TBTabBarLayoutOrientationVertical ? @"vertical" : @"horizontal"), self.selectedIndex, NSStringFromUIEdgeInsets(self.contentInsets)];
}


- (UIColor *)defaultTintColor {
    
    if (_defaultTintColor == nil) {
        _defaultTintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
    
    return _defaultTintColor;
}


- (UIColor *)dotsFillColor {
    
    if (_dotsFillColor == nil) {
        _dotsFillColor = self.tintColor;
    }
    
    return _dotsFillColor;
}


#pragma mark Setters

- (void)setItems:(NSArray <TBTabBarItem *> *)items {
    
    if ([items isEqual:_items]) {
        return;
    }
    
    if (self.buttons.count > 0) {
        for (_TBTabBarButton *button in self.buttons) {
            [button removeFromSuperview];
        }
        self.buttons = nil;
    }
    
    _items = items;
    
    NSMutableArray <_TBTabBarButton *> *buttons = [NSMutableArray arrayWithCapacity:items.count];
    
    for (TBTabBarItem *item in _items) {
        
        _TBTabBarButton *button = [[_TBTabBarButton alloc] initWithTabBarItem:item];
        button.tintColor = self.defaultTintColor;
        button.dotLayer.fillColor = [self.dotsFillColor CGColor];
        button.laysOutHorizontally = self.isVertical;
        
        [button addTarget:self action:@selector(tb_didSelectItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        [buttons addObject:button];
    }
    
    self.buttons = [buttons copy];
    
    self.buttons[self.selectedIndex].tintColor = self.selectedTintColor;
}


- (void)setDefaultTintColor:(UIColor *)defaultTintColor {
    
    if (defaultTintColor != nil) {
        _defaultTintColor = defaultTintColor;
    } else {
        _defaultTintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
    
    for (_TBTabBarButton *button in self.buttons) {
        button.tintColor = _defaultTintColor;
    }
}


- (void)setDotsFillColor:(UIColor *)dotsFillColor {
    
    if (dotsFillColor != nil) {
        _dotsFillColor = dotsFillColor;
    } else {
        _dotsFillColor = self.tintColor;
    }
    
    for (_TBTabBarButton *button in self.buttons) {
        button.dotLayer.fillColor = [_dotsFillColor CGColor];
    }
}


- (void)setSelectedTintColor:(UIColor *)selectedTintColor {
    
    _selectedTintColor = selectedTintColor;
    
    self.buttons[self.selectedIndex].tintColor = _selectedTintColor;
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    
    self.buttons[_selectedIndex].tintColor = self.defaultTintColor;
    
    _selectedIndex = selectedIndex;
    
    self.buttons[_selectedIndex].tintColor = self.selectedTintColor;
}


- (void)setContentInsets:(UIEdgeInsets)insets {
    
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInsets, insets)) {
        return;
    }
    
    _contentInsets = insets;
}

@end
