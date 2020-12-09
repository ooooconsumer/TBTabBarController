//
//  SceneDelegate.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "SceneDelegate.h"

#import "TabBarController.h"
#import "TabViewController.h"

@implementation SceneDelegate

#pragma mark - Public

#pragma mark UIWindowSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0)) {
    
    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray array];
    
    for (NSUInteger index = 0; index < 5; index += 1) {
        TabViewController *tabViewController = [self _tabViewControllerForIndex:index];
        if (index > 1) {
            tabViewController.tb_hidesTabBarWhenPushed = true;
        }
        UINavigationController *navigationController = [self _navigationControllerWithTabViewController:tabViewController];
        [viewControllers addObject:navigationController];
    }
    
    TabBarController *tabBarController = [[TabBarController alloc] init];
    tabBarController.viewControllers = viewControllers;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        tabBarController.viewControllers[0].tb_tabBarItem.showsNotificationIndicator = true;
        tabBarController.viewControllers[1].tb_tabBarItem.showsNotificationIndicator = true;
    });
    
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
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
