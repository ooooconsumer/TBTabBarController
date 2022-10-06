//
//  UIViewController+Extensions.m
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

#import "UIViewController+Extensions.h"
#import "UINavigationController+Extensions.h"

@implementation UIViewController (Extensions)

#pragma mark Internal Methods

- (void)tb_addContainerViewController:(UIViewController *)containerViewController {
    
    [self addChildViewController:containerViewController];
    [self.view addSubview:containerViewController.view];
    
    [containerViewController didMoveToParentViewController:self];
    
    containerViewController.view.frame = self.view.bounds;
}

- (void)tb_addContainerViewController:(UIViewController *)containerViewController atIndex:(NSUInteger)index {
    
    [self addChildViewController:containerViewController];
    [self.view insertSubview:containerViewController.view atIndex:index];
    
    [containerViewController didMoveToParentViewController:self];
    
    containerViewController.view.frame = self.view.bounds;
}

- (void)tb_removeContainerViewController:(UIViewController *)containerViewController {
 
    [containerViewController willMoveToParentViewController:nil];
    [containerViewController.view removeFromSuperview];
    [containerViewController removeFromParentViewController];
}

@end
