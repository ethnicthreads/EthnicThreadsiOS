//
//  TagTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/16/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagTableViewCellDelegate <NSObject>
- (void)updateTagStatus:(id)sender;
@end

@interface TagTableViewCell : UITableViewCell
@property (nonatomic, assign) id <TagTableViewCellDelegate> delegate;
@property (nonatomic, assign) IBOutlet UIButton     *btnCheck;
@property (nonatomic, assign) IBOutlet UILabel      *lblValue;
@end
