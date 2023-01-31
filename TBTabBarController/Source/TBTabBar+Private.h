//
//  TBTabBar+Private.h
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
#import <TBTabBarController/TBTabBarController.h>

@class TBTabBarItem, TBTabBarItemsDifference;

NS_ASSUME_NONNULL_BEGIN

@interface TBTabBar (Private)

@property (assign, nonatomic, readonly) TBTabBarControllerTabBarPlacement currentPlacement;

- (void)_setItems:(NSArray <__kindof TBTabBarItem *> *)items;

- (void)_setSelectedIndex:(NSUInteger)selectedIndex quietly:(BOOL)quietly;

- (__kindof TBTabBarButton *)_makeButtonWithItem:(__kindof TBTabBarItem *)item NS_SWIFT_NAME(makeButton(withItem:));

- (NSArray<__kindof TBTabBarButton *> *)_buttons;

- (void)_addButton:(__kindof TBTabBarButton *)button;

- (void)_insertButton:(__kindof TBTabBarButton *)button atIndex:(NSUInteger)index;

- (void)_setButtonEnabled:(BOOL)enabled atIndex:(NSUInteger)index;

- (void)_setNormalImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

- (void)_setSelectedImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

- (void)_setNotificationIndicatorImage:(UIImage *)image forButtonAtIndex:(NSUInteger)index;

- (void)_setNotificationIndicatorHidden:(BOOL)hidden forButtonAtIndex:(NSUInteger)index;

- (void)_setAdditionalContentInsets:(UIEdgeInsets)additionalContentInsets;

- (void)_setVisible:(BOOL)visible;

- (void)_prepareForTransitionToPlacement:(TBTabBarControllerTabBarPlacement)preferredTabBarPlacement;

@end

NS_ASSUME_NONNULL_END
