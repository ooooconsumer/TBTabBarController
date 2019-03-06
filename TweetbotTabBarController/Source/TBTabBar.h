//
//  TBTabBar.h
//  TBTabBarController
//
//  Created by Timur Ganiev on 03/02/2019.
//  Copyright © 2019 Timur Ganiev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBTabBar, TBTabBarItem, TBTabBarButton;

typedef NS_ENUM(NSInteger, TBTabBarLayoutOrientation) {
    TBTabBarLayoutOrientationHorizontal,
    TBTabBarLayoutOrientationVertical
};

NS_ASSUME_NONNULL_BEGIN

@protocol TBTabBarDelegate <NSObject>

@optional

- (void)tabBar:(TBTabBar *)tabBar didSelectItem:(TBTabBarItem *)item;

@end

@interface TBTabBar : UIView

/** @brief Items to display. */
@property (weak, nonatomic, nullable) NSArray <TBTabBarItem *> *items;

/** @brief The color of the separator. Default is black with 0.3 alpha. */
@property (copy, nonatomic, nullable) UIColor *separatorColor;

/** @brief When a tab is not selected, its tint color. Default is 0.6 white. */
@property (strong, nonatomic, null_resettable) UIColor *defaultTintColor;

/** @brief When a tab is selected, its tint color. Default is nil. */
@property (strong, nonatomic, nullable) UIColor *selectedTintColor;

/** @brief The currently selected tab index. */
@property (assign, nonatomic) NSUInteger selectedIndex;

/** @brief Additional area around content. Affects the size of the tab bar. Default is UIEdgeInsetsZero. */
@property (assign, nonatomic) UIEdgeInsets contentInsets;

@property (weak, nonatomic, nullable) id <TBTabBarDelegate> delegate;

@property (assign, nonatomic, readonly) TBTabBarLayoutOrientation layoutOrientation;

- (instancetype)initWithLayoutOrientation:(TBTabBarLayoutOrientation)layoutOrientation;

@end

NS_ASSUME_NONNULL_END
