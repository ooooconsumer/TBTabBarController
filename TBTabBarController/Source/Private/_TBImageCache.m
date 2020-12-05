//
//  _TBImageCache.m
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

#import "_TBImageCache.h"

@implementation _TBImageCache {
    
    NSCache *_cache;
}

static _TBImageCache *_sharedCache;

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self _commonInit];
    }
    
    return self;
}

+ (instancetype)new {
    
    return [[_TBImageCache alloc] init];
}

#pragma mark Interface

- (nullable UIImage *)cachedImageWithName:(NSString *)imageName {
    
    return [_cache objectForKey:imageName];
}

- (void)cacheImage:(UIImage *)image withName:(NSString *)imageName {
    
    [_cache setObject:image forKey:imageName];
}

#pragma mark - Private

#pragma mark Setup

- (void)_commonInit {
    
    _cache = [[NSCache alloc] init];
}

#pragma mark Getters

+ (_TBImageCache *)cache {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCache = [[_TBImageCache alloc] init];
    });
    
    return _sharedCache;
}

@end
