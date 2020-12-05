//
//  UIView+_TBTabBarController.m
//  TBTabBarController
//
//  Copyright (c) 2019-2020 Timur Ganiev
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

#import "UIView+_TBTabBarController.h"

@implementation UIView (_TBTabBarController)

#pragma mark - Public

#pragma mark Interface

- (nullable __kindof UIView *)tb_subviewAtLocation:(CGPoint)location withCondition:(nullable BOOL (^)(__kindof UIView *subview))condition subviewIndex:(NSUInteger *)subviewIndex skipIndexes:(BOOL)skipIndexes touchSize:(CGFloat)touchSize verticalLayout:(BOOL)verticalLayout {
    
    if (verticalLayout) {
        location.x -= touchSize;
    } else {
        location.y -= touchSize;
    }
    
    __kindof UIView *desiredView = nil;
    
    CGFloat const size = touchSize + touchSize;
    CGRect const frame = (CGRect){location, CGSizeMake(size , size)};
    
    NSUInteger index = 0;
    
    for (__kindof UIView *view in self.subviews) {
        if (condition != nil) {
            if (condition(view) == false) {
                if (skipIndexes == false) {
                    index += 1;
                }
                continue;
            }
        }
        if (CGRectIntersectsRect(frame, view.frame)) {
            desiredView = view;
            break;
        }
        index += 1;
    }
    
    if (desiredView != nil) {
        *subviewIndex = index;
    } else {
        *subviewIndex = NSNotFound;
    }
    
    return desiredView;
}

#pragma mark - Private

#pragma mark Getters

- (CGFloat)tb_displayScale {
    
    if (self.window != nil) {
        return self.window.screen.nativeScale;
    } else {
        return [UIScreen mainScreen].nativeScale;
    }
}

- (BOOL)tb_isLeftToRight {
    
    return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionLeftToRight;
}

@end
