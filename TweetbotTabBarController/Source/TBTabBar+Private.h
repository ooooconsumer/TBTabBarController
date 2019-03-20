//
//  TBTabBar+Private.h
//  TBTabBarController
//
//  Created by Timur Ganiev on 07/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

#import "TBTabBar.h"

@class _TBTabBarButton;

NS_ASSUME_NONNULL_BEGIN

@interface TBTabBar (Private)

@property (strong, nonatomic, readonly, nullable) NSArray <_TBTabBarButton *> *buttons;

@end

NS_ASSUME_NONNULL_END
