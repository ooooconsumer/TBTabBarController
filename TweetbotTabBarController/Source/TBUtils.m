//
//  TBUtils.m
//  TweetbotTabBarController
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

#import "TBUtils.h"

#import <objc/runtime.h>

UIImage * TBResizeImageToPreferredSize(UIImage *image, CGSize preferredSize) {
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:preferredSize];
    UIImage *resizedImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:(CGRect){CGPointZero, preferredSize}];
    }];
    
    return resizedImage;
}

CGFloat TBFloorValueWithScale(CGFloat value, CGFloat scale) {
    // This solution was borrowed from Texture https://github.com/TextureGroup/Texture
    return floor((value + FLT_EPSILON) * scale) / scale;
}

BOOL TBSubclassOverridesMethod (Class superclass, Class subclass, SEL selector) {
    return class_getInstanceMethod(superclass, selector) != class_getInstanceMethod(subclass, selector);
}
