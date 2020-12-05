//
//  TBTabBarItemChange.h
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

@class TBTabBarItem;

typedef NS_ENUM(NSInteger, TBTabBarItemChangeType) {
    TBTabBarItemChangeInsert,
    TBTabBarItemChangeRemove
};

NS_ASSUME_NONNULL_BEGIN

@interface TBTabBarItemChange : NSObject

@property (strong, nonatomic, readonly, nullable) TBTabBarItem *item;

@property (assign, nonatomic, readonly) TBTabBarItemChangeType type;

@property (assign, nonatomic, readonly) NSUInteger index;

- (instancetype)initWithItem:(TBTabBarItem *)item type:(TBTabBarItemChangeType)type index:(NSUInteger)index NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCollectionChange:(NSOrderedCollectionChange *)collectionChange API_AVAILABLE(ios(13.0));

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
