//
//  TBTabBarItem.m
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

#import "TBTabBarItem.h"

@implementation TBTabBarItem

#pragma mark - Public

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self tb_commonInit];
    }
    
    return self;
}


- (instancetype)initWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    
    self = [super init];
    
    if (self) {
        self.image = image;
        self.selectedImage = selectedImage;
        [self tb_commonInit];
    }
    
    return self;
}


#pragma mark - Private

- (void)tb_commonInit {
    
    self.enabled = true;
}

@end
