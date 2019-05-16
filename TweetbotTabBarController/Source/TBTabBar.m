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
#import "TBDotLayer.h"

static const CGFloat _TBTabBarStackViewDefaultSpacing = 4.0;
static const CGFloat _TBTabBarDotLayerPresentationAnimationDuration = 0.25;
static const CGFloat _TBTabBarDotLayerDismissalAnimationDuration = 0.15;

static NSString *const _TBTabBarDotLayerAnimationKey = @"_TBTabBarDotLayerAnimationKey";

@interface TBTabBar()

@property (strong, nonatomic) NSArray <_TBTabBarButton *> *buttons;

/** Stack view with tab bar buttons */
@property (strong, nonatomic) UIStackView *stackView;

/** An array of constraints */
@property (strong, nonatomic) NSArray <NSLayoutConstraint *> *stackViewConstraints;

@end

@implementation TBTabBar {
    
    struct {
        unsigned int isTabBarCurrentlyVisible:1;
        unsigned int didSelectItem:1;
        unsigned int didSwitchItem:1;
        unsigned int shouldAnimateDot:1;
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


- (void)setDotLayer:(TBDotLayer *)dotLayer hidden:(BOOL)hidden animated:(BOOL)animated {
    
    if (self.dotLayerAnimationBlock != nil) {
        self.dotLayerAnimationBlock(dotLayer, hidden);
        return;
    }
    
    if (animated == false) {
        dotLayer.hidden = hidden;
        return;
    }
    
    // Begin transcation
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    // Common variables for different animations
    NSString *keyPath = nil;
    CGFloat dotLayerSize = 0.0;
    CGFloat dotLayerOriginalPos = 0.0;
    // Move a dot by its larger size
    if (self.isVertical == true) {
        keyPath = @"position.x";
        dotLayerSize = CGRectGetWidth(dotLayer.frame);
        dotLayerOriginalPos = dotLayer.position.x;
    } else {
        keyPath = @"position.y";
        dotLayerSize = CGRectGetHeight(dotLayer.frame);
        dotLayerOriginalPos = dotLayer.position.y;
    }
    // Animations
    __kindof CABasicAnimation *positionAnimation = nil;
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.fillMode = kCAFillModeForwards;
    // Deсide whether we should show or hide a dot
    if (hidden == false) {
        dotLayer.hidden = false;
        positionAnimation = [CASpringAnimation animationWithKeyPath:keyPath];
        ((CASpringAnimation *)positionAnimation).damping = 8.5;
        positionAnimation.fromValue = @(dotLayerOriginalPos + dotLayerSize);
        positionAnimation.byValue = @(-dotLayerSize);
        opacityAnimation.fromValue = @0.0;
        opacityAnimation.toValue = @1.0;
        groupAnimation.duration = _TBTabBarDotLayerPresentationAnimationDuration;
    } else {
        [CATransaction setCompletionBlock:^{
            dotLayer.hidden = true;
        }];
        positionAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
        positionAnimation.byValue = @(dotLayerSize);
        opacityAnimation.toValue = @0.0;
        groupAnimation.duration = _TBTabBarDotLayerDismissalAnimationDuration;
    }
    // Apply animations
    groupAnimation.animations = @[positionAnimation, opacityAnimation];
    [dotLayer addAnimation:groupAnimation forKey:_TBTabBarDotLayerAnimationKey];
    [CATransaction commit];
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
    _stackView.spacing = _TBTabBarStackViewDefaultSpacing;
    _stackView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addSubview:_stackView];
    
    // Constraints
    [self tb_setupConstraints];
}


- (void)tb_setDotHidden:(BOOL)hidden atTabIndex:(NSUInteger)index {
    
    TBDotLayer *dot = _buttons[index].dotLayer;
    
    if (dot.hidden == hidden) {
        return;
    }
    
    if ((tb_delegateFlags.isTabBarCurrentlyVisible && [_delegate isTabBarCurrentlyVisible:self]) == false) {
        dot.hidden = hidden;
        return;
    }
    
    BOOL animated = true;
    
    if (tb_delegateFlags.shouldAnimateDot) {
        animated = [_delegate tabBar:self shouldAnimateDotAtTabIndex:index];
    }
    
    [self setDotLayer:dot hidden:hidden animated:animated];
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
        NSUInteger const buttonIndex = [_buttons indexOfObject:button];
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
    
    _items = items;
    
    if (_buttons.count > 0) {
        for (_TBTabBarButton *button in _buttons) {
            [button removeFromSuperview];
        }
        _buttons = nil;
        if (items.count == 0 || items == nil) {
            return;
        }
    }
    
    NSMutableArray <_TBTabBarButton *> *buttons = [NSMutableArray arrayWithCapacity:_items.count];
    
    UIStackView *stackView = self.stackView;
    
    [_items enumerateObjectsUsingBlock:^(TBTabBarItem *_Nonnull item, NSUInteger index, BOOL * _Nonnull stop) {
        
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
    }];
    
    _buttons = [buttons copy];
    
    _buttons[self.selectedIndex].tintColor = self.selectedTintColor;
}


- (void)setDefaultTintColor:(UIColor *)defaultTintColor {
    
    if (defaultTintColor != nil) {
        _defaultTintColor = defaultTintColor;
    } else {
        _defaultTintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
    
    for (_TBTabBarButton *button in _buttons) {
        button.tintColor = _defaultTintColor;
    }
}


- (void)setDotsFillColor:(UIColor *)dotTintColor {
    
    if (dotTintColor != nil) {
        _dotsFillColor = dotTintColor;
    } else {
        _dotsFillColor = self.tintColor;
    }
    
    for (_TBTabBarButton *button in _buttons) {
        button.dotLayer.fillColor = [_dotsFillColor CGColor];
    }
}


- (void)setSelectedTintColor:(UIColor *)selectedTintColor {
    
    _selectedTintColor = selectedTintColor;
    
    _buttons[self.selectedIndex].tintColor = _selectedTintColor;
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    
    _TBTabBarButton *previouslySelectedButton = _buttons[_selectedIndex];
    previouslySelectedButton.tintColor = self.defaultTintColor;
    
    _selectedIndex = selectedIndex;
    
    _TBTabBarButton *selectedButton = _buttons[_selectedIndex];
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
    
    tb_delegateFlags.isTabBarCurrentlyVisible = [_delegate respondsToSelector:@selector(isTabBarCurrentlyVisible:)];
    tb_delegateFlags.didSelectItem = [_delegate respondsToSelector:@selector(tabBar:didSelectItem:)];
    tb_delegateFlags.didSwitchItem = [_delegate respondsToSelector:@selector(tabBar:didSwitchItem:toItem:)];
    tb_delegateFlags.shouldAnimateDot = [_delegate respondsToSelector:@selector(tabBar:shouldAnimateDotAtTabIndex:)];
}

@end
