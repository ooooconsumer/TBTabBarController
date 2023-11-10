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
#import "TBTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract A private class that represents the transition state of a tab bar placement within the `TBTabBarController` framework.
 * @discussion This class is used internally by `TBTabBarController` to manage transitions between different tab bar placements.
 */
@interface _TBTabBarControllerTransitionState : NSObject

/**
 * @abstract The initial tab bar placement at the beginning of the transition.
 */
@property (assign, nonatomic, readonly) TBTabBarControllerTabBarPlacement initialPlacement;

/**
 * @abstract The target tab bar placement at the end of the transition.
 */
@property (assign, nonatomic, readonly) TBTabBarControllerTabBarPlacement targetPlacement;

/**
 * @abstract The tab bar that is manipulated during the transition.
 */
@property (weak, nonatomic, readonly, nullable) TBTabBar *manipulatedTabBar;

/**
 * @abstract A flag indicating whether the transition is happening in a backward direction.
 */
@property (assign, nonatomic, readonly) BOOL backwards;

/**
 * @abstract A flag indicating whether the tab bar is in the process of showing.
 */
@property (assign, nonatomic, readonly) BOOL isShowing;

/**
 * @abstract A flag indicating whether the tab bar is in the process of hiding.
 */
@property (assign, nonatomic, readonly) BOOL isHiding;

/**
 * @abstract This method is unavailable for use.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @abstract Creates and returns a new instance of `TBTabBarControllerTransitionState` with the provided 
 * initial and target placements and transition direction.
 * @param initialPlacement The initial tab bar placement at the beginning of the transition.
 * @param targetPlacement The target tab bar placement at the end of the transition.
 * @param backwards A flag indicating whether the transition is happening in a backward direction.
 * @return A new _TBTabBarControllerTransitionState instance.
 */
+ (_TBTabBarControllerTransitionState *)stateWithInitialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                                                  targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                                        backwards:(BOOL)backwards;

/**
 * @abstract Creates and returns a new instance of `TBTabBarControllerTransitionState` with the provided 
 * manipulated tab bar, initial and target placements, and transition direction.
 * @param tabBar The tab bar that is manipulated during the transition.
 * @param initialPlacement The initial tab bar placement at the beginning of the transition.
 * @param targetPlacement The target tab bar placement at the end of the transition.
 * @param backwards A flag indicating whether the transition is happening in a backward direction.
 * @return A new _TBTabBarControllerTransitionState instance.
 */
+ (_TBTabBarControllerTransitionState *)stateWithManipulatedTabBar:(TBTabBar *)tabBar
                                                  initialPlacement:(TBTabBarControllerTabBarPlacement)initialPlacement
                                                   targetPlacement:(TBTabBarControllerTabBarPlacement)targetPlacement
                                                         backwards:(BOOL)backwards;

@end

NS_ASSUME_NONNULL_END
