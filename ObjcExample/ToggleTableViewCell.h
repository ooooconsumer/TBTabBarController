//
//  ToggleTableViewCell.h
//  ObjcExample
//
//  Created by Timur Ganiev on 08.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToggleTableViewCell : UITableViewCell

- (instancetype)initWithText:(NSString *)text enabled:(BOOL)enabled;

- (void)addTarget:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
