//
//  TBDummyBar.h
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

#if SWIFT_PACKAGE
#import "TBSimpleBar.h"
#else
#import <TBTabBarController/TBSimpleBar.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract A custom bar used to fill the void between the navigation bar and vertical tab bar.
 * @discussion TBDummyBar is a subclass of TBSimpleBar and provides a placeholder for a custom subview.
 * The default content insets for the TBDummyBar is {0.0, 0.0, 6.0, 0.0}.
 */
@interface TBDummyBar : TBSimpleBar

/**
 * @abstract The custom subview that will be displayed within the TBDummyBar.
 */
@property (strong, nonatomic, nullable) __kindof UIView *subview;

@end

NS_ASSUME_NONNULL_END
