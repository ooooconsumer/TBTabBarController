//
//  ToggleTableViewCell.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "ToggleTableViewCell.h"

@implementation ToggleTableViewCell

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)initWithText:(NSString *)text enabled:(BOOL)enabled {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self _configureWithText:text enabled:enabled];
    }
    
    return self;
}

#pragma mark Interface

- (void)addTarget:(id)target action:(SEL)action {
    
    UISwitch *switchView = (UISwitch *)self.accessoryView;
    
    [switchView addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Private

#pragma mark Setup

- (void)_configureWithText:(NSString *)text enabled:(BOOL)enabled {
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    [switchView setOn:enabled];
    
    self.accessoryView = switchView;
    
    if (@available(iOS 14.0, *)) {
        UIListContentConfiguration *config = [UIListContentConfiguration subtitleCellConfiguration];
        config.text = text;
        self.contentConfiguration = config;
    } else {
        self.textLabel.text = text;
    }
}

@end
