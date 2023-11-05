//
//  TBTabBarController+Private.h
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

#import <UIKit/UIKit.h>

@class TBTabBarItem;

NS_ASSUME_NONNULL_BEGIN

@interface TBTabBarController (Private)

/**
 * @abstract Specifies the preferred tab bar placement for a given horizontal size class and view size.
 * @discussion Use this method to set the preferred tab bar placement based on specific conditions. 
 * It allows you to customize the tab bar placement behavior.
 * @param horizontalSizeClass The horizontal size class.
 * @param size The view size.
 */
- (void)_specifyPreferredTabBarPlacementForHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass size:(CGSize)size NS_SWIFT_NAME(specifyPreferredTabBarPlacement(for:size:));

/**
 * @abstract Changes the specified tab bar item to a new tab bar item.
 * @discussion This method is used to replace one tab bar item with another. It allows you to modify the tab bar items dynamically.
 * @param item The tab bar item to be replaced.
 * @param newItem The new tab bar item to be used.
 */
- (void)_changeItem:(TBTabBarItem *)item toItem:(TBTabBarItem *)newItem NS_SWIFT_NAME(changeItem(_:to:));

/**
 * @abstract Returns the currently visible view controller.
 * @discussion This method is used to retrieve the currently visible view controller in the tab bar controller.
 * @return The currently visible view controller, if available.
 */
- (__kindof UIViewController *_Nullable)_visibleViewController NS_SWIFT_NAME(visibleViewController());

@end

NS_ASSUME_NONNULL_END
