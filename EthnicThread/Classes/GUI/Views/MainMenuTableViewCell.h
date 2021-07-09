//
//  MainMenuTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 3/3/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel      *lblText;

- (void)setBadgesNumber:(NSInteger)badges;
@end
