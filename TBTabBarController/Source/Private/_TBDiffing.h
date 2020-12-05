//
//  _TBDiffing.h
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

#ifndef _TBDiffing_h
#define _TBDiffing_h

#include <Foundation/Foundation.h>

@class TBTabBarItemChange, TBTabBarItem;

// This is a Swift's version of the Myers Diff Algorithm written in C language but much slower in terms of performance and yet less demanding on memory.
// You can read more about it's implementation here: https://medium.com/better-programming/how-collection-diffing-works-in-swift-316c14775d31
// A Swift's version of the Myers Diff Algorithm is placed here: https://github.com/apple/swift/blob/9de3db97bdbabc503a2445ceb2f6699755aace23/stdlib/public/core/Diffing.swift

NSArray<TBTabBarItemChange *> *_TBDiffingCalculateChanges(NSArray<TBTabBarItem *> *from, NSArray<TBTabBarItem *> *to);

#endif /* _TBDiffing_h */
