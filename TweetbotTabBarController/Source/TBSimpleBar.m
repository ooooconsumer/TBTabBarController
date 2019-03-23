//
//  TBSimpleBar.m
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

#import "TBSimpleBar.h"

@implementation TBSimpleBar

@synthesize separatorColor = _separatorColor;

#pragma mark - Public

- (instancetype)init {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self tb_setupBar];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self tb_setupBar];
    }
    
    return self;
}


#pragma mark UIViewRendering

- (void)drawRect:(CGRect)rect {
    
    CGFloat const pixelSize = (1.0 / self.traitCollection.displayScale);
    CGFloat const offset = (pixelSize / 2.0);
    
    CGPoint startPoint, endPoint;
    
    switch (self.separatorPosition) {
        case TBSimpleBarSeparatorPositionTop:
            startPoint = (CGPoint){CGRectGetMinX(rect), offset};
            endPoint = (CGPoint){CGRectGetMaxX(rect), startPoint.y};
            break;
        case TBSimpleBarSeparatorPositionLeft:
            startPoint = (CGPoint){offset, CGRectGetMinY(rect)};
            endPoint = (CGPoint){startPoint.x, CGRectGetMaxY(rect)};
            break;
        case TBSimpleBarSeparatorPositionBottom:
            startPoint = (CGPoint){CGRectGetMinX(rect), CGRectGetMaxY(rect) - offset};
            endPoint = (CGPoint){CGRectGetMaxX(rect), startPoint.y};
            break;
        case TBSimpleBarSeparatorPositionRight:
            startPoint = (CGPoint){CGRectGetMaxX(rect) - offset, CGRectGetMinX(rect)};
            endPoint = (CGPoint){startPoint.x, CGRectGetMaxY(rect)};
            break;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, pixelSize);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextClosePath(context);
    [self.separatorColor setStroke];
    CGContextDrawPath(context, kCGPathStroke);
}


#pragma mark UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (previousTraitCollection.displayScale != self.traitCollection.displayScale) {
        [self setNeedsDisplay];
    }
    
    [super traitCollectionDidChange:previousTraitCollection];
}


#pragma mark - Private

- (void)tb_setupBar {
    
    self.separatorPosition = TBSimpleBarSeparatorPositionBottom;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor whiteColor];
}


#pragma mark Getters

- (UIColor *)separatorColor {
    
    if (_separatorColor == nil) {
        _separatorColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    }
    
    return _separatorColor;
}


#pragma mark Setters

- (void)setSeparatorColor:(UIColor *)separatorColor {
    
    if (separatorColor != nil) {
        _separatorColor = separatorColor;
    } else {
        _separatorColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    }
    
    [self setNeedsDisplay];
}

@end
