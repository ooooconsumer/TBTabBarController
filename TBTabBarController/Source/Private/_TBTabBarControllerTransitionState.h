//
//  _TBTabBarControllerTransitionState.h
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

#import <Foundation/Foundation.h>

#import <TBTabBarController/TBTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

@interface _TBTabBarControllerTransitionState : NSObject

@property (assign, nonatomic, readonly) TBTabBarControllerTabBarPlacement initialPlacement;
@property (assign, nonatomic, readonly) TBTabBarControllerTabBarPlacement targetPlacement;

@property (weak, nonatomic, readonly, nullable) TBTabBar *manipulatedTabBar;

@property (assign, nonatomic, readonly) BOOL backwards;
@property (assign, nonatomic, readonly) BOOL isShowing;
@property (assign, nonatomic, readonly) BOOL isHiding;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

+ (_TBTabBarControllerTransitionState *)stateWithInitialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                                                  targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                                        backwards:(BOOL)backwards;

+ (_TBTabBarControllerTransitionState *)stateWithManipulatedTabBar:(TBTabBar *)tabBar
                                                  initialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                                                   targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                                         backwards:(BOOL)backwards;

@end

NS_ASSUME_NONNULL_END
