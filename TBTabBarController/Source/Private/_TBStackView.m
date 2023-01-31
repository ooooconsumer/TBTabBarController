//
//  _TBStackView.m
//  TBTabBarController
//
//  Copyright © 2019-2023 Timur Ganiev. All rights reserved.
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

#import "_TBStackView.h"
#import "TBTabBarButton.h"
#import "_TBUtils.h"
#import "UIView+Extensions.h"

typedef NS_ENUM(NSUInteger, _TBStackViewPixelDistributionRule) {
    _TBStackViewPixelDistributionRuleStraight,
    _TBStackViewPixelDistributionRuleEven,
    _TBStackViewPixelDistributionRuleOdd
};

typedef struct _TBStackViewPixelDistribution {
    _TBStackViewPixelDistributionRule rule;
    NSUInteger pixelsCount;
} _TBStackViewPixelDistribution;

@implementation _TBStackView {
    
    BOOL _needsLayout;
}

#pragma mark Lifecycle

- (instancetype)initWithAxis:(TBStackedTabsViewAxis)axis {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _vertical = axis == TBStackedTabsViewAxisVertical;
        [self _commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _vertical = false;
        [self _commonInit];
    }
    
    return self;
}

- (instancetype)init {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _vertical = false;
        [self _commonInit];
    }
    
    return self;
}

#pragma mark Overrides

- (void)setNeedsLayout {
    
    [super setNeedsLayout];
    
    [self _setNeedsLayout];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (_needsLayout == false) {
        return;
    }

    _needsLayout = false;
    
    NSArray<TBTabBarButton *> *subviews = self.subviews;
    NSUInteger const tabsCount = subviews.count;
    
    if (tabsCount == 0) {
        return;
    }

    CGFloat const width = CGRectGetWidth(self.bounds);
    CGFloat const height = CGRectGetHeight(self.bounds);
    CGFloat const displayScale = self.tb_displayScale;
    CGFloat const pixelSize = (1.0 / displayScale);
    CGFloat const spacing = self.spacing;
    CGFloat const totalSpacing = (spacing * (tabsCount - 1));
    BOOL const isVertical = self.isVertical;

    CGRect frames[tabsCount];
    
    if (isVertical) {
        CGFloat const maxTabHeight = (height - totalSpacing) / (CGFloat)tabsCount;
        for (NSInteger index = 0; index < tabsCount; index += 1) {
            frames[index] = (CGRect){
                {0.0, ((_TBPixelAccurateValue(maxTabHeight, displayScale, true) + _TBPixelAccurateValue(spacing, displayScale, true)) * (CGFloat)index)},
                {width, _TBPixelAccurateValue(maxTabHeight, displayScale, true)}
            };
        }
    } else {
        CGFloat const maxTabWidth = (width - totalSpacing) / (CGFloat)tabsCount;
        for (NSInteger index = 0; index < tabsCount; index += 1) {
            frames[index] = (CGRect){
                {((_TBPixelAccurateValue(maxTabWidth, displayScale, true) + _TBPixelAccurateValue(spacing, displayScale, true)) * (CGFloat)index), 0.0},
                {_TBPixelAccurateValue(maxTabWidth, displayScale, true), height}
            };
        }
    }
    
    NSUInteger undistributedPixelsCount = (NSUInteger)ceil(MAX(0.0, (isVertical ? height - CGRectGetMaxY(frames[tabsCount - 1]) : width -CGRectGetMaxX(frames[tabsCount - 1]))) / pixelSize);
    
    if (undistributedPixelsCount > 0) {

        NSUInteger const distributionRowsCount = (NSUInteger)ceil((CGFloat)undistributedPixelsCount / (CGFloat)tabsCount);
        _TBStackViewPixelDistribution distributionRows[distributionRowsCount];

        for (NSUInteger row = 0; row < distributionRowsCount; row += 1) {
            NSUInteger const undistributedPixelsCountInRow = MIN(undistributedPixelsCount, tabsCount);
            NSUInteger const amountOfEvenNumbers = _TBAmountOfEvenNumbersInRange(NSMakeRange(1, tabsCount));
            NSUInteger const amountOfOddNumbers = tabsCount - amountOfEvenNumbers;
            BOOL const isEven = undistributedPixelsCountInRow % 2 == 0;
            if (isEven && amountOfEvenNumbers >= undistributedPixelsCountInRow) {
                distributionRows[row] = (_TBStackViewPixelDistribution){_TBStackViewPixelDistributionRuleEven, undistributedPixelsCountInRow};
            } else if (!isEven && amountOfOddNumbers >= undistributedPixelsCountInRow) {
                distributionRows[row] = (_TBStackViewPixelDistribution){_TBStackViewPixelDistributionRuleOdd, undistributedPixelsCountInRow};
            } else {
                distributionRows[row] = (_TBStackViewPixelDistribution){_TBStackViewPixelDistributionRuleStraight, undistributedPixelsCountInRow};
            }
            undistributedPixelsCount -= undistributedPixelsCountInRow;
        }

        CGPoint offset = CGPointZero;
        NSUInteger distributedPixelsCount[distributionRowsCount];

        for (NSUInteger row = 0; row < distributionRowsCount; row += 1) {
            distributedPixelsCount[row] = 0;
        }

        for (NSInteger index = 0; index < tabsCount; index += 1) {

            CGRect frame = frames[index];
            CGRect newFrame = CGRectZero;
            CGFloat axisOffset = 0.0;

            for (NSUInteger row = 0; row < distributionRowsCount; row += 1) {
                _TBStackViewPixelDistribution const distributionRow = distributionRows[row];
                if (distributionRow.pixelsCount > distributedPixelsCount[row]) {
                    switch (distributionRow.rule) {
                        case _TBStackViewPixelDistributionRuleStraight:
                            axisOffset += pixelSize;
                            distributedPixelsCount[row] += 1;
                            break;

                        case _TBStackViewPixelDistributionRuleEven:
                            if ((index + 1) % 2 == 0) {
                                axisOffset += pixelSize;
                                distributedPixelsCount[row] += 1;
                            }
                            break;

                        case _TBStackViewPixelDistributionRuleOdd:
                            if ((index + 1) % 2 != 0) {
                                axisOffset += pixelSize;
                                distributedPixelsCount[row] += 1;
                            }
                            break;

                        default:
                            break;
                    }
                }
            }

            if (axisOffset > 0.0) {
                CGSize newSize = frame.size;
                CGPoint newOffset = offset;
                if (isVertical) {
                    newSize.height += axisOffset;
                    newOffset.y += axisOffset;
                } else {
                    newSize.width += axisOffset;
                    newOffset.x += axisOffset;
                }
                newFrame = (CGRect){{frame.origin.x + offset.x, frame.origin.y + offset.y}, newSize};
                offset = newOffset;
            }

            if (offset.x > 0.0 || offset.y > 0.0) {
                if (CGRectEqualToRect(newFrame, CGRectZero)) {
                    // Shift only next frames due size changes of previous ones since they're already corrected
                    newFrame = frame;
                    newFrame.origin = (CGPoint){newFrame.origin.x + offset.x, newFrame.origin.y + offset.y};
                }
                frames[index] = newFrame;
            }
        }
    }
    
    NSInteger index = 0;

    for (TBTabBarButton *subview in subviews) {
        subview.frame = frames[index];
        index += 1;
    }
}

- (void)addSubview:(UIView *)view {
    
    NSAssert([view isKindOfClass:[TBTabBarButton class]], @"Subview must be of type `%@`", NSStringFromClass([TBTabBarButton class]));
    
    [super addSubview:view];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    
    NSAssert([view isKindOfClass:[TBTabBarButton class]], @"Subview must be of type `%@`", NSStringFromClass([TBTabBarButton class]));
    
    [super insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    
    NSAssert([view isKindOfClass:[TBTabBarButton class]], @"Subview must be of type `%@`", NSStringFromClass([TBTabBarButton class]));
    
    [super insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    
    NSAssert([view isKindOfClass:[TBTabBarButton class]], @"Subview must be of type `%@`", NSStringFromClass([TBTabBarButton class]));
    
    [super insertSubview:view belowSubview:siblingSubview];
}

#pragma mark Private Methods

#pragma mark Setup

- (void)_commonInit {
    _spacing = 4.0;
    _needsLayout = false;
}

#pragma mark Layout

- (void)_setNeedsLayout {
    
    if (!_needsLayout) {
        _needsLayout = true;
    }
}

#pragma mark Setters

- (void)setFrame:(CGRect)frame {
    
    if (CGRectEqualToRect(self.frame, frame) == false) {
        [self _setNeedsLayout];
    }
    
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    
    if (CGRectEqualToRect(self.bounds, bounds) == false) {
        [self _setNeedsLayout];
    }
    
    [super setBounds:bounds];
}

- (void)setSpacing:(CGFloat)spacing {

    if (_spacing == spacing) {
        return;
    }
    
    _spacing = spacing;
    
    [self setNeedsLayout];
}

@end
