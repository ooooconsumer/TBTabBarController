//
//  AppDelegate.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "AppDelegate.h"

#import "EntryPoint.h"

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (@available(iOS 13.0, *)) { } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[EntryPoint shared] setupWithWindow:self.window];
    }
    
    return true;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)){

    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
