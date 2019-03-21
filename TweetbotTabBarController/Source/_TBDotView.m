//
//  _TBDotView.m
//  TweetbotTabBarController
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

#import "_TBDotView.h"

@implementation _TBDotView

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


#pragma mark UIViewRendering

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    [self.tintColor set];
    CGContextDrawPath(context, kCGPathFill);
}


- (void)tintColorDidChange {
    
    [super tintColorDidChange];
    
    [self setNeedsDisplay];
}


#pragma mark - Private

- (void)tb_commonInit {
    
    self.userInteractionEnabled = false;
    
    [self tb_setup];
}


- (void)tb_setup {
    
    self.backgroundColor = [UIColor clearColor];
}

@end
