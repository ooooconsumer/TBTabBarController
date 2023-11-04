//
//  TabBarController.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "TabBarController.h"

@implementation TabBarController

#pragma mark -  Public

#pragma mark Overrides

- (void)viewDidLoad {

    [super viewDidLoad];

    // Make the bottom tab bar translucent

    self.horizontalTabBar.backgroundColor = [UIColor clearColor];
    self.horizontalTabBar.contentView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
}

- (TBTabBarControllerTabBarPlacement)preferredTabBarPlacementForViewSize:(CGSize)size {

    // Show the vertical tab bar whenever the device orientation is landscape

    return size.width >= size.height ? TBTabBarControllerTabBarPlacementLeading : TBTabBarControllerTabBarPlacementBottom;
}

@end
