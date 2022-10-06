//
//  TBSimpleBar.m
//  TBTabBarController
//
//  Copyright (c) 2019-2023 Timur Ganiev
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

#import "TBSimpleBar.h"
#import "_TBUtils.h"
#import "UIView+Extensions.h"

@implementation TBSimpleBar {
    
    BOOL tbsmplbr_needsLayout;
}

@synthesize contentView = _contentView;
@synthesize separatorColor = tbsmplbr_separatorColor;
@synthesize separatorImage = tbsmplbr_separatorImage;

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)init {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self tbsmplbr_commonInit];
        [self tbsmplbr_setup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self tbsmplbr_commonInit];
        [self tbsmplbr_setup];
    }
    
    return self;
}

#pragma mark Overrides

- (void)setNeedsLayout {
    
    [super setNeedsLayout];
    
    [self tbsmplbr_setNeedsLayout];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (tbsmplbr_needsLayout == false) {
        return;
    }
    
    tbsmplbr_needsLayout = false;
    
    CGRect const bounds = self.bounds;
    
    CGFloat const width = CGRectGetWidth(bounds);
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const displayScale = self.tb_displayScale;
    
    // Separator
    
    CGFloat const separatorSize = self.separatorSize;
    
    CGRect frame = CGRectZero;
    
    switch (self.separatorPosition) {
        case TBSimpleBarSeparatorPositionHidden:
            break;

        case TBSimpleBarSeparatorPositionLeft:
            frame = (CGRect){CGPointZero, (CGSize){separatorSize, height}};
            break;

        case TBSimpleBarSeparatorPositionRight:
            frame = (CGRect){
                _TBPixelAccuratePoint((CGPoint){width - separatorSize, 0.0}, displayScale, false),
                (CGSize){separatorSize, height}
            };
            break;

        case TBSimpleBarSeparatorPositionTop:
            frame = (CGRect){CGPointZero, (CGSize){width, separatorSize}};
            break;

        default:
            break;
    }
    
    if (!CGRectEqualToRect(CGRectZero, frame) && !CGRectIsInfinite(frame)) {
        _separatorImageView.frame = frame;
    }
    
    // Content view
    
    UIView *contentView = self.contentView;
    
    if (contentView != nil && contentView.superview != nil) {
        contentView.frame = bounds;
    }
}

#pragma mark - Private

- (void)tbsmplbr_commonInit {
    
    _separatorSize = (1.0 / self.tb_displayScale);
    _contentInsets = UIEdgeInsetsZero;
    _separatorPosition = TBSimpleBarSeparatorPositionHidden;
    
    _additionalContentInsets =  UIEdgeInsetsZero;
    
    _separatorImageView = [[UIImageView alloc] initWithImage:self.separatorImage];
    _separatorImageView.tintColor = self.separatorColor;
    _separatorImageView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)tbsmplbr_setup {
    // View
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    // Content view
    UIView *contentView = self.contentView;
    if (contentView != nil) {
        [self addSubview:contentView];
    }
    // Separator
    if (self.separatorPosition != TBSimpleBarSeparatorPositionHidden) {
        [self addSubview:_separatorImageView];
    }
}

#pragma mark Helpers

- (UIImage *)makeSeparatorImage {
    return _TBDrawFilledRectangleWithSize((CGSize){self.tb_displayScale, self.tb_displayScale});
}

#pragma mark Layout

- (void)tbsmplbr_setNeedsLayout {
    
    if (!tbsmplbr_needsLayout) {
        tbsmplbr_needsLayout = true;
    }
}

#pragma mark Getters

- (UIColor *)separatorColor {
    
    if (tbsmplbr_separatorColor == nil) {
        if (@available(iOS 13.0, *)) {
            tbsmplbr_separatorColor = [UIColor separatorColor];
        } else {
            tbsmplbr_separatorColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }
    }
    
    return tbsmplbr_separatorColor;
}

- (UIImage *)separatorImage {
    
    if (tbsmplbr_separatorImage == nil) {
        tbsmplbr_separatorImage = [self makeSeparatorImage];
    }
    
    return tbsmplbr_separatorImage;
}

#pragma mark Setters

- (void)setFrame:(CGRect)frame {
    
    if (CGRectEqualToRect(self.frame, frame) == false) {
        [self tbsmplbr_setNeedsLayout];
    }
    
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    
    if (CGRectEqualToRect(self.bounds, bounds) == false) {
        [self tbsmplbr_setNeedsLayout];
    }
    
    [super setBounds:bounds];
}

- (void)setSeparatorSize:(CGFloat)separatorSize {
    
    if (separatorSize < 0.0) {
        return;
    }
    
    _separatorSize = separatorSize;
    
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInsets, contentInsets)) {
        return;
    }
    
    _contentInsets = contentInsets;
    
    [self setNeedsLayout];
}

- (void)setSeparatorPosition:(TBSimpleBarSeparatorPosition)separatorPosition {
    
    if (self.separatorPosition == separatorPosition) {
        return;
    }
    
    if (separatorPosition == TBSimpleBarSeparatorPositionHidden) {
        [_separatorImageView removeFromSuperview];
    } else if (_separatorImageView.superview == nil) {
        [self addSubview:_separatorImageView];
    }
    
    _separatorPosition = separatorPosition;
    
    [self setNeedsLayout];
}

- (void)setContentView:(UIView *)contentView {
    
    if (contentView != nil) {
        [self insertSubview:contentView atIndex:0];
    } else {
        [_contentView removeFromSuperview];
    }
    
    _contentView = contentView;
}

- (void)setSeparatorImage:(UIImage *)separatorImage {
    
    if (separatorImage != nil) {
        tbsmplbr_separatorImage = separatorImage;
    } else {
        tbsmplbr_separatorImage = [self makeSeparatorImage];
    }
    
    _separatorImageView.image = tbsmplbr_separatorImage;
    
    [self setNeedsLayout];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    
    if (separatorColor != nil) {
        tbsmplbr_separatorColor = separatorColor;
    } else {
        if (@available(iOS 13.0, *)) {
            tbsmplbr_separatorColor = [UIColor separatorColor];
        } else {
            tbsmplbr_separatorColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }
    }
    
    _separatorImageView.tintColor = tbsmplbr_separatorColor;
}

@end
