//
//  UIApplication+Extensions.h
//  TBTabBarController
//
//  Created by Timur Ganiev on 27.01.2023.
//  Copyright © 2023 Timur Ganiev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Extensions)

@property (strong, nonatomic, readonly, nullable) UIScreen *currentScreen;

@end

NS_ASSUME_NONNULL_END
