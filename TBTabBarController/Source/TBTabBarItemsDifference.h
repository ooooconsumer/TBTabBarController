//
//  TBTabBarItemsDifference.h
//  TBTabBarController
//
//  Copyright (c) 2019-2020 Timur Ganiev
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

@class TBTabBarItemChange, TBTabBarItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract A difference between two given arrays calculated using the Myers algorithm.
 * @discussion This is a backward compatibility for NSOrderedCollectionDifeerence that supports older iOS versions (< 13.0).
 * Under the hood it uses the same algorithm that uses Swift to calculate the difference except it is written in C language.
 * For iOS 13.0 and up it uses NSOrderedCollectionDifeerence to calculate the difference.
 */
@interface TBTabBarItemsDifference : NSObject <NSFastEnumeration> {
    
@protected
    NSArray<TBTabBarItemChange *> *_changes;
}

@property (strong, nonatomic, readonly) NSArray<TBTabBarItemChange *> *insertions;

@property (strong, nonatomic, readonly) NSArray<TBTabBarItemChange *> *removals;

@property (assign, nonatomic, readonly) BOOL hasChanges;

- (instancetype)initWithChanges:(NSArray<TBTabBarItemChange *> *)changes;

- (instancetype)initWithCollectionDifference:(NSOrderedCollectionDifference *)collectionDifference API_AVAILABLE(ios(13.0));

+ (instancetype)differenceWithItems:(NSArray<TBTabBarItem *> *)array from:(NSArray<TBTabBarItem *> *)other;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
