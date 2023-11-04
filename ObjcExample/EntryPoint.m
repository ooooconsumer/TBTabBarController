//
//  EntryPoint.m
//  ObjcExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "EntryPoint.h"

#import "TabBarController.h"
#import "TabViewController.h"

@implementation EntryPoint

static EntryPoint *_shared;

#pragma mark - Public

#pragma mark Interface

+ (EntryPoint *)shared {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[EntryPoint alloc] init];
    });

    return _shared;
}

- (void)setupWithWindow:(UIWindow *)window {

    _window = window;

    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray array];

    for (NSUInteger index = 0; index < 5; index += 1) {
        [viewControllers addObject:[self _navigationControllerWithTabViewController:[self _tabViewControllerForIndex:index]]];
    }

    TabBarController *tabBarController = [[TabBarController alloc] init];
    tabBarController.viewControllers = viewControllers;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        tabBarController.viewControllers[0].tb_tabBarItem.showsNotificationIndicator = true;
        tabBarController.viewControllers[1].tb_tabBarItem.showsNotificationIndicator = true;
    });

    window.rootViewController = tabBarController;

    [window makeKeyAndVisible];
}

#pragma mark - Private

#pragma mark Builders

- (TabViewController *)_tabViewControllerForIndex:(NSUInteger)index {

    TabViewController *tabViewController = [[TabViewController alloc] init];
    tabViewController.title = [NSString stringWithFormat:@"View Controller #%ld", index];

    return tabViewController;
}

- (UINavigationController *)_navigationControllerWithTabViewController:(TabViewController *)tabViewController {

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabViewController];
    navigationController.tb_tabBarItem.image = [self _drawTabBarItemImage];

    return navigationController;
}

#pragma mark Helpers

- (UIImage *)_drawTabBarItemImage {

    CGSize const size = CGSizeMake(25.0, 25.0);

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextAddEllipseInRect(context, (CGRect){CGPointZero, size});
        CGContextFillPath(context);
    }];

    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
