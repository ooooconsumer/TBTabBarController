//
//  _TBDotView.m
//  TweetbotTabBarController
//
//  Created by Timur Ganiev on 19/03/2019.
//

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
