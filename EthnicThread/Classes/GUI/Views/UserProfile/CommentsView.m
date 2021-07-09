//
//  CommentReviewView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/21/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "CommentsView.h"
#import "CommentTableViewCell.h"
#import "NSMutableArray+SWUtilityButtons.h"

@interface CommentsView() <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, CommentTableViewCellDelegate> {
    CGFloat tableViewHeight;
}
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView  *aiLoading;
@property (nonatomic, assign) IBOutlet UITableView          *tableView;
@property (strong, nonatomic) CommentTableViewCell          *offScreenCell;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcLeadingTableView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTrailingTableView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightTableView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTopTableView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomTableView;
@end

@implementation CommentsView

- (void)initVariables {
    [super initVariables];
}

- (void)initGUI {
    [super initGUI];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 68;
    self.lcHeightTableView.constant = 0;
    [self startAnimating];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (CGFloat)calculateHeightOfCellForRowIndex:(NSInteger)rowIndex {
    if (!self.offScreenCell) {
        self.offScreenCell = [[[UINib nibWithNibName:NSStringFromClass([CommentTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    NSInteger index = 0;
    if (self.comments.count > 0) {
        index = self.comments.count - rowIndex - 1;
    }
    CommentModel *commentModel = [self.comments objectAtIndex:index];
    [self.offScreenCell setCommentToCalculateHeightOfCell:commentModel];
    
//    [self.offScreenCell setNeedsUpdateConstraints];
//    [self.offScreenCell updateConstraintsIfNeeded];
//    [self.offScreenCell setNeedsLayout];
//    [self.offScreenCell layoutIfNeeded];
//    self.offScreenCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.offScreenCell.bounds));
//    [self.offScreenCell setNeedsLayout];
    [self.offScreenCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [self.offScreenCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height += 1;
}

- (void)reloadData {
    self.lcHeightTableView.constant = tableViewHeight;
    [self.tableView reloadData];
}

- (void)hidenLoadMoreButton:(BOOL)hiden {
    [self.btnLoadMore setHidden:hiden];
}

- (CGFloat)updateHeightOfTableView {
    CGFloat height = 0;
    for (int i = 0; i < self.comments.count; i++) {
        height += [self calculateHeightOfCellForRowIndex:i];
    }
    return tableViewHeight = height;
}

- (CGFloat)tableViewHeight {
    return self.lcHeightTableView.constant;
}

- (CGFloat)getMinYOfTableView {
    return self.lcTopTableView.constant;
}

- (CGFloat)viewHeight {
    return self.lcTopTableView.constant + self.lcHeightTableView.constant + self.lcBottomTableView.constant;
}

- (void)startAnimating {
    [self.aiLoading startAnimating];
    [self.btnLoadMore setHidden:YES];
    [self.aiLoading setHidden:NO];
}

- (void)stopAnimating:(BOOL)hideLoadMore {
    [self.aiLoading stopAnimating];
    [self.aiLoading setHidden:YES];
    [self.btnLoadMore setHidden:hideLoadMore];
}

- (BOOL)isAnimating {
    return [self.aiLoading isAnimating];
}

- (NSArray *)rightButtons:(CommentModel *)comment {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if ([comment.owner isMe]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:ORANGE_COLOR title:NSLocalizedString(@"edit", @"")];
        [rightUtilityButtons sw_addUtilityButtonWithColor:PURPLE_COLOR title:NSLocalizedString(@"delete", @"")];
    }
    else if (self.allowDeleteAnyComment) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:PURPLE_COLOR title:NSLocalizedString(@"delete", @"")];
    }
    return rightUtilityButtons;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reviewCellIdentifier = @"CommentCellIdentifier";
    NSInteger index = 0;
    if (self.comments.count > 0) {
        index = self.comments.count - indexPath.row - 1;
    }
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reviewCellIdentifier];
    if (!cell) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([CommentTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.ownerDelegate = self;
    }
    CommentModel *commentModel = [self.comments objectAtIndex:index];
    [cell setRightUtilityButtons:[self rightButtons:commentModel] WithButtonWidth:58.0f];
    [cell setComment:commentModel];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self calculateHeightOfCellForRowIndex:indexPath.row];
//    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(didSelectRowOfComment:)]) {
        [self.delegate didSelectRowOfComment:cell.comment];
    }
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    UIButton *button = [cell.rightUtilityButtons objectAtIndex:index];
    if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"edit", @"")]) {
        if ([self.delegate respondsToSelector:@selector(editComment:)]) {
            [self.delegate editComment:((CommentTableViewCell *)cell).comment];
        }
    }
    else if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"delete", @"")]) {
        if ([self.delegate respondsToSelector:@selector(deleteComment:)]) {
            [self.delegate deleteComment:((CommentTableViewCell *)cell).comment];
        }
    }
}

#pragma mark - CommentTableViewCellDelegate
- (void)openUserProfilePage:(SellerModel *)owner {
    if ([self.delegate respondsToSelector:@selector(openCommenter:)]) {
        [self.delegate openCommenter:owner];
    }
}
@end
