//
//  TBFakeNavigationBar.m
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

#import "TBFakeNavigationBar.h"

#import "TBUtils.h"

static const CGFloat TBFakeNavigationBarButtonVerticalInset = 4.0;

@implementation TBFakeNavigationBar {
    
    BOOL tb_needsLayoutButton;
}

#pragma mark - Public

- (instancetype)init {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self tb_commonInit];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self tb_commonInit];
    }
    
    return self;
}


#pragma mark View lifecycle

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIButton *button = self.button;
    
    if (button == nil || tb_needsLayoutButton == false) {
        return;
    }
    
    CGFloat const displayScale = self.traitCollection.displayScale;
    
    [button sizeToFit];
    
    CGRect const frame = self.frame;
    CGRect buttonFrame = button.frame;
    
    UIEdgeInsets safeAreaInsets = self.safeAreaInsets;
    
    CGFloat const preferredHeight = TBFloorValueWithScale((CGRectGetHeight(frame) - safeAreaInsets.top - TBFakeNavigationBarButtonVerticalInset * 2.0), displayScale);
    
    if (CGRectGetHeight(buttonFrame) > preferredHeight) {
        if (self.shouldShrink && button.imageView.image) {
            CGSize const scaledSize = (CGSize){TBFloorValueWithScale((preferredHeight / CGRectGetHeight(buttonFrame)) * CGRectGetWidth(buttonFrame), displayScale), preferredHeight};
            button.imageView.image = TBResizeImageToPreferredSize(button.imageView.image, scaledSize);
            buttonFrame.size = scaledSize;
        }
    }
    
    buttonFrame.origin = (CGPoint){TBFloorValueWithScale((CGRectGetWidth(frame) - CGRectGetWidth(buttonFrame) + safeAreaInsets.left) / 2.0, displayScale), TBFloorValueWithScale(CGRectGetHeight(frame) - CGRectGetHeight(buttonFrame) - TBFakeNavigationBarButtonVerticalInset, displayScale)};
    
    button.frame = buttonFrame;
    
    tb_needsLayoutButton = false;
}


#pragma mark - Private

- (void)tb_commonInit {
    
    self.shouldShrink = true;
}


#pragma mark Setters

- (void)setBounds:(CGRect)bounds {
    
    if (CGRectEqualToRect(self.bounds, bounds) == false) {
        tb_needsLayoutButton = true;
    }
    
    [super setBounds:bounds];
}


- (void)setButton:(UIButton *)button {
    
    _button = button;
    
    if (button == nil) {
        if (_button != nil) {
            [_button removeFromSuperview];
        }
    } else {
        if ([button.superview isEqual:self] == false) {
            tb_needsLayoutButton = true;
            [self addSubview:button];
        }
    }
}

@end
