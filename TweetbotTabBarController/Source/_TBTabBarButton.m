//
//  TBTabBarButton.m
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

#import "_TBTabBarButton.h"

#import "TBTabBarItem.h"

#import "_TBDotView.h"

@interface _TBTabBarButton ()

@property (strong, nonatomic, readwrite) UIImageView *imageView;

@property (weak, nonatomic, readwrite) TBTabBarItem *tabBarItem;

@property (strong, nonatomic, readwrite) _TBDotView *dotView;

@end

@implementation _TBTabBarButton {
    
    UIImage *_normalImage;
    UIImage *_highlightedImage;
    UIImage *_disabledImage;
    UIImage *_selectedImage;
    UIImage *_highlightedAndSelectedImage;
}

#pragma mark - Public

- (instancetype)initWithTabBarItem:(TBTabBarItem *)tabBarItem {
    
    if (self = [super initWithFrame:CGRectZero]) {
        self.tabBarItem = tabBarItem;
        [self tb_commonInit];
    }
    
    return self;
}


- (UIImage *)imageForState:(UIControlState)state {
    
    UIImage *image = nil;
    
    switch (state) {
        case UIControlStateNormal:
            image = _normalImage;
            break;
        case UIControlStateHighlighted:
            image = _highlightedImage;
            break;
        case UIControlStateDisabled:
            image = _disabledImage;
            break;
        case UIControlStateSelected:
            image = _selectedImage;
            break;
        case UIControlStateHighlighted | UIControlStateSelected:
            image = _highlightedAndSelectedImage;
            break;
        default:
            break;
    }
    
    return image;
}


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
    
    [self tb_updateImage];
    
    [self setNeedsLayout];
}


#pragma mark View Lifecycle

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    
    // Image view
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.x = rint((CGRectGetWidth(self.bounds) - CGRectGetWidth(imageViewFrame)) / 2.0);
    imageViewFrame.origin.y = rint((CGRectGetHeight(self.bounds) - CGRectGetHeight(imageViewFrame)) / 2.0);
    
    self.imageView.frame = imageViewFrame;
    
    // Dot view
    CGSize dotViewSize = (CGSize){5.0, 5.0};
    CGPoint dotViewPosition = CGPointZero;
    
    if (self.laysOutHorizontally) {
        dotViewPosition = (CGPoint){rint(CGRectGetMaxX(self.bounds) - (dotViewSize.width * 2.0)), rint(CGRectGetMidY(self.bounds) - (dotViewSize.height / 2.0))};
    } else {
        dotViewPosition = (CGPoint){rint(CGRectGetMidX(self.bounds) - (dotViewSize.width / 2.0)), rint(CGRectGetMaxY(self.bounds) - (dotViewSize.height + 3.0))};
    }
    
    self.dotView.frame = (CGRect){dotViewPosition, dotViewSize};
}


#pragma mark - Private

- (void)tb_commonInit {
    
    _normalImage = self.tabBarItem.image;
    _selectedImage = self.tabBarItem.selectedImage;
    
    self.dotView.hidden = !self.tabBarItem.showDot;
    
    [self tb_setup];
}


- (void)tb_setup {
    
    // Image view
    [self addSubview:self.imageView];
    
    [self tb_updateImage];
    
    // Dot view
    [self addSubview:self.dotView];
}


- (void)tb_updateImage {
    
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
    
    self.imageView.image = image;
}


#pragma mark Getters

- (UIImageView *)imageView {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    return _imageView;
}


- (_TBDotView *)dotView {
    
    if (_dotView == nil) {
        _dotView = [[_TBDotView alloc] initWithFrame:CGRectZero];
        _dotView.hidden = true;
        _dotView.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    return _dotView;
}


#pragma mark Setters

- (void)setSelected:(BOOL)selected {
    
    if (self.selected == selected) {
        return;
    }
    
    [super setSelected:selected];
    
    [self tb_updateImage];
}


- (void)setHighlighted:(BOOL)highlighted {
    
    if (self.highlighted == highlighted) {
        return;
    }
    
    [super setHighlighted:highlighted];
    
    [self tb_updateImage];
}


- (void)setEnabled:(BOOL)enabled {
    
    if (self.enabled == enabled) {
        return;
    }
    
    [super setEnabled:enabled];
    
    self.alpha = self.isEnabled ? 1.0 : 0.5;
    
    [self tb_updateImage];
}

@end
