//
//  UIApplication+Extensions.m
//  TBTabBarController
//
//  Created by Timur Ganiev on 27.01.2023.
//  Copyright © 2019-2023 Timur Ganiev. All rights reserved.
//

#import "UIApplication+Extensions.h"

@implementation UIApplication (Extensions)

#pragma mark Private Methods

- (nullable UIWindowScene *)retrieveActiveWindowSceneFromHierarchy API_AVAILABLE(ios(13.0)) {

    if (self.openSessions.count == 1) {
        UISceneSession *session = self.openSessions.anyObject;
        return [session.scene isKindOfClass:[UIWindowScene class]] ?
            (UIWindowScene *)session.scene :
            nil;
    }

    for (UISceneSession *session in self.openSessions) {

        if ([session.scene isKindOfClass:[UIWindowScene class]] == false) {
            return nil;
        }

        switch (session.scene.activationState) {
            case UISceneActivationStateForegroundActive:
            case UISceneActivationStateForegroundInactive:
                return (UIWindowScene *)session.scene;
                break;

            default:
                return nil;
                break;
        }
    }

    return nil;
}

#pragma mark Getters

- (UIScreen *)currentScreen {

    if (@available(iOS 13.0, *)) {
        return [self retrieveActiveWindowSceneFromHierarchy].screen;
    } else if (self.keyWindow != nil) {
        return self.keyWindow.screen;
    } else {
        return [UIScreen mainScreen];
    }
}

@end
