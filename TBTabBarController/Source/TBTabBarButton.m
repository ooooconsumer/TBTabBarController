//
//  TBTabBarButton.m
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

#import "TBTabBarButton.h"
#import "TBTabBarItem.h"
#import "_TBUtils.h"
#import "UIView+Extensions.h"

static const CGFloat _TBTabBarButtonNotificationIndicatorSize = 5.0;
static const CGFloat _TBTabBarButtonNotificationIndicatorPresentationAnimationDuration = 0.25;
static const CGFloat _TBTabBarButtonNotificationIndicatorDismissalAnimationDuration = 0.25;

static NSString *const _TBTabBarButtonNotificationIndicatorAnimationKey = @"_TBTabBarButtonNotificationIndicatorAnimationKey";

typedef NS_ENUM(NSUInteger, _TBTabBarButtonNotificationIndicatorViewAnimationState) {
    _TBTabBarButtonNotificationIndicatorViewAnimationStateNone,
    _TBTabBarButtonNotificationIndicatorViewAnimationStateShow,
    _TBTabBarButtonNotificationIndicatorViewAnimationStateHide
};

@interface TBTabBarButton ()

@property (strong, nonatomic, readwrite) TBTabBarItem *tabBarItem;

@end

@implementation TBTabBarButton {
    
    BOOL _laysOutHorizontally;
    BOOL _needsLayout;

    _TBTabBarButtonNotificationIndicatorViewAnimationState _notificationIndicatorViewAnimationState; // This ivar is used for logic that ensures that indicator view wasn't removed from the button when it's not necessary
    
    UIImage *_normalImage;
    UIImage *_highlightedImage;
    UIImage *_disabledImage;
    UIImage *_selectedImage;
    UIImage *_highlightedAndSelectedImage;
}

@synthesize imageView = _imageView;
@synthesize notificationIndicatorView = _notificationIndicatorView;

#pragma mark Lifecycle

- (instancetype)initWithTabBarItem:(TBTabBarItem *)tabBarItem layoutOrientation:(TBTabBarButtonLayoutOrientation)layoutOrientation {
    
    if (self = [super initWithFrame:CGRectZero]) {
        _laysOutHorizontally = layoutOrientation == TBTabBarButtonLayoutOrientationHorizontal;
        [self _commonInitWithTabBarItem:tabBarItem];
        [self _setup];
    }
    
    return self;
}

#pragma mark Public Methods

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    
    switch (state) {
        case UIControlStateNormal:
            _normalImage = image;
            break;
        case UIControlStateHighlighted:
            _highlightedImage = image;
            break;
        case UIControlStateDisabled:
            _disabledImage = image;
            break;
        case UIControlStateSelected:
            _selectedImage = image;
            break;
        case UIControlStateHighlighted | UIControlStateSelected:
            _highlightedAndSelectedImage = image;
            break;
        default:
            break;
    }
    
    [self _updateImage];
}

- (void)setNotificationIndicatorHidden:(BOOL)hidden animated:(BOOL)animated {
    
    BOOL const isNotificationIndicatorVisible = !hidden;
    
    UIView *notificationIndicatorView = self.notificationIndicatorView;
    
    if (isNotificationIndicatorVisible) {
        if (notificationIndicatorView.superview == nil) {
            [self addSubview:notificationIndicatorView];
        }
        // We need to layout the notification indicator view before animation otherwise it will be glitchy
        // There is no reason to layout whole button when the indicator is hidden before the update
        [self _setNeedsLayout];
        [self layoutIfNeeded];
    }
    
    _notificationIndicatorVisible = isNotificationIndicatorVisible;
    
    if (isNotificationIndicatorVisible) {
        void (^animations)(void) = ^(void) {
            [self layoutIfNeeded];
            notificationIndicatorView.alpha = 1.0;
        };
        if (animated == false) {
            [self setNeedsLayout];
            animations();
        } else {
            notificationIndicatorView.alpha = 0.0;
            [self setNeedsLayout];
            void (^completion)(BOOL) = ^(BOOL finished) {
                if (self->_notificationIndicatorViewAnimationState == _TBTabBarButtonNotificationIndicatorViewAnimationStateShow) {
                    self->_notificationIndicatorViewAnimationState = _TBTabBarButtonNotificationIndicatorViewAnimationStateNone;
                }
            };
            _TBTabBarButtonNotificationIndicatorViewAnimationState const _prevAnimationState = _notificationIndicatorViewAnimationState;
            _notificationIndicatorViewAnimationState = _TBTabBarButtonNotificationIndicatorViewAnimationStateShow;
            // When there is a very small (less than animation duration) gap in time between hiding and showing the indicator view we should animate it without extra spring animation to make it look smooth
            if (_prevAnimationState == _TBTabBarButtonNotificationIndicatorViewAnimationStateHide) {
                [UIView animateWithDuration:[self notificationIndicatorAnimationDuration:true] delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
            } else {
                [UIView animateWithDuration:[self notificationIndicatorAnimationDuration:true] delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.25 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
            }
        }
    } else {
        if (animated == false) {
            notificationIndicatorView.alpha = 0.0;
            if (notificationIndicatorView.superview != nil) {
                [notificationIndicatorView removeFromSuperview];
            }
        } else {
            _notificationIndicatorViewAnimationState = _TBTabBarButtonNotificationIndicatorViewAnimationStateHide;
            [self setNeedsLayout];
            [UIView animateWithDuration:[self notificationIndicatorAnimationDuration:false] delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self layoutIfNeeded];
                notificationIndicatorView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (self->_notificationIndicatorViewAnimationState == _TBTabBarButtonNotificationIndicatorViewAnimationStateHide) {
                    [notificationIndicatorView removeFromSuperview];
                    self->_notificationIndicatorViewAnimationState = _TBTabBarButtonNotificationIndicatorViewAnimationStateNone;
                }
            }];
        }
    }
}

#pragma mark Overrides

- (void)setNeedsLayout {
    
    [super setNeedsLayout];
    
    [self _setNeedsLayout];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (_needsLayout == false) {
        return;
    }

    _needsLayout = false;
    
    CGRect const bounds = self.bounds;
    
    // Tab icon
    
    UIImageView *imageView = self.imageView;
    
    if (imageView.superview != nil && imageView.image != nil) {
        
        imageView.frame = [self imageViewFrameForBounds:bounds];
    }
    
    // Notification indicator
    
    UIImageView *notificationIndicatorView = self.notificationIndicatorView;
    
    if (notificationIndicatorView.superview != nil) {
        
        notificationIndicatorView.frame = [self notificationIndicatorViewFrameForBounds:bounds];
    }
}

- (void)tintColorDidChange {
    
    [super tintColorDidChange];
    
    UIColor *const tintColor = self.tintColor;
    
    if (self.isSelected) {
        self.imageView.tintColor = tintColor;
    }
}

#pragma mark Private Methods

#pragma mark Setup

- (void)_commonInitWithTabBarItem:(TBTabBarItem *)tabBarItem {
    // Logic
    self.enabled = tabBarItem.isEnabled;
    // Data
    _tabBarItem = tabBarItem;
    // Images
    _normalImage = tabBarItem.image;
    _selectedImage = tabBarItem.selectedImage;
    // Layout
    _notificationIndicatorSize = (CGSize){_TBTabBarButtonNotificationIndicatorSize, _TBTabBarButtonNotificationIndicatorSize};
    _notificationIndicatorVisible = tabBarItem.showsNotificationIndicator;
    _notificationIndicatorInsets = _laysOutHorizontally ? UIEdgeInsetsMake(0.0, 0.0, 0.0, 5.0) : UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0);
    _notificationIndicatorViewAnimationState = _TBTabBarButtonNotificationIndicatorViewAnimationStateNone;
}

- (void)_setup {
    // UI
    // Tab icon
    if (_normalImage != nil) {
        [self addSubview:self.imageView];
    }
    // Notification indicator
    if (self.isNotificationIndicatorVisible) {
        [self addSubview:self.notificationIndicatorView];
    }
}

#pragma mark Helpers

- (void)_updateImage {
    
    UIImage *image = nil;
    
    if (self.isHighlighted) {
        if (self.isSelected) {
            image = _highlightedAndSelectedImage;
        } else {
            image = _highlightedImage;
        }
    } else if (self.isEnabled == false) {
        image = _disabledImage;
    } else if (self.isSelected) {
        image = _selectedImage;
    }
    
    if (image == nil && _normalImage != nil) {
        image = _normalImage;
    }
    
    UIImageView *imageView = self.imageView;
    
    UIImage *prevImage = imageView.image;
    
    imageView.image = image;
    
    if (imageView.superview == nil && imageView.image != nil) {
        [self addSubview:imageView];
        [self setNeedsLayout];
    } else if (imageView.superview != nil && imageView.image == nil) {
        [imageView removeFromSuperview];
        [self setNeedsLayout];
    } else {
        if ([prevImage isEqual:image] == false) {
            [self setNeedsLayout];
        }
    }
}

#pragma mark Layout

- (void)_setNeedsLayout {
    
    if (!_needsLayout) {
        _needsLayout = true;
    }
}

#pragma mark Getters

- (UIImageView *)imageView {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithImage:_normalImage];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.autoresizingMask = UIViewAutoresizingNone;
    }
    
    return _imageView;
}

- (UIImageView *)notificationIndicatorView {
    
    if (_notificationIndicatorView == nil) {
        _notificationIndicatorView = [[UIImageView alloc] initWithImage:self.tabBarItem.notificationIndicator];
        _notificationIndicatorView.autoresizingMask = UIViewAutoresizingNone;
    }
    
    return _notificationIndicatorView;
}

#pragma mark Setters

- (void)setFrame:(CGRect)frame {
    
    if (CGRectEqualToRect(self.frame, frame) == false) {
        [self _setNeedsLayout];
    }
    
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    
    if (CGRectEqualToRect(self.bounds, bounds) == false) {
        [self _setNeedsLayout];
    }
    
    [super setBounds:bounds];
}

- (void)setSelected:(BOOL)selected {
    
    if (self.selected == selected) {
        return;
    }
    
    [super setSelected:selected];
    
    [self _updateImage];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    if (self.highlighted == highlighted) {
        return;
    }
    
    [super setHighlighted:highlighted];
    
    [self _updateImage];
}

- (void)setEnabled:(BOOL)enabled {
    
    if (self.enabled == enabled) {
        return;
    }
    
    [super setEnabled:enabled];
    
    self.alpha = self.isEnabled ? 1.0 : 0.5;
    
    [self _updateImage];
}

- (void)setNotificationIndicatorHidden:(BOOL)notificationIndicatorHidden {
    
    [self setNotificationIndicatorHidden:notificationIndicatorHidden animated:false];
}

- (void)setNotificationIndicatorSize:(CGSize)notificationIndicatorSize {
    
    _notificationIndicatorSize = notificationIndicatorSize;
    
    if (self.notificationIndicatorView.superview != nil && self.notificationIndicatorVisible == false) {
        [self setNeedsLayout];
    }
}

- (void)setNotificationIndicatorInsets:(UIEdgeInsets)notificationIndicatorInsets {
    
    if (UIEdgeInsetsEqualToEdgeInsets(_notificationIndicatorInsets, notificationIndicatorInsets)) {
        return;
    }
    
    _notificationIndicatorInsets = notificationIndicatorInsets;
    
    [self setNeedsLayout];
}

- (void)setNotificationIndicatorView:(__kindof UIView *)notificationIndicatorView {
    
    if (_notificationIndicatorView != nil && _notificationIndicatorView.superview != nil) {
        [_notificationIndicatorView removeFromSuperview];
    }
    
    if (notificationIndicatorView == nil) {
        _notificationIndicatorView = [[UIImageView alloc] initWithImage:self.tabBarItem.notificationIndicator];
    } else {
        if ([_notificationIndicatorView isEqual:notificationIndicatorView]) {
            return;
        }
        _notificationIndicatorView = notificationIndicatorView;
    }
    
    BOOL const isNotificationIndicatorVisible = self.isNotificationIndicatorVisible;
    
    if (isNotificationIndicatorVisible) {
        [self setNotificationIndicatorHidden:isNotificationIndicatorVisible animated:false];
    }
    
    [self addSubview:_notificationIndicatorView];
}

@end

#pragma mark - Subclassing

@implementation TBTabBarButton (Subclassing)

#pragma mark Public Methods

- (CGRect)imageViewFrameForBounds:(CGRect)bounds {
    
    CGFloat const width = CGRectGetWidth(bounds);
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const displayScale = self.tb_displayScale;
    
    UIImageView *imageView = self.imageView;
    
    [imageView sizeToFit];
    
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame = _TBPixelAccurateRect((CGRect){
        (CGPoint){(width - CGRectGetWidth(imageViewFrame)) / 2.0, (height - CGRectGetHeight(imageViewFrame)) / 2.0},
        imageViewFrame.size
    }, displayScale, true);
    
    return imageViewFrame;
}

- (CGRect)notificationIndicatorViewFrameForBounds:(CGRect)bounds {
    
    CGFloat const width = CGRectGetWidth(bounds);
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const displayScale = self.tb_displayScale;
    
    BOOL const isNotificationIndicatorVisible = self.isNotificationIndicatorVisible;

    CGPoint indicatorOrigin;
    
    UIEdgeInsets const insets = self.notificationIndicatorInsets;
    CGSize const indicatorSize = self.notificationIndicatorSize;
    CGFloat const multiplier = isNotificationIndicatorVisible ? 1.0 : 0.0;
    
    if (_laysOutHorizontally) {
        indicatorOrigin = (CGPoint){
            (width - indicatorSize.width) - ((insets.left + insets.right) * multiplier),
            (height - indicatorSize.height + insets.top - insets.bottom) / 2.0
        };
    } else {
        indicatorOrigin = (CGPoint){
            (width - indicatorSize.width + insets.left - insets.right) / 2.0,
            (height - indicatorSize.height) - ((insets.top + insets.bottom) * multiplier)
        };
    }
    
    return _TBPixelAccurateRect((CGRect){indicatorOrigin, indicatorSize}, displayScale, true);
}

- (NSTimeInterval)notificationIndicatorAnimationDuration:(BOOL)presenting {
    
    return presenting ?
        _TBTabBarButtonNotificationIndicatorPresentationAnimationDuration :
        _TBTabBarButtonNotificationIndicatorDismissalAnimationDuration;
}

@end
