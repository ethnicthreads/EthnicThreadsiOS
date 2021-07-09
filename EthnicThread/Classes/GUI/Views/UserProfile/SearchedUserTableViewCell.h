//
//  SearchedUserTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/27/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchedUserTableViewCell.h"
#import "BasicInfoUserModel.h"

@interface SearchedUserTableViewCell : UITableViewCell
@property (nonatomic, strong) BasicInfoUserModel     *searchUser;
@end
