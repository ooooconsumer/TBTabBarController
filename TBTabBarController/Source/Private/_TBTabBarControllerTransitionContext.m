//
//  _TBTabBarControllerTransitionContext.m
//  TBTabBarController
//
//  Copyright (c) 2019-2023 Timur Ganiev
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

#import "_TBTabBarControllerTransitionContext.h"

@implementation _TBTabBarControllerTransitionContext

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)initWithManipulatedTabBar:(nullable TBTabBar *)tabBar initialPosition:(TBTabBarControllerTabBarPosition)initialPosition targetPosition:(TBTabBarControllerTabBarPosition)targetPosition backwards:(BOOL)backwards {
    
    self = [super init];
    
    if (self) {
        _manipulatedTabBar = tabBar;
        _initialPosition = initialPosition;
        _targetPosition = targetPosition;
        _isShowing = initialPosition == TBTabBarControllerTabBarPositionHidden && targetPosition > TBTabBarControllerTabBarPositionHidden;
        _isHiding = initialPosition > TBTabBarControllerTabBarPositionHidden && targetPosition == TBTabBarControllerTabBarPositionHidden;
        _backwards = backwards;
    }
    
    return self;
}

+ (_TBTabBarControllerTransitionContext *)contextWithInitialPosition:(TBTabBarControllerTabBarPosition)initialPosition targetPosition:(TBTabBarControllerTabBarPosition)targetPosition backwards:(BOOL)backwards {
    
    return [[_TBTabBarControllerTransitionContext alloc] initWithManipulatedTabBar:nil initialPosition:initialPosition targetPosition:targetPosition backwards:backwards];
}

+ (_TBTabBarControllerTransitionContext *)contextWithManipulatedTabBar:(TBTabBar *)tabBar initialPosition:(TBTabBarControllerTabBarPosition)initialPosition targetPosition:(TBTabBarControllerTabBarPosition)targetPosition backwards:(BOOL)backwards {
    
    return [[_TBTabBarControllerTransitionContext alloc] initWithManipulatedTabBar:tabBar initialPosition:initialPosition targetPosition:targetPosition backwards:backwards];
}

@end
