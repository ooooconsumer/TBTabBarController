//
//  UINavigationController+Extensions.m
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


#import "UINavigationController+Extensions.h"
#import "TBTabBarController.h"
#import "TBTabBarController+Private.h"
#import "_TBUtils.h"

#import <objc/runtime.h>

@interface UINavigationController ()

@property (weak, nonatomic, setter = tb_setPrivateDelegate:) id<TBNavigationControllerExtensionDelegate> tb_delegate;

@property (assign, nonatomic, getter = tb_isNestedInTBTabBarController, setter = tb_setNestedInTBTabBarController:) BOOL tb_nestedInTBTabBarController;
@property (assign, nonatomic, getter = tb_isInteractivePopGestureRecognizerRegistered, setter = tb_setInteractivePopGestureRecognizerRegistered:) BOOL tb_interactivePopGestureRecognizerRegistered;

@end

@implementation UINavigationController (Extensions)

static char *tb_nestedInTBTabBarControllerKey;
static char *tb_interactivePopGestureRecognizerRegisteredKey;
static char *tb_privateDelegateKey;

#pragma mark Lifecycle

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TBSwizzleMethod([self class],
                         @selector(popViewControllerAnimated:),
                         @selector(tb_popViewControllerAnimated:));

        _TBSwizzleMethod([self class],
                         @selector(popToViewController:animated:),
                         @selector(tb_popToViewController:animated:));

        _TBSwizzleMethod([self class],
                         @selector(popToRootViewControllerAnimated:),
                         @selector(tb_popToRootViewControllerAnimated:));

        _TBSwizzleMethod([self class],
                         @selector(pushViewController:animated:),
                         @selector(tb_pushViewController:animated:));

        _TBSwizzleMethod([self class],
                         @selector(didMoveToParentViewController:),
                         @selector(tb_didMoveToParentViewController:));

        _TBSwizzleMethod([self class],
                         @selector(viewDidLayoutSubviews),
                         @selector(tb_viewDidLayoutSubviews));
    });
}

#pragma mark Overrides

- (UIViewController *)tb_popViewControllerAnimated:(BOOL)animated {

    UIViewController *previousViewController = [self tb_popViewControllerAnimated:animated];

    if (!self.tb_isNestedInTBTabBarController) {
        return previousViewController;
    }

    [previousViewController setValue:nil forKey:NSStringFromSelector(@selector(tb_tabBarController))];

    [self tb_popViewController:previousViewController
     destinationViewController:self.topViewController
                      animated:animated];

    return previousViewController;
}

- (NSArray<__kindof UIViewController *> *)tb_popToViewController:(UIViewController *)viewController
                                                        animated:(BOOL)animated {

    UIViewController *previousViewController = self.topViewController;

    NSArray<__kindof UIViewController *> *viewControllers = [self tb_popToViewController:viewController animated:animated];

    if (!self.tb_isNestedInTBTabBarController) {
        return viewControllers;
    }

    for (UIViewController *viewController in viewControllers) {
        [viewController setValue:nil forKey:NSStringFromSelector(@selector(tb_tabBarController))];
    }

    [self tb_popViewController:previousViewController destinationViewController:viewController animated:animated];

    return viewControllers;
}

- (NSArray<__kindof UIViewController *> *)tb_popToRootViewControllerAnimated:(BOOL)animated {

    UIViewController *previousViewController = self.topViewController;

    NSArray<__kindof UIViewController *> *viewControllers = [self tb_popToRootViewControllerAnimated:animated];

    for (UIViewController *viewController in viewControllers) {
        [viewController setValue:nil forKey:NSStringFromSelector(@selector(tb_tabBarController))];
    }

    [self tb_popViewController:previousViewController destinationViewController:self.topViewController animated:animated];

    return viewControllers;
}

- (void)tb_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {

    if (!self.tb_isNestedInTBTabBarController) {
        [self tb_pushViewController:viewController animated:animated];
        return;
    }

    UIViewController *prevViewController = self.topViewController; // Get the top view controller before it will be replaced with a new view controller

    [viewController setValue:prevViewController.tb_tabBarController forKey:NSStringFromSelector(@selector(tb_tabBarController))];

    [self tb_pushViewController:viewController animated:animated];

    if (self.tb_isInteractivePopGestureRecognizerRegistered == false && self.interactivePopGestureRecognizer != nil) {
        [self tb_registerInteractivePopGestureRecognizer:self.interactivePopGestureRecognizer];
    }

    [self.tb_delegate tb_navigationController:self
                       didBeginTransitionFrom:prevViewController
                                           to:viewController
                                    backwards:false];

    id<UIViewControllerTransitionCoordinator> const transitionCoordinator = self.transitionCoordinator;

    if (transitionCoordinator != nil) {

        __weak typeof(self) weakSelf = self;
        
        [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (weakSelf == nil) {
                return;
            }
            typeof(self) strongSelf = weakSelf;
            [strongSelf.tb_delegate tb_navigationController:strongSelf
                                      willEndTransitionFrom:prevViewController
                                                         to:viewController
                                                  cancelled:context.isCancelled];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (weakSelf == nil) {
                return;
            }
            typeof(self) strongSelf = weakSelf;
            [strongSelf.tb_delegate tb_navigationController:strongSelf
                                       didEndTransitionFrom:prevViewController
                                                         to:viewController
                                                  cancelled:context.isCancelled];
        }];
        
    } else {
        
        if (animated) {
            [UIView animateWithDuration:0.35 delay:0.0 options:7 << 16 animations:^{
                [self.tb_delegate tb_navigationController:self
                                    willEndTransitionFrom:prevViewController
                                                       to:viewController
                                                cancelled:false];
            } completion:^(BOOL finished) {
                [self.tb_delegate tb_navigationController:self
                                     didEndTransitionFrom:prevViewController
                                                       to:viewController
                                                cancelled:false];
            }];
        } else {
            [self.tb_delegate tb_navigationController:self
                                willEndTransitionFrom:prevViewController
                                                   to:viewController
                                            cancelled:false];
            [self.tb_delegate tb_navigationController:self
                                 didEndTransitionFrom:prevViewController
                                                   to:viewController
                                            cancelled:false];
        }
    }
}

- (void)tb_viewDidLayoutSubviews {

    [self tb_viewDidLayoutSubviews];

    if (self.tb_nestedInTBTabBarController) {
        [self tb_update];
    }
}

- (void)tb_didMoveToParentViewController:(UIViewController *)parent {

    [self tb_didMoveToParentViewController:parent];

    if (parent == nil && self.tb_isNestedInTBTabBarController) {
        [self.interactivePopGestureRecognizer removeTarget:self action:@selector(tb_handleInteractivePopGestureRecognizer:)];
        self.tb_nestedInTBTabBarController = false;
        self.tb_delegate = nil;
    } else if ([parent isKindOfClass:[TBTabBarController class]]) {
        self.tb_delegate = (id<TBNavigationControllerExtensionDelegate>)parent;
        self.tb_nestedInTBTabBarController = true;
        [self tb_update];
    }
}

#pragma mark Private Methods

#pragma mark Gestures

- (void)tb_registerInteractivePopGestureRecognizer:(__kindof UIGestureRecognizer *)interactivePopGestureRecognizer {

    [interactivePopGestureRecognizer addTarget:self action:@selector(tb_handleInteractivePopGestureRecognizer:)];

    self.tb_interactivePopGestureRecognizerRegistered = true;
}

- (void)tb_handleInteractivePopGestureRecognizer:(UIPanGestureRecognizer *)interactivePopGestureRecognizer {

    if (interactivePopGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        return;
    }

    CGFloat const translation = [interactivePopGestureRecognizer translationInView:self.view].x;

    if (translation == 0.0) {
        return;
    }

    CGFloat const completed = MAX(0.0, MIN(1.0, translation / CGRectGetWidth(self.view.bounds)));

    [self.tb_delegate tb_navigationController:self
                     didUpdateInteractiveFrom:[self.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey]
                                           to:self.topViewController
                              percentComplete:completed];
}

#pragma mark Helpers

- (void)tb_popViewController:(UIViewController *)previousViewController
   destinationViewController:(UIViewController *)destinationViewController
                    animated:(BOOL)animated {

    id<UIViewControllerTransitionCoordinator> const transitionCoordinator = self.transitionCoordinator;

    [self.tb_delegate tb_navigationController:self didBeginTransitionFrom:previousViewController to:destinationViewController backwards:true];

    if (transitionCoordinator != nil) {
        
        if (transitionCoordinator.isInteractive) {
            
            __weak typeof(self) weakSelf = self;
            
            [transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                if (weakSelf == nil) {
                    return;
                }
                typeof(self) strongSelf = weakSelf;
                BOOL const isCancelled = context.isCancelled;
                if (animated) {
                    [UIView animateWithDuration:transitionCoordinator.transitionDuration
                                          delay:0.0
                         usingSpringWithDamping:1.0
                          initialSpringVelocity:transitionCoordinator.completionVelocity
                                        options:transitionCoordinator.completionCurve << 16
                                     animations:^{
                        [strongSelf.tb_delegate tb_navigationController:strongSelf
                                                  willEndTransitionFrom:previousViewController
                                                                     to:destinationViewController
                                                              cancelled:isCancelled];
                    } completion:^(BOOL finished) {
                        [strongSelf.tb_delegate tb_navigationController:strongSelf
                                                   didEndTransitionFrom:previousViewController
                                                                     to:destinationViewController
                                                              cancelled:isCancelled];
                    }];
                } else {
                    [strongSelf.tb_delegate tb_navigationController:strongSelf
                                              willEndTransitionFrom:previousViewController
                                                                 to:destinationViewController
                                                          cancelled:isCancelled];
                    [strongSelf.tb_delegate tb_navigationController:strongSelf
                                               didEndTransitionFrom:previousViewController
                                                                 to:destinationViewController
                                                          cancelled:isCancelled];
                }
            }];
            
        } else {
            
            __weak typeof(self) weakSelf = self;
            
            [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (weakSelf == nil) {
                    return;
                }
                typeof(self) strongSelf = weakSelf;
                [strongSelf.tb_delegate tb_navigationController:strongSelf
                                          willEndTransitionFrom:previousViewController
                                                             to:destinationViewController
                                                      cancelled:context.isCancelled];
            } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (weakSelf == nil) {
                    return;
                }
                typeof(self) strongSelf = weakSelf;
                [strongSelf.tb_delegate tb_navigationController:strongSelf
                                           didEndTransitionFrom:previousViewController
                                                             to:destinationViewController
                                                      cancelled:context.isCancelled];
            }];
            
        }
        
    } else {
        
        if (animated) {
            [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:7 << 16 animations:^{
                [self.tb_delegate tb_navigationController:self
                                    willEndTransitionFrom:previousViewController
                                                       to:destinationViewController
                                                cancelled:false];
            } completion:^(BOOL finished) {
                [self.tb_delegate tb_navigationController:self
                                     didEndTransitionFrom:previousViewController
                                                       to:destinationViewController
                                                cancelled:false];
            }];
        } else {
            [self.tb_delegate tb_navigationController:self
                                willEndTransitionFrom:previousViewController
                                                   to:destinationViewController
                                            cancelled:false];
            [self.tb_delegate tb_navigationController:self
                                 didEndTransitionFrom:previousViewController
                                                   to:destinationViewController
                                            cancelled:false];
        }
    }
}

- (void)tb_update {

    CGFloat value = 0.0;

    for (UIView *subview in self.navigationBar.subviews) {
        if ([NSStringFromClass([subview class]) containsString:@"ContentView"]) {
            value = CGRectGetMaxY(subview.frame);
            break;
        }
    }

    [self.tb_delegate tb_navigationController:self
                 navigationBarDidChangeHeight:value + self.view.safeAreaInsets.top];
}

#pragma mark Getters

- (BOOL)tb_isNestedInTBTabBarController {

    return [(NSNumber *)objc_getAssociatedObject(self, &tb_nestedInTBTabBarControllerKey) boolValue];
}

- (BOOL)tb_isInteractivePopGestureRecognizerRegistered {

    return [(NSNumber *)objc_getAssociatedObject(self, &tb_interactivePopGestureRecognizerRegisteredKey) boolValue];
}

- (id<TBNavigationControllerExtensionDelegate>)tb_delegate {

    return objc_getAssociatedObject(self, &tb_privateDelegateKey);
}

#pragma mark Setters

- (void)tb_setNestedInTBTabBarController:(BOOL)tb_nestedInTBTabBarController {

    objc_setAssociatedObject(self,
                             &tb_nestedInTBTabBarControllerKey,
                             @(tb_nestedInTBTabBarController),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)tb_setInteractivePopGestureRecognizerRegistered:(BOOL)tb_interactivePopGestureRecognizerRegistered {

    objc_setAssociatedObject(self,
                             &tb_interactivePopGestureRecognizerRegisteredKey,
                             @(tb_interactivePopGestureRecognizerRegistered),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)tb_setPrivateDelegate:(id<TBNavigationControllerExtensionDelegate>)tb_privateDelegate {

    objc_setAssociatedObject(self,
                             &tb_privateDelegateKey,
                             tb_privateDelegate,
                             OBJC_ASSOCIATION_ASSIGN);
}

@end
