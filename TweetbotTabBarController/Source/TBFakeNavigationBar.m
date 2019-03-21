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
