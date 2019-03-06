//
//  TBTabBarButton.m
//  TBTabBarController
//
//  Created by Timur Ganiev on 03/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

#import "TBTabBarButton.h"

#import "TBTabBarItem.h"

@interface TBTabBarButton ()

@property (strong, nonatomic, readwrite) UIImageView *imageView;

@property (weak, nonatomic, readwrite) TBTabBarItem *tabBarItem;

@end

@implementation TBTabBarButton {
    
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
    
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(imageViewFrame)) / 2.0;
    imageViewFrame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(imageViewFrame)) / 2.0;
    
    self.imageView.frame = imageViewFrame;
}


#pragma mark - Private

- (void)tb_commonInit {
    
    _normalImage = self.tabBarItem.image;
    _selectedImage = self.tabBarItem.selectedImage;
    
    [self tb_setup];
}


- (void)tb_setup {
    
    [self addSubview:self.imageView];
    
    [self tb_updateImage];
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
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    return _imageView;
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
