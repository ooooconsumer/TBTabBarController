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

#import "TBDotLayer.h"

#import "TBUtils.h"

static const CGFloat _TBTabBarButtonDotSize = 5.0;
static const CGFloat _TBTabBarButtonDotBottomInset = 3.0;

@interface _TBTabBarButton ()

@property (strong, nonatomic, readwrite) UIImageView *imageView;

@property (strong, nonatomic, readwrite) TBDotLayer *dotLayer;

@end

@implementation _TBTabBarButton {
    
    UIImage *_normalImage;
    UIImage *_highlightedImage;
    UIImage *_disabledImage;
    UIImage *_selectedImage;
    UIImage *_highlightedAndSelectedImage;
    
    BOOL tb_needsLayoutImageView;
}

#pragma mark - Public

- (instancetype)initWithTabBarItem:(TBTabBarItem *)tabBarItem {
    
    if (self = [super initWithFrame:CGRectZero]) {
        [self tb_commonInitWithTabBarItem:tabBarItem];
    }
    
    return self;
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
    
    UIImageView *imageView = self.imageView;
    
    if (imageView.image == nil) {
        return;
    }
    
    CGFloat const displayScale = self.traitCollection.displayScale;
    
    [imageView sizeToFit];
    
    CGRect const bounds = self.bounds;
    
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.origin = (CGPoint){TBFloorValueWithScale(((CGRectGetWidth(bounds) - CGRectGetWidth(imageViewFrame)) / 2.0), displayScale), TBFloorValueWithScale(((CGRectGetHeight(bounds) - CGRectGetHeight(imageViewFrame)) / 2.0), displayScale)};
    
    self.imageView.frame = imageViewFrame;
    
    CGRect dotLayerFrame = (CGRect){CGPointZero, (CGSize){_TBTabBarButtonDotSize, _TBTabBarButtonDotSize}};
    
    if (self.laysOutHorizontally) {
        dotLayerFrame.origin = (CGPoint){TBFloorValueWithScale(CGRectGetWidth(bounds) - (_TBTabBarButtonDotSize * 2.0), displayScale), TBFloorValueWithScale((CGRectGetHeight(bounds) - _TBTabBarButtonDotSize) / 2.0, displayScale)};
    } else {
        dotLayerFrame.origin = (CGPoint){TBFloorValueWithScale((CGRectGetWidth(bounds) - _TBTabBarButtonDotSize) / 2.0, displayScale), TBFloorValueWithScale(CGRectGetHeight(bounds) - (_TBTabBarButtonDotSize + _TBTabBarButtonDotBottomInset), displayScale)};
    }
    
    self.dotLayer.frame = dotLayerFrame;
    
    [self.dotLayer setNeedsDisplay];
}

#pragma mark - Private

- (void)tb_commonInitWithTabBarItem:(TBTabBarItem *)tabBarItem {
    
    _normalImage = tabBarItem.image;
    _selectedImage = tabBarItem.selectedImage;
    
    self.dotLayer.hidden = !tabBarItem.showDot;
    
    [self tb_setup];
}


- (void)tb_setup {
    
    // Image view
    [self addSubview:self.imageView];
    
    [self tb_updateImage];
    
    // Dot view
    [self.layer addSublayer:self.dotLayer];
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


- (TBDotLayer *)dotLayer {
    
    if (_dotLayer == nil) {
        _dotLayer = [TBDotLayer layer];
        _dotLayer.hidden = true;
    }
    
    return _dotLayer;
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
