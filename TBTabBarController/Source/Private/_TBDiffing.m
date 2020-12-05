//
//  _TBDiffing.c
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

#include "_TBDiffing.h"

#include "_TBTriangularMatrix.h"
#import "TBTabBarItemsDifference.h"
#import "TBTabBarItemChange.h"

#pragma mark - Private

static inline short int _TBDiffingPlus(short int lhs, short int rhs) {
    
    short int const result = lhs + rhs;
    
    if (result > SHRT_MAX) {
        return SHRT_MIN + rhs - 1;
    } else {
        return result;
    }
}

static inline short int _TBDiffingMinus(short int lhs, short int rhs) {
    
    short int const result = lhs - rhs;
    
    if (result < SHRT_MIN) {
        return SHRT_MAX - rhs + 1;
    } else {
        return result;
    }
}

_TBTriangularMatrix *_TBDiffingDescent(NSArray *a, NSArray *b, int *count) {
    
    short int const n = (short int)a.count;
    short int const m = (short int)b.count;
    short int const max = n + m;
    
    _TBTriangularMatrix v = _TBTriangularMatrixWithLargestIndex(1);
    _TBTriangularMatrixSetValue(v, 0, 1);
    
    _TBTriangularMatrix *result = malloc(sizeof(_TBTriangularMatrix) * (max + 1));
    
    short int x = 0, y = 0;
    
    for (short int d = 0; d <= max; d += 1) {
        _TBTriangularMatrix prev_v = v;
        result[d] = v;
        *count = *count + 1;
        v = _TBTriangularMatrixWithLargestIndex(d); // malloc is a real bottleneck in here. But for our usage is ok
        for (short int k = -d; k <= d; k += 2) {
            if (k == -d) {
                x = _TBTriangularMatrixGetValueAtIndex(prev_v, _TBDiffingPlus(k, 1));
            } else {
                short int const km = _TBTriangularMatrixGetValueAtIndex(prev_v, _TBDiffingMinus(k, 1));
                if (k != d) {
                    short int const kp = _TBTriangularMatrixGetValueAtIndex(prev_v, _TBDiffingPlus(k, 1));
                    if (km < kp) {
                        x = kp;
                    } else {
                        x = _TBDiffingPlus(km, 1);
                    }
                } else {
                    x = _TBDiffingPlus(km, 1);
                }
            }
            y = _TBDiffingMinus(x, k);
            while (x < n && y < m) {
                if (![a[x] isEqual:b[y]]) {
                    break;
                }
                x = _TBDiffingPlus(x, 1);
                y = _TBDiffingPlus(y, 1);
            }
            _TBTriangularMatrixSetValue(v, x, k);
            if (x >= n && y >= m) {
                break;
            }
        }
        if (x >= n && y >= m) {
            break;
        }
    }
    
    _TBTriangularMatrixRelease(v);
    
    return result;
}

NSArray<TBTabBarItemChange *> *_TBDiffingFormChanges(NSArray *a, NSArray *b, _TBTriangularMatrix *trace, int count) {
    
    if (count == 0) {
        return @[];
    }
    
    NSMutableArray<TBTabBarItemChange *> *changes = [NSMutableArray arrayWithCapacity:(NSUInteger)count];
    
    short int x = (short int)a.count, y = (short int)b.count;
    short int aIndex = 0, bIndex = 0;
    
    for (short int d = _TBDiffingMinus(count, 1); d > 0; d -= 1) {
        _TBTriangularMatrix v = trace[d];
        short int const k = _TBDiffingMinus(x, y);
        short int prev_k = (k == -d || (k != d && _TBTriangularMatrixGetValueAtIndex(v, _TBDiffingMinus(k, 1)) < _TBTriangularMatrixGetValueAtIndex(v, _TBDiffingPlus(k, 1)))) ? _TBDiffingPlus(k, 1) : _TBDiffingMinus(k, 1);
        short int prev_x = _TBTriangularMatrixGetValueAtIndex(v, prev_k);
        short int prev_y = _TBDiffingMinus(prev_x, prev_k);
        while (x > prev_x && y > prev_y) {
            x = _TBDiffingMinus(x, 1);
            y = _TBDiffingMinus(y, 1);
        }
        if (y != prev_y) {
            [changes insertObject:[[TBTabBarItemChange alloc] initWithItem:b[prev_y] type:TBTabBarItemChangeInsert index:prev_y] atIndex:bIndex];
        } else {
            [changes insertObject:[[TBTabBarItemChange alloc] initWithItem:a[prev_x] type:TBTabBarItemChangeRemove index:prev_x] atIndex:aIndex];
            aIndex += 1;
            bIndex += 1;
        }
        x = prev_x;
        y = prev_y;
        _TBTriangularMatrixRelease(v);
    }
    
    _TBTriangularMatrixRelease(trace[0]); // Release the first matrix in the array since the loop does not actually touch it
    
    free(trace);
    
    return [changes copy];
}

#pragma mark - Public

NSArray<TBTabBarItemChange *> *_TBDiffingCalculateChanges(NSArray<TBTabBarItem *> *from, NSArray<TBTabBarItem *> *to) {
    
    int count = 0;
    
    return _TBDiffingFormChanges(from, to, _TBDiffingDescent(from, to, &count), count);
}
