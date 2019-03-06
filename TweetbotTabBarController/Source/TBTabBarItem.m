//
//  TBTabBarItem.m
//  TBTabBarController
//
//  Created by Timur Ganiev on 03/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

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


- (instancetype)initWithImage:(UIImage *)image {
    
    self = [self initWithImage:image selectedImage:nil];
    
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
