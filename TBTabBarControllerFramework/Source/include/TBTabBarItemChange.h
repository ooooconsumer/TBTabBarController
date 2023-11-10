//
//  TBTabBarItemChange.h
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

@class TBTabBarItem;

/**
 * @abstract Describes the type of change in a TBTabBarItem.
 */
typedef NS_ENUM(NSInteger, TBTabBarItemChangeType) {
    /// Indicates that a tab item was inserted.
    TBTabBarItemChangeInsert,

    /// Indicates that a tab item was removed.
    TBTabBarItemChangeRemove
};

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract Represents a change in a TBTabBarItem.
 * @discussion The `TBTabBarItemChange` class is used to encapsulate changes made to the tab items in a TBTabBarController.
 */
@interface TBTabBarItemChange : NSObject

/**
 * @abstract The tab item associated with the change, if applicable.
 */
@property (strong, nonatomic, readonly, nullable) TBTabBarItem *item;

/**
 * @abstract The type of change (insert or remove).
 */
@property (assign, nonatomic, readonly) TBTabBarItemChangeType type;

/**
 * @abstract The index of the change.
 */
@property (assign, nonatomic, readonly) NSUInteger index;

/**
 * @abstract Initializes a TBTabBarItemChange instance with the specified parameters.
 * @param item The tab item associated with the change.
 * @param type The type of change (insert or remove).
 * @param index The index of the change.
 * @return An initialized TBTabBarItemChange instance.
 */
- (instancetype)initWithItem:(TBTabBarItem *)item
                        type:(TBTabBarItemChangeType)type
                       index:(NSUInteger)index NS_DESIGNATED_INITIALIZER;

/**
 * @abstract Initializes a TBTabBarItemChange instance with a collection change.
 * @discussion This initializer is available starting from iOS 13.
 * @param collectionChange The collection change from which to create the TBTabBarItemChange.
 * @return An initialized TBTabBarItemChange instance.
 */
- (instancetype)initWithCollectionChange:(NSOrderedCollectionChange *)collectionChange API_AVAILABLE(ios(13.0));

/**
 * @abstract This method is unavailable. Use designated initializers to create TBTabBarItemChange instances.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @abstract This method is unavailable. Use designated initializers to create TBTabBarItemChange instances.
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
