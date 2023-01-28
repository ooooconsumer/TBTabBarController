//
//  NSArray+Extensions.h
//  TBTabBarController
//
//  Created by Timur Ganiev on 28.01.2023.
//  Copyright © 2019-2023 Timur Ganiev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (Extensions)

- (NSArray<ObjectType> *)reversed;

- (nullable ObjectType)firstObject:(BOOL(^)(ObjectType object))condition;

@end

NS_ASSUME_NONNULL_END
