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

#import "_TBTabBarControllerTransitionContext.h"

@interface _TBTabBarControllerTransitionContext ()

@property (weak, nonatomic, nullable) __kindof UIViewController *sourceViewController;
@property (weak, nonatomic, nullable) __kindof UIViewController *destinationViewController;

@property (assign, nonatomic) CGAffineTransform targetTransform;

@end

@implementation _TBTabBarControllerTransitionContext {

    __weak __kindof UIView *_containerView;
}

#pragma mark Lifecycle

- (instancetype)initWithSourceViewController:(__kindof UIViewController *)sourceViewController
                   destinationViewController:(__kindof UIViewController *)destinationViewController
                               containerView:(__kindof UIView *)containerView {

    self = [super init];

    if (self) {
        self.sourceViewController = sourceViewController;
        self.destinationViewController = destinationViewController;
        self.targetTransform = CGAffineTransformIdentity;
        _containerView = containerView;
    }

    return self;
}

#pragma mark UIViewControllerContextTransitioning

- (UIView *)containerView {

    return _containerView;
}

- (BOOL)transitionWasCancelled {

    return NO;
}

- (UIModalPresentationStyle)presentationStyle {

    return UIModalPresentationCustom;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {

}

- (void)finishInteractiveTransition {

}

- (void)cancelInteractiveTransition {

}

- (void)pauseInteractiveTransition {

}

- (void)completeTransition:(BOOL)didComplete {

    if (self.completionBlock != nil) {
        self.completionBlock(didComplete);
    }
}

- (__kindof UIViewController *)viewControllerForKey:(UITransitionContextViewControllerKey)key {

    if ([key isEqualToString:UITransitionContextFromViewControllerKey]) {
        return self.sourceViewController;
    } else if ([key isEqualToString:UITransitionContextToViewControllerKey]) {
        return self.destinationViewController;
    }

    return nil;
}

- (__kindof UIView *)viewForKey:(UITransitionContextViewKey)key {

    if ([key isEqualToString:UITransitionContextFromViewKey]) {
        return self.sourceViewController.view;
    } else if ([key isEqualToString:UITransitionContextToViewKey]) {
        return self.destinationViewController.view;
    }

    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {

    return self.containerView.bounds;
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {

    return self.containerView.bounds;
}

@end
