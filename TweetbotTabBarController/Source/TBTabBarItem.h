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

- (instancetype)initWithImage:(nullable UIImage *)image;

- (instancetype)initWithImage:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage;

@end

NS_ASSUME_NONNULL_END
