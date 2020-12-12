//
//  SettingsViewController.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "SettingsViewController.h"

#import <TBTabBarController/TBTabBarControllerFramework.h>

#import "ToggleTableViewCell.h"

@implementation SettingsViewController {
    
    NSArray<UITableViewCell *> *_cells;
    
    BOOL _isUpdatingTabBarPosition;
}

#pragma mark - Public

#pragma mark Lifecycle

- (instancetype)init {
    
    if (@available(iOS 13.0, *)) {
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    } else {
        self = [super initWithStyle:UITableViewStyleGrouped];
    }
    
    return self;
}

#pragma mark Overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    ToggleTableViewCell *hidesTabBarOnPushSettingCell = [[ToggleTableViewCell alloc] initWithText:@"Hides tab bar on push" enabled:self.tb_hidesTabBarWhenPushed];
    [hidesTabBarOnPushSettingCell addTarget:self action:@selector(_setHideTabBarOnPush:)];
    
    ToggleTableViewCell *showsNotificationIndicatorCell = [[ToggleTableViewCell alloc] initWithText:@"Shows notification indicator" enabled:self.navigationController.tb_tabBarItem.showsNotificationIndicator];
    [showsNotificationIndicatorCell addTarget:self action:@selector(_setShowsNotificationIndicator)];
    
    _cells = @[hidesTabBarOnPushSettingCell, showsNotificationIndicatorCell];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return _cells[indexPath.row];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0;
}

#pragma mark - Private

#pragma mark Actions

- (void)_setHideTabBarOnPush:(UISwitch *)sender {
    
    if (_isUpdatingTabBarPosition) {
        [sender setOn:!sender.isOn animated:true];
        return;
    }
    
    _isUpdatingTabBarPosition = true;
    
    self.tb_hidesTabBarWhenPushed = !self.tb_hidesTabBarWhenPushed;
    
    [UIView animateWithDuration:0.35 delay:0.0 options:7 << 16 animations:^{
        [self.navigationController.tb_tabBarController beginUpdateTabBarPosition];
    } completion:^(BOOL finished) {
        [self.navigationController.tb_tabBarController endUpdateTabBarPosition];
        self->_isUpdatingTabBarPosition = false;
    }];
}

- (void)_setShowsNotificationIndicator {
    
    self.navigationController.tb_tabBarItem.showsNotificationIndicator = !self.navigationController.tb_tabBarItem.showsNotificationIndicator;
}

@end
