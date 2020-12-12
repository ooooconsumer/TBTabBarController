//
//  TabViewController.m
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import "TabViewController.h"

#import <TBTabBarController/TBTabBarControllerFramework.h>

#import "SettingsViewController.h"

@implementation TabViewController

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
    
    self.navigationController.navigationBar.prefersLargeTitles = true;
    self.navigationItem.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.navigationController.tb_tabBarItem.showsNotificationIndicator = false;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSString *title = [NSString stringWithFormat:@"Cell at index: %ld", indexPath.row];
    NSString *subtitle = @"Tap to show settings";
    
    if (@available(iOS 14.0, *)) {
        UIListContentConfiguration *config = [UIListContentConfiguration subtitleCellConfiguration];
        config.text = title;
        config.secondaryText = subtitle;
        cell.contentConfiguration = config;
    } else {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subtitle;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    settingsViewController.tb_hidesTabBarWhenPushed = true;
    
    [self.navigationController pushViewController:settingsViewController animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0;
}

@end
