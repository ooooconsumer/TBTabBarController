//
//  _TBTabBarControllerTransitionContext.m
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

#import "_TBTabBarControllerTransitionState.h"

@implementation _TBTabBarControllerTransitionState

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)initWithManipulatedTabBar:(nullable TBTabBar *)tabBar
                          initialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                           targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                backwards:(BOOL)backwards {

    self = [super init];

    if (self) {
        _manipulatedTabBar = tabBar;
        _initialPlacement = initialPlacement;
        _targetPlacement = targetPlacement;
        _isShowing = initialPlacement == TBTabBarControllerTabBarPlacementHidden && targetPlacement > TBTabBarControllerTabBarPlacementHidden;
        _isHiding = initialPlacement > TBTabBarControllerTabBarPlacementHidden && targetPlacement == TBTabBarControllerTabBarPlacementHidden;
        _backwards = backwards;
    }

    return self;
}

+ (_TBTabBarControllerTransitionState *)stateWithInitialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                                                      targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                                           backwards:(BOOL)backwards {

    return [[_TBTabBarControllerTransitionState alloc] initWithManipulatedTabBar:nil
                                                                   initialPlacement:initialPlacement
                                                                    targetPlacement:targetPlacement
                                                                         backwards:backwards];
}

+ (_TBTabBarControllerTransitionState *)stateWithManipulatedTabBar:(TBTabBar *)tabBar
                                                       initialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                                                        targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                                             backwards:(BOOL)backwards {

    return [[_TBTabBarControllerTransitionState alloc] initWithManipulatedTabBar:tabBar
                                                                   initialPlacement:initialPlacement
                                                                    targetPlacement:targetPlacement
                                                                         backwards:backwards];
}

@end
