//
//  SceneDelegate.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "SceneDelegate.h"

#import "EntryPoint.h"

@implementation SceneDelegate

#pragma mark - Public

#pragma mark UIWindowSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0)) {

    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];

    [[EntryPoint shared] setupWithWindow:self.window];
}

@end
