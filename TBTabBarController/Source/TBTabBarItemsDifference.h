//
//  TBTabBarItemsDifference.h
//  TBTabBarController
//
//  Copyright © 2019-2023 Timur Ganiev. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <Foundation/Foundation.h>

#import <TBTabBarController/TBTabBarItemChange.h>

@class TBTabBarItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract Represents the difference between two arrays of TBTabBarItem instances.
 * @discussion The `TBTabBarItemsDifference` class encapsulates the changes between two arrays of tab items.
 * Starting from iOS 13 and newer, it uses `NSOrderedCollectionDifference` to calculate the difference,
 * while older versions calculate the difference manually
 */
@interface TBTabBarItemsDifference : NSObject <NSFastEnumeration> {

@protected
    NSArray<TBTabBarItemChange *> *_changes;
}

/**
 * @abstract An array of changes representing insertions in the difference.
 */
@property (strong, nonatomic, readonly) NSArray<TBTabBarItemChange *> *insertions;

/**
 * @abstract An array of changes representing removals in the difference.
 */
@property (strong, nonatomic, readonly) NSArray<TBTabBarItemChange *> *removals;

/**
 * @abstract Indicates whether there are changes in the difference.
 */
@property (assign, nonatomic, readonly) BOOL hasChanges;

/**
 * @abstract Initializes a TBTabBarItemsDifference instance with an array of TBTabBarItemChange objects.
 * @param changes An array of TBTabBarItemChange objects representing the changes.
 * @return An initialized TBTabBarItemsDifference instance.
 */
- (instancetype)initWithChanges:(NSArray<TBTabBarItemChange *> *)changes;

/**
 * @abstract Initializes a TBTabBarItemsDifference instance with a collection difference.
 * @discussion This initializer is available starting from iOS 13.0.
 * @param collectionDifference The collection difference from which to create the TBTabBarItemsDifference.
 * @return An initialized TBTabBarItemsDifference instance.
 */
- (instancetype)initWithCollectionDifference:(NSOrderedCollectionDifference *)collectionDifference API_AVAILABLE(ios(13.0));

/**
 * @abstract Creates a TBTabBarItemsDifference instance with differences between two arrays of TBTabBarItem objects.
 * @param array An array of TBTabBarItem objects.
 * @param other Another array of TBTabBarItem objects to compare with.
 * @return A TBTabBarItemsDifference instance representing the differences between the two arrays.
 */
+ (instancetype)differenceWithItems:(NSArray<TBTabBarItem *> *)array from:(NSArray<TBTabBarItem *> *)other;

/**
 * @abstract This method is unavailable. Use designated initializers to create TBTabBarItemsDifference instances.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @abstract This method is unavailable. Use designated initializers to create TBTabBarItemsDifference instances.
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
