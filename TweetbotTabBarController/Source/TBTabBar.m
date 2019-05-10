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

@interface TBTabBar()

@property (strong, nonatomic) NSArray <_TBTabBarButton *> *buttons;

/** Stack view with tab bar buttons */
@property (strong, nonatomic) UIStackView *stackView;

/** An array of constraints */
@property (strong, nonatomic) NSArray <NSLayoutConstraint *> *stackViewConstraints;

@end

@implementation TBTabBar {
    
    struct {
        unsigned int didSelectItem:1;
        unsigned int shouldChangeItem:1;
        unsigned int didChangeItem:1;
    } tb_delegateFlags;
}

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


#pragma mark - Private

- (void)tb_commonInitWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation {
    
    _layoutOrientation = layoutOrientation;
    _contentInsets = UIEdgeInsetsZero;
    _vertical = (_layoutOrientation == TBTabBarLayoutOrientationVertical);
    
    self.separatorPosition = self.isVertical ? TBSimpleBarSeparatorPositionRight : TBSimpleBarSeparatorPositionTop;
    
    [self tb_setup];
}


- (void)tb_setup {
    
    // View
    self.backgroundColor = [UIColor whiteColor];
    
    // Stack view
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.axis = self.isVertical ? UILayoutConstraintAxisVertical : UILayoutConstraintAxisHorizontal;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionFillEqually;
    _stackView.spacing = 4.0;
    _stackView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addSubview:_stackView];
    
    // Constraints
    [self tb_setupConstraints];
}


#pragma mark Layout

- (void)tb_setupConstraints {
    
    UILayoutGuide *layoutGuide = self.safeAreaLayoutGuide;
    
    NSLayoutYAxisAnchor *bottomAnchor = self.isVertical ? self.bottomAnchor : layoutGuide.bottomAnchor; // Horizontal tab bar has to play cool with safe area
    
    UIStackView *stackView = self.stackView;
    
    UIEdgeInsets contentInsets = self.contentInsets;
    
    _stackViewConstraints = @[[stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:contentInsets.top], [stackView.leftAnchor constraintEqualToAnchor:layoutGuide.leftAnchor constant:contentInsets.left], [stackView.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:contentInsets.bottom], [stackView.rightAnchor constraintEqualToAnchor:layoutGuide.rightAnchor constant:contentInsets.right]]; // Capture stack view's constraints to update them later
    
    [NSLayoutConstraint activateConstraints:_stackViewConstraints];
}


#pragma mark Callbacks

- (void)tb_didSelectItem:(_TBTabBarButton *)button {
    
    if (tb_delegateFlags.didSelectItem) {
        NSUInteger const buttonIndex = [self.buttons indexOfObject:button];
        if (buttonIndex != NSNotFound) {
            [self.delegate tabBar:self didSelectItem:self.items[buttonIndex]];
        }
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


- (CGFloat)spaceBetweenTabs {
    
    return _stackView.spacing;
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
    
    UIStackView *stackView = self.stackView;
    
    for (TBTabBarItem *item in _items) {
        
        _TBTabBarButton *button = [[_TBTabBarButton alloc] initWithTabBarItem:item];
        button.tintColor = self.defaultTintColor;
        button.dotLayer.fillColor = [self.dotsFillColor CGColor];
        button.laysOutHorizontally = self.isVertical;
        
        [button addTarget:self action:@selector(tb_didSelectItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [stackView addArrangedSubview:button];
        
        if (self.isVertical == false) {
            [button.heightAnchor constraintEqualToAnchor:stackView.heightAnchor].active = true;
        } else {
            [button.widthAnchor constraintEqualToAnchor:stackView.widthAnchor].active = true;
        }
        
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


- (void)setDotsFillColor:(UIColor *)dotTintColor {
    
    if (dotTintColor != nil) {
        _dotsFillColor = dotTintColor;
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
    
    _TBTabBarButton *previouslySelectedButton = self.buttons[_selectedIndex];
    previouslySelectedButton.tintColor = self.defaultTintColor;
    
    _selectedIndex = selectedIndex;
    
    _TBTabBarButton *selectedButton = self.buttons[_selectedIndex];
    selectedButton.tintColor = self.selectedTintColor;
}


- (void)setContentInsets:(UIEdgeInsets)insets {
    
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInsets, insets)) {
        return;
    }
    
    _contentInsets = insets;
    
    [_stackViewConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull constraint, NSUInteger index, BOOL *_Nonnull stop) {
        
        switch (index) {
            case 0:
                constraint.constant = insets.top;
                break;
            case 1:
                constraint.constant = insets.left;
                break;
            case 2:
                constraint.constant = insets.bottom;
                break;
            case 3:
                constraint.constant = insets.right;
                break;
            default:
                break;
        }
    }];
}


- (void)setSpaceBetweenTabs:(CGFloat)spaceBetweenTabs {
    
    _stackView.spacing = spaceBetweenTabs;
}


- (void)setDelegate:(id <TBTabBarDelegate>)delegate {
    
    _delegate = delegate;
    
    tb_delegateFlags.didSelectItem = [_delegate respondsToSelector:@selector(tabBar:didSelectItem:)];
    tb_delegateFlags.shouldChangeItem = [_delegate respondsToSelector:@selector(tabBar:shouldChangeItem:)];
    tb_delegateFlags.didChangeItem = [_delegate respondsToSelector:@selector(tabBar:didChangeItem:toItem:)];
}

@end
