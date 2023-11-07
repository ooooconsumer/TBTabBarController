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

/**
 * @abstract Returns a new array with the elements reversed in order.
 * @discussion This method creates a new array with the elements of the original array in reverse order. The original array remains unchanged.
 * @return A new array containing the reversed elements.
 */
- (NSArray<ObjectType> *)reversed;

/**
 * @abstract Returns the first object in the array that satisfies the given condition.
 * @discussion This method iterates through the array and returns the first object for which the provided condition block returns `YES`. 
 * If no object meets the condition, it returns `nil`.
 * @param condition A block that defines the condition the object must satisfy.
 * @return The first object that meets the condition, or `nil` if no object matches the condition.
 */
- (nullable ObjectType)firstObject:(BOOL(^)(ObjectType object))condition;

@end

NS_ASSUME_NONNULL_END
