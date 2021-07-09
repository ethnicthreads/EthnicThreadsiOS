//
//  CommentReviewTableViewCell.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/21/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"
#import "SWTableViewCell.h"

@protocol CommentTableViewCellDelegate <NSObject>
- (void)openUserProfilePage:(SellerModel *)owner;
@end

@interface CommentTableViewCell : SWTableViewCell
@property (nonatomic, strong) CommentModel      *comment;
@property (nonatomic, assign) id <CommentTableViewCellDelegate> ownerDelegate;
- (void)setCommentToCalculateHeightOfCell:(CommentModel *)comment;
@end
