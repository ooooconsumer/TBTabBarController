//
//  TBTabBarItemsDifference.m
//  TBTabBarController
//
//  Copyright (c) 2019-2023 Timur Ganiev
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

#import "TBTabBarItemsDifference.h"
#import "TBTabBarItemChange.h"
#import "_TBUtils.h"
#import "NSArray+Extensions.h"

@implementation TBTabBarItemsDifference

#pragma mark Lifecycle

- (instancetype)initWithChanges:(NSArray<TBTabBarItemChange *> *)changes {
    
    self = [super init];
    
    if (self) {
        _changes = changes;
        _insertions = [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %ld", NSStringFromSelector(@selector(type)), TBTabBarItemChangeInsert]];
        _removals = _insertions.count != _changes.count ? [_changes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %ld", NSStringFromSelector(@selector(type)), TBTabBarItemChangeRemove]] : @[];
        _hasChanges = _changes.count > 0;
    }
    
    return self;
}

- (instancetype)initWithCollectionDifference:(NSOrderedCollectionDifference *)collectionDifference {
    
    NSMutableArray *changes = [NSMutableArray arrayWithCapacity:collectionDifference.insertions.count + collectionDifference.removals.count];
    for (NSOrderedCollectionChange *change in collectionDifference) {
        [changes addObject:[[TBTabBarItemChange alloc] initWithCollectionChange:change]];
    }
    
    return [self initWithChanges:[changes copy]];
}

+ (instancetype)differenceWithItems:(NSArray<TBTabBarItem *> *)array from:(NSArray<TBTabBarItem *> *)other {
    
    if (array.count == 0) {
        return [[TBTabBarItemsDifference alloc] initWithChanges:[self _changesFrom:array insertion:false]];
    } else if (other.count == 0) {
        return [[TBTabBarItemsDifference alloc] initWithChanges:[self _changesFrom:array insertion:true]];
    }

    if (@available(iOS 13.0, *)) {
        return [[TBTabBarItemsDifference alloc] initWithCollectionDifference:[array differenceFromArray:other]];
    } else {
        NSArray<TBTabBarItemChange *> *removals = [[self _changesFrom:other insertion:false] reversed];
        NSArray<TBTabBarItemChange *> *insertions = [self _changesFrom:array insertion:true];
        NSArray<TBTabBarItemChange *> *changes = [removals arrayByAddingObjectsFromArray:insertions];
        return [[TBTabBarItemsDifference alloc] initWithChanges:changes];
    }
}

#pragma mark Overrides

- (NSString *)description {
    
    if (!self.hasChanges) {
        return [NSString stringWithFormat:@"%@ without changes.", [super description]];
    }
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@ contains %ld %@:", [super description], _changes.count, _changes.count == 1 ? @"change" : @"changes"];
    
    for (TBTabBarItemChange *change in self) {
        [description appendFormat:@"\n%@", change];
    }
    
    return [description copy];
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id _Nullable [])buffer count:(NSUInteger)len {
    
    return [_changes countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark Private Methods

+ (NSArray<TBTabBarItemChange *> *)_changesFrom:(NSArray<TBTabBarItem *> *)items insertion:(BOOL)insertion {
    
    NSUInteger const length = items.count;
    
    if (length == 0) {
        return @[];
    }
    
    NSMutableArray *changes = [NSMutableArray arrayWithCapacity:length];
    
    TBTabBarItemChangeType const type = insertion ? TBTabBarItemChangeInsert : TBTabBarItemChangeRemove;
    
    for (NSUInteger index = 0; index < length; index += 1) {
        [changes insertObject:[[TBTabBarItemChange alloc] initWithItem:items[index] type:type index:index] atIndex:index];
    }
    
    return changes;
}

@end
