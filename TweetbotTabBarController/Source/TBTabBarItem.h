//
//  TBTabBarItem.h
//  TBTabBarController
//
//  Copyright (c) 2019 Timur Ganiev
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

NS_ASSUME_NONNULL_BEGIN

@interface TBTabBarItem : NSObject

@property (strong, nonatomic, nullable) UIImage *image;

@property (strong, nonatomic, nullable) UIImage *selectedImage;

/** @brief Describes whether item should be enabled or disabled. Default is YES */
@property (assign, nonatomic, getter = isEnabled) BOOL enabled;

/** @brief By setting this value to YES, a tab bar will show a small dot next to the tab icon that indicates something has happened. Default is NO */
@property (assign, nonatomic) BOOL showDot;

- (instancetype)initWithImage:(nullable UIImage *)image selectedImage:(nullable UIImage *)selectedImage;

@end

NS_ASSUME_NONNULL_END
