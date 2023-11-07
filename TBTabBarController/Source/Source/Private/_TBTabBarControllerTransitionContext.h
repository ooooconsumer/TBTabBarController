//
//  _TBTabBarControllerTransitionContext.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _TBTabBarControllerTransitionContext : NSObject <UIViewControllerContextTransitioning>

@property (copy, nonatomic) void (^completionBlock)(BOOL didComplete);

@property (assign, nonatomic, getter = isAnimated) BOOL animated;
@property (assign, nonatomic, getter = isInteractive) BOOL interactive;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithSourceViewController:(nullable __kindof UIViewController *)sourceViewController
                   destinationViewController:(nullable __kindof UIViewController *)destinationViewController
                               containerView:(__kindof UIView *)containerView;

@end

NS_ASSUME_NONNULL_END
