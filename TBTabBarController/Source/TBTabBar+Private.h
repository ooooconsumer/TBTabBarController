//
//  TBTabBar+Private.h
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

@class TBTabBarItem, TBTabBarItemsDifference;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private

@interface TBTabBar (Private)

- (void)_setItems:(NSArray <__kindof TBTabBarItem *> *)items;

- (void)_setSelectedIndex:(NSUInteger)selectedIndex quitly:(BOOL)quitly;

- (__kindof TBTabBarButton *)_buttonWithItem:(__kindof TBTabBarItem *)item NS_SWIFT_NAME(_button(with:));

- (NSArray<__kindof TBTabBarButton *> *)_buttons;

- (void)_addButton:(__kindof TBTabBarButton *)button;

- (void)_insertButton:(__kindof TBTabBarButton *)button atIndex:(NSUInteger)index;

- (void)_setButtonEnabled:(BOOL)enabled atIndex:(NSUInteger)index;

- (void)_setNormalImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

- (void)_setSelectedImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

- (void)_setNotificationIndicatorImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

- (void)_setNotificationIndicatorHidden:(BOOL)hidden forButtonAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
