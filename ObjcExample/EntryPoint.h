//
//  EntryPoint.h
//  ObjcExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EntryPoint : NSObject

@property (weak, nonatomic, readonly) UIWindow *window;

@property (class, nonatomic, readonly) EntryPoint *shared;

- (void)setupWithWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
