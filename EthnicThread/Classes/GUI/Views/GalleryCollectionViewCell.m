//
//  GalleryCollectionViewCell.m
//  EthnicThread
//
//  Created by DuyLoc on 4/7/17.
//  Copyright © 2017 CodeBox Solutions Ltd. All rights reserved.
//

#import "GalleryCollectionViewCell.h"
#import "UIImageView+Custom.h"
#import "AvatarButton.h"
#import "UIButton+Custom.h"

@interface GalleryCollectionViewCell() <CBImageViewProtocol>
@property (strong, nonatomic) IBOutlet AvatarButton *btnAvatar;
@property (strong, nonatomic) IBOutlet UIButton *btnFollow;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

@property (strong, nonatomic) IBOutlet UIView *vStatContainer;
@property (strong, nonatomic) IBOutlet UIView *vAvatarContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIView *vContainer;
@property (strong, nonatomic) IBOutlet UIView *vMenu;
@property (strong, nonatomic) IBOutlet UIButton *btnUnavailable;
@property (strong, nonatomic) IBOutlet UIButton *btnEditItem;
@property (strong, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet UILabel *lblNumOfLikes;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;

@property (nonatomic, assign) IBOutlet UILabel              *lbPrice;
@property (nonatomic, assign) IBOutlet UILabel              *lbPurchares;
@property (nonatomic, assign) IBOutlet UIView               *vPriceContainer;
@end

@implementation GalleryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.btnAvatar setTitle:nil forState:UIControlStateNormal];
    [self.imItem setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnFollow setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [self.lblLocation setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
    [self.imItem setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOpenImage:)];
    [self.imItem addGestureRecognizer:tapImage];
    [self setBackgroundColor:GRAY_COLOR];
    [self.btnEdit setHidden:YES];
    [self.btnLike setImage:[UIImage imageNamed:@"white_like_icon"] forState:UIControlStateNormal];
    [self.btnLike setImage:[UIImage imageNamed:@"big_purple_heart"] forState:UIControlStateSelected];
    // Initialization code
}

- (IBAction)handleLikeButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(likeItem:)]) {
        [self.delegate likeItem:self.item];
    }
}

- (IBAction)btnEditItem:(id)sender {
    if (self.vContainer.frame.origin.x == 0) {
        // if is closing
        CGRect rect = self.vContainer.frame;
        rect.origin.x = - self.vMenu.frame.size.width;
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.vContainer.frame = rect;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    else {// if is openning
        CGRect rect = self.vContainer.frame;
        rect.origin.x = 0;
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.vContainer.frame = rect;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (void)allowEdit {
    [self.btnEdit setHidden:NO];
}

- (CGFloat)cellHeight {
    return self.vAvatarContainer.frame.size.height + self.lcHeightImItem.constant;
}
- (IBAction)handleBtnFollow:(id)sender {
    if (self.item.sellerModel.followed || [self.item isMine]) {
        if ([self.delegate respondsToSelector:@selector(didOpenSellerInfo:)]) {
            [self.delegate didOpenSellerInfo:self.item];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(updateSellerFollowStatus:)]) {
            [self.delegate updateSellerFollowStatus:self.item];
        }
    }
}
- (IBAction)handleBtnAvatar:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didOpenSellerInfo:)]) {
        [self.delegate didOpenSellerInfo:self.item];
    }
}

- (void)handleOpenImage:(UITapGestureRecognizer *)tapGesture {
    if ([self.delegate respondsToSelector:@selector(didOpenItem:sender:)]) {
        [self.delegate didOpenItem:self.item sender:self];
    }
}

- (IBAction)handleEditItemButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editItem:)]) {
        [self.delegate editItem:self.item];
    }
}

- (IBAction)handleUnavailableButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(updateItemStatus:withStatus:)]) {
        [self.delegate updateItemStatus:self.item withStatus:(!self.btnUnavailable.selected) ? STATUS_UNAVAILABLE : @""];
    }
}

- (IBAction)handleRemoveButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(removeItem:)]) {
        [self.delegate removeItem:self.item];
    }
}

- (UIImage *)getAvatarImage {
    return self.btnAvatar.currentImage;
}

- (UIImage *)getFirstImage {
    return self.imItem.image;
}

- (void)configureCellForItem:(ItemModel *)item {
    [self.imItem loadImageForUrl:[item getFirstImageUrl]];
    [self.imItem setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnAvatar loadImageForUrl:[item.sellerModel avatar]];
    self.lblLocation.text = [self.item getLocation];
    [self.btnFollow setTitle:[self.item getSellerFollowStatus] forState:UIControlStateNormal];
    [self.btnEdit setHidden:!self.isMyPosting];
    [self.btnUnavailable setSelected:[item isUnavallable]];
    if ([self.item isService]) {
        [self.lbPrice setHidden:YES];
        [self.vPriceContainer setHidden:YES];
    }
    else {
        [self.lbPrice setHidden:(self.item.price == 0)];
        self.lbPrice.text = [self.item getPriceWithCurencyText];
        self.lbPurchares.text = [self.item getPurchasesText];
        if (self.item.price == 0) {
            self.lbPrice.text = @"";
        }
        
        if ([[self.item getPurchasesText] isEqualToString:@"For Fun"]) {
            [self.lbPurchares setText:NSLocalizedString(@"my_style", @"")];
        } else {
            [self.vPriceContainer setHidden:NO];
        }
    }
    [self.btnLike setSelected:item.liked];
    NSString *numOfLikes = [NSString stringWithFormat:@"%ld", item.total_likes];
    if (item.total_likes > 9) {
        numOfLikes = @"9+";
    }
    self.lblNumOfLikes.text = numOfLikes;
}

- (void)cbImageView:(UIImageView *)cbImageView didFinishDownloadingImage:(UIImage *)aDownloadedImage {
    DLog(@"Finish Load Image:%@", aDownloadedImage);
}

- (void)cbImageView:(UIImageView *)cbImageView didFinishDownloadingImage:(UIImage *)aDownloadedImage downloadFailUrl:(NSString *)url {
    DLog(@"Finish Load Image:%@", aDownloadedImage);  
}
@end
