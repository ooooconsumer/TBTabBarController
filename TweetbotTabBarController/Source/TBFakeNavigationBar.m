//
//  TBFakeNavigationBar.m
//  TBTabBarController
//
//  Created by Timur Ganiev on 03/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

#import "TBFakeNavigationBar.h"

@interface TBFakeNavigationBar ()

@property (strong, nonatomic) UIView *separatorView;

@property (assign, nonatomic) CGFloat separatorViewHeight;

@end

@implementation TBFakeNavigationBar

@synthesize separatorColor = _separatorColor;

#pragma mark - Public

- (instancetype)init {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self tb_setup];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self tb_setup];
    }
    
    return self;
}


#pragma mark View lifecycle

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.separatorView.frame = (CGRect){CGPointMake(0.0, CGRectGetHeight(self.frame) - _separatorViewHeight), CGSizeMake(CGRectGetWidth(self.frame), _separatorViewHeight)};
}


#pragma mark UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (previousTraitCollection.displayScale != self.traitCollection.displayScale) {
        _separatorViewHeight = (1.0 / self.traitCollection.displayScale);
    }
    
    [super traitCollectionDidChange:previousTraitCollection];
}


#pragma mark - Private

- (void)tb_setup {
    
    _separatorViewHeight = (1.0 / [UIScreen mainScreen].scale);
    
    // View
    self.backgroundColor = [UIColor whiteColor];
    
    // Separator view
    self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    [self addSubview:self.separatorView];
}


#pragma mark Getters

- (UIColor *)separatorColor {
    
    return self.separatorView.backgroundColor;
}


#pragma mark Setters

- (void)setSeparatorColor:(UIColor *)separatorColor {
    
    self.separatorView.backgroundColor = separatorColor;
}

@end
