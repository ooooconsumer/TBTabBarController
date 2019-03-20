//
//  TBTabBarItem.h
//  TBTabBarController
//
//  Created by Timur Ganiev on 03/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBTabBarItem : NSObject

@property (strong, nonatomic, nullable) UIImage *image;

@property (strong, nonatomic, nullable) UIImage *selectedImage;

/** @brief Describes whether item should be enabled or disabled. Default is YES */
@property (assign, nonatomic, getter = isEnabled) BOOL enabled;

/** @brief By setting this value to YES, a tab bar will show a small dot next to the tab icon that indicates something has happened. Default is NO */
@property (assign, nonatomic) BOOL showDot;

- (instancetype)initWithImage:(nullable UIImage *)image;

- (instancetype)initWithImage:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage;

@end

NS_ASSUME_NONNULL_END
