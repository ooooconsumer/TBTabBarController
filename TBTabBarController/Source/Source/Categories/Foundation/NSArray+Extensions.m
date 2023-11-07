//
//  NSArray+Extensions.m
//  TBTabBarController
//
//  Created by Timur Ganiev on 28.01.2023.
//  Copyright © 2019-2023 Timur Ganiev. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

- (NSArray *)reversed {
    return [[self reverseObjectEnumerator] allObjects];
}

- (id)firstObject:(BOOL (^)(id _Nonnull))condition {

    __block id object;

    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (condition(obj)) {
            object = obj;
            *stop = true;
        }
    }];

    return object;
}

@end
