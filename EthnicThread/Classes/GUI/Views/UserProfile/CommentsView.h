//
//  CommentReviewView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/21/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@protocol CommentsViewDelegate <NSObject>
- (void)openCommenter:(SellerModel *)commenter;
- (void)didSelectRowOfComment:(CommentModel *)comment;
- (void)editComment:(CommentModel *)comment;
- (void)deleteComment:(CommentModel *)comment;
@end

@interface CommentsView : BaseView
@property (nonatomic, assign) IBOutlet UIButton             *btnLoadMore;
@property (nonatomic, assign) IBOutlet UILabel              *lblNumberOfComment;
@property (nonatomic, strong) NSMutableArray                *comments;
@property (nonatomic, assign) id <CommentsViewDelegate>     delegate;
@property (nonatomic, assign) BOOL                          allowDeleteAnyComment; // default NO

- (CGFloat)updateHeightOfTableView;
- (CGFloat)getMinYOfTableView;
- (CGFloat)tableViewHeight;
- (CGFloat)viewHeight;
- (void)startAnimating;
- (void)stopAnimating:(BOOL)hideLoadMore;
- (BOOL)isAnimating;
- (void)reloadData;
@end
