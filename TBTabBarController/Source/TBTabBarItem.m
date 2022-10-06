//
//  TBTabBarItem.m
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

#import "TBTabBarItem.h"

#import "TBTabBarButton.h"
#import "_TBUtils.h"
#import "UIApplication+Extensions.h"

static NSString *const _TBTabBarItemNotificationIndicatorImageName = @"circle";

@implementation TBTabBarItem

@synthesize notificationIndicator = _notificationIndicator;

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)initWithImage:(UIImage *)image buttonClass:(Class)buttonClass {
    
    return [self initWithImage:image selectedImage:nil title:nil buttonClass:buttonClass];
}

- (instancetype)initWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage buttonClass:(Class)buttonClass {
    
    return [self initWithImage:image selectedImage:selectedImage title:nil buttonClass:buttonClass];
}

- (instancetype)initWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title buttonClass:(Class)buttonClass {
    
    self = [super init];
    
    if (self) {
        _buttonClass = buttonClass != nil ? buttonClass : [TBTabBarButton class];
        _title = title;
        _image = image;
        _selectedImage = selectedImage;
        _enabled = true;
    }
    
    return self;
}

#pragma mark Overrides

- (NSUInteger)hash {
    
    return TB_UINT_ROTATE(self.image.hash, TB_UINT_BIT / 2) ^ self.buttonClass.hash;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object {

    if (self == object) {
        return true;
    }
    
    if ([object isKindOfClass:[self class]] == false) {
        return false;
    }
    
    return [self isEqualToItem:object];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    TBTabBarItem *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.title = [self.title copy];
        copy.image = [self.image copy];
        copy.selectedImage = [self.selectedImage copy];
        copy.notificationIndicator = [self.notificationIndicator copy];
        copy->_showsNotificationIndicator = _showsNotificationIndicator;
        copy->_enabled = _enabled;
        copy->_buttonClass = [self.buttonClass copy];
    }
    
    return copy;
}

#pragma mark Private Methods

#pragma mark Helpers

- (UIImage *)makeNotificationIndicatorImage {
    return _TBDrawFilledCircleWithSize((CGSize){5.0, 5.0}, [UIScreen mainScreen].nativeScale);
}

#pragma mark Getters

- (UIImage *)notificationIndicator {
    
    if (_notificationIndicator == nil) {
        _notificationIndicator = [self makeNotificationIndicatorImage];
    }
    
    return _notificationIndicator;
}

#pragma mark Setters

- (void)setEnabled:(BOOL)enabled {
    
    NSString *key = NSStringFromSelector(@selector(isEnabled));
    
    [self willChangeValueForKey:key];
    
    _enabled = enabled;
    
    [self didChangeValueForKey:key];
}

- (void)setNotificationIndicator:(UIImage *)notificationIndicator {
    
    NSString *key = NSStringFromSelector(@selector(notificationIndicator));
    
    [self willChangeValueForKey:key];
    
    if (notificationIndicator != nil) {
        _notificationIndicator = notificationIndicator;
    } else {
        _notificationIndicator = [self makeNotificationIndicatorImage];
    }
    
    [self didChangeValueForKey:key];
}

@end

#pragma mark - TBExtendedTabBarItem

@implementation TBTabBarItem (TBExtendedTabBarItem)

#pragma mark - Public

- (BOOL)isEqualToItem:(TBTabBarItem *)item {
    
    return self.title == item.title &&
        self.image == item.image &&
        self.selectedImage == item.selectedImage &&
        self.enabled == item.enabled &&
        self.showsNotificationIndicator == item.showsNotificationIndicator;
}

@end
