//
//  ItemTableViewCell.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/28/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "Constants.h"
#import "AvatarButton.h"
#import "LikersView.h"

@interface ItemTableViewCell() <SupViewOfMoreInfoDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnSeeOtherPost;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;

@property (strong, nonatomic) IBOutlet UIView *vDesc;

@property (nonatomic, assign) IBOutlet UIView               *vContainer;
@property (nonatomic, assign) IBOutlet UIView               *vMenu;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditItem;
@property (nonatomic, assign) IBOutlet UIButton             *btnUnavailable;
@property (nonatomic, assign) IBOutlet UIButton             *btnRemove;

@property (nonatomic, assign) IBOutlet UILabel              *lbTitle;
@property (nonatomic, assign) IBOutlet UIButton             *btnForGender;
@property (nonatomic, assign) IBOutlet UIButton             *btnSize;
@property (nonatomic, assign) IBOutlet UIButton             *btnLocation;
@property (nonatomic, assign) IBOutlet UIButton             *btnSellerName;
@property (nonatomic, assign) IBOutlet UIButton             *btnFollowers;
@property (nonatomic, assign) IBOutlet UIButton             *btnLikeNumber;

@property (nonatomic, assign) IBOutlet UIButton             *btnMenu;
@property (nonatomic, assign) IBOutlet UIButton             *btnLike;
@property (nonatomic, assign) IBOutlet UIButton             *btnWishlist;
@property (nonatomic, assign) IBOutlet UIButton             *btnShare;
@property (nonatomic, assign) IBOutlet UIButton             *btnComment;
@property (nonatomic, assign) IBOutlet UIButton             *btnMoreInfo;
@property (nonatomic, assign) IBOutlet UIButton             *btnBuyNow;
@property (strong, nonatomic) IBOutlet UILabel *lblFollowers;

@property (nonatomic, assign) IBOutlet UIView               *vPriceContainer;
@property (nonatomic, assign) IBOutlet UILabel              *lbPrice;
@property (nonatomic, assign) IBOutlet UILabel              *lbPurchares;
@property (nonatomic, assign) IBOutlet UIView               *vPriceLine;
@property (nonatomic, assign) IBOutlet UIImageView          *imvItemStatus;
@property (nonatomic, assign) IBOutlet UILabel              *lbItemStatus;
@property (nonatomic, assign) IBOutlet AvatarButton         *btnSellerAvatar;
@property (nonatomic, assign) IBOutlet UIButton             *btnRemoveFromWishlist;
@property (nonatomic, assign) IBOutlet LikersView           *vLikers;
@property (strong, nonatomic) IBOutlet UILabel *lblSizeTag;

@property (nonatomic, assign) IBOutlet UIView               *vTagsContainer;
@property (nonatomic, assign) IBOutlet UILabel              *lblTags;
@property (nonatomic, assign) IBOutlet UIButton             *btnInAppropriate;

@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightLocation;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightNumOfLikeView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidthPriceLabel;
@property (nonatomic, strong) UIButton *btnShowMore;

- (IBAction)handleSellerAvatarButton:(id)sender;
- (IBAction)handleLikeButton:(id)sender;
- (IBAction)handleWishlistButton:(id)sender;
- (IBAction)handleShareButton:(id)sender;
- (IBAction)handleCommentButton:(id)sender;
- (IBAction)handleMoreInfoButton:(id)sender;
@end

@implementation ItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.btnComment.layer.borderColor = BLACK_COLOR_TEXT.CGColor;
    self.btnComment.layer.borderWidth = 1;
    self.btnComment.titleLabel.textColor = BLACK_COLOR_TEXT;
    self.btnMoreInfo.layer.borderColor = PURPLE_COLOR.CGColor;
    self.btnMoreInfo.layer.borderWidth = 1;
    self.btnMoreInfo.titleLabel.textColor = PURPLE_COLOR;
    self.btnBuyNow.layer.borderColor = ORANGE_COLOR.CGColor;
    self.btnBuyNow.layer.borderWidth = 1;
    self.btnBuyNow.titleLabel.textColor = ORANGE_COLOR;
    self.hasRightMenu = NO;
    self.inWishlistPage = NO;
    self.btnSellerName.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.btnSellerName.titleLabel.numberOfLines = 2;
    [self.btnSellerName setTintColor:[UIColor blackColor]];
    self.vLikers.delegate = self;
    [self.btnRemoveFromWishlist setHidden:YES];
    [self.btnSeeOtherPost setTitle:NSLocalizedString(@"see_other_post", @"") forState:UIControlStateNormal];
    [self.btnSeeOtherPost.titleLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
    self.lblFollowers.textColor = [UIColor darkGrayColor];
    [self.lblFollowers setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapShowFollowers)];
    [self.lblFollowers addGestureRecognizer:tapGesture];
    [self.btnFollowers setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
}

- (void)didTapShowFollowers {
    if ([self.delegate respondsToSelector:@selector(openFollowersPage:)]) {
        [self.delegate openFollowersPage:self.itemModel.sellerModel];
    }
}

- (void)updateConstraints {
    self.lcHeightLocation.constant = ([self.itemModel getLocation].length == 0) ? 0 : 21;
    self.lcHeightNumOfLikeView.constant = (self.itemModel.total_likes == 0) ? 3 : 28;
    if ([self.lbPrice isHidden]) {
        self.lcWidthPriceLabel.constant = 0;
    }
    else {
        self.lcWidthPriceLabel.constant = 79;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.hasRightMenu) {
        self.btnUnavailable.selected = [self.itemModel isUnavallable];
    }
    if (self.hasRightMenu) {
        [self.lbItemStatus setHidden:YES];
        [self.imvItemStatus setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setItemModel:(ItemModel *)itemModel {
    _itemModel = itemModel;
    [self.scvGallery setImages:[self.itemModel getAllImageUrls] andSize:GALLERY_SCROLLVIEW_SIZE];
    
    //set text values
    self.lbTitle.text = self.itemModel.name;
    CGFloat lableHeight = [Utils calculateHeightForString:self.lbTitle.text withWidth:[UIScreen mainScreen].bounds.size.width andFont:self.lbTitle.font];
    UserModel *user = itemModel.sellerModel;
    if (![user isFullDesc]) {
        self.lbTitle.numberOfLines = 1;
//        [self addMoreButton];
        if (lableHeight > self.lbTitle.frame.size.height) {
            [self addMoreButton];
        } else {
            [self.btnShowMore removeFromSuperview];
        }
    } else {
        self.lbTitle.numberOfLines = 0;
    }
    
    [self.btnLocation setTitle:[self.itemModel getLocation] forState:UIControlStateNormal];
    [self.btnLocation setHidden:[self.itemModel getLocation].length == 0];
    [self.btnLikeNumber setTitle:[self.itemModel getNumberOfLikesText] forState:UIControlStateNormal];
    self.btnFollowers.hidden = self.itemModel.sellerModel.followed;
    
    if ([self.itemModel isService]) {
        [self.btnSize setHidden:YES];
        [self.btnForGender setHidden:YES];
        NSString *tags = [self.itemModel getDisplayedTags];
        [self.vTagsContainer setHidden:(tags.length == 0)];
        self.lblTags.text = tags;
        
        [self.lbPrice setHidden:YES];
        [self.vPriceContainer setHidden:YES];
    }
    else {
        [self.vTagsContainer setHidden:YES];
        [self.btnSize setHidden:NO];
        [self.btnSize setTitle:[self.itemModel getSizeString] forState:UIControlStateNormal];
        [self.btnForGender setHidden:NO];
        [self.btnForGender setTitle:[self.itemModel getGenderString] forState:UIControlStateNormal];
        [self.btnForGender setImage:[self.itemModel getGenderImage] forState:UIControlStateNormal];
        
        [self.lbPrice setHidden:(self.itemModel.price == 0)];
        self.lbPrice.text = [self.itemModel getPriceWithCurencyText];
        self.lbPurchares.text = [self.itemModel getPurchasesText];
        
        if ([[self.itemModel getPurchasesText] isEqualToString:@"For Fun"]) {
            [self.lbPurchares setText:NSLocalizedString(@"my_style", @"")];
        } else {
            [self.vPriceContainer setHidden:NO];
        }
    }
    
    self.lbItemStatus.font = [UIFont systemFontOfSize:[self.itemModel isUnavallable] ? SMALL_FONT_SIZE : MEDIUM_FONT_SIZE];
    self.lbItemStatus.text = [self.itemModel getStatusString];
    if (self.lbItemStatus.text.length > 0) {
        [self.lbItemStatus setHidden:NO];
        [self.imvItemStatus setHidden:NO];
    }
    else {
        [self.lbItemStatus setHidden:YES];
        [self.imvItemStatus setHidden:YES];
    }
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:[self.itemModel getCommentTextAndNumber]];
    NSInteger length = commentString.length - NSLocalizedString(@"comment", @"").length;
    [commentString addAttribute:NSForegroundColorAttributeName
                          value:PURPLE_COLOR
                          range:NSMakeRange(commentString.length - length, length)];
    [commentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(commentString.length - length, length)];
    [self.btnComment setAttributedTitle:commentString forState:UIControlStateNormal];
    
    if (self.itemModel.sellerModel.followed) {
        [self.btnFollowers setTitle:NSLocalizedString(@"followed", @"") forState:UIControlStateNormal];
    } else {
        [self.btnFollowers setTitle:NSLocalizedString(@"follow_me", @"") forState:UIControlStateNormal];
    }
    self.lblFollowers.text = [self.itemModel.sellerModel getFollowersText];
    self.lblFollowers.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
    
    self.lblSizeTag.text = [NSString stringWithFormat:@"%@, %@", self.itemModel.getGenderString, self.itemModel.getSizeString];
//    if (!self.itemModel.sellerModel.followed && ![self.itemModel.sellerModel isMe]) {
//        NSString *displayName = nil;
//        if ([self.itemModel.sellerModel.display_name isEqualToString:@""] || self.itemModel.sellerModel.display_name == nil) {
//            displayName = self.itemModel.sellerModel.first_name;
//        } else {
//            displayName = self.itemModel.sellerModel.display_name;
//        }
//        NSString *followSeller = displayName;
//        [self.btnSellerName setTitle:followSeller forState:UIControlStateNormal];
//    } else {
//    }
    NSString *displayName = [NSString stringWithFormat:@"%@, %@", self.itemModel.sellerModel.getDisplayName, self.itemModel.city];
    [self.btnSellerName setTitle:displayName forState:UIControlStateNormal];
    
    [self updateLikeUI:self.itemModel.liked];
    [self updateWishlistUI:self.itemModel.in_wish_list];
    
    [self.btnLikeNumber setHidden:self.itemModel.total_likes == 0];
    [self.vLikers setHidden:self.itemModel.latest_likers.count == 0];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (self.itemModel.latest_likers.count > 0) {
        self.vLikers.itemModel = self.itemModel;
    }
    
    [self.btnInAppropriate setSelected:self.itemModel.flagged];
}

- (void)addMoreButton {
    UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMore setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vDesc addSubview:btnMore];
    [self.vDesc addTrailingConstraintForItem:btnMore];
    [self.vDesc addBottomConstraintForItem:btnMore equalBottomItem:self.lbTitle bottom:0];
    [btnMore setTitle:@"...more" forState:UIControlStateNormal];
    [btnMore setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
    [btnMore addHeightConstraint:20];
    [btnMore addTarget:self action:@selector(handleMoreDescription:) forControlEvents:UIControlEventTouchUpInside];
    [btnMore setBackgroundColor:[UIColor whiteColor]];
    [btnMore setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    btnMore.titleLabel.font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
    self.btnShowMore = btnMore;
}

- (void)handleMoreDescription:(id)sender {
    [Utils showAlertNoInteractiveWithTitle:@"Description" message:self.itemModel.name];
}

- (UIImage *)getAvatar {
    return [self.btnSellerAvatar backgroundImageForState:UIControlStateNormal];
}

- (void)setAvatar:(UIImage *)avatarImage {
    if (avatarImage) {
        [self.btnSellerAvatar setBackgroundImage:avatarImage forState:UIControlStateNormal];
    } else {
        [self.btnSellerAvatar displayDefaultImage];
    }
}

- (UIImage *)getFirstImage {
    return [self.scvGallery getFirstImage];
}

- (void)setFirstImage:(UIImage *)firstImage {
    [self.scvGallery displayFirstImage:firstImage];
}

- (CGFloat)cellHeight {
    return CGRectGetMaxY(self.vContainer.frame) + 1;
}

- (void)setItemModelToCalcHeightOfCell:(ItemModel *)itemModel {
    _itemModel = itemModel;
}

- (void)setHasRightMenu:(BOOL)hasRightMenu {
    _hasRightMenu = hasRightMenu;
    [self.imvItemStatus setHidden:hasRightMenu];
    [self.lbItemStatus setHidden:hasRightMenu];
    [self.btnMenu setHidden:!hasRightMenu];
}

- (void)setInWishlistPage:(BOOL)inWishlistPage {
    _inWishlistPage = inWishlistPage;
    //    [self.btnRemoveFromWishlist setHidden:!inWishlistPage];
}

- (void)updateLikeUI:(BOOL)liked {
    self.btnLike.selected = liked;
}

- (void)updateWishlistUI:(BOOL)wishlisted {
    self.btnWishlist.selected = wishlisted;
    //    self.btnWishlist.userInteractionEnabled = !wishlisted;
}

- (void)closeRightMenu:(BOOL)animate {
    CGRect rect = self.vContainer.frame;
    rect.origin.x = 0;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.vContainer.frame = rect;
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark - Button Handle
- (IBAction)handleSellerAvatarButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openSellerProfilePage:sender:)]) {
        [self.delegate openSellerProfilePage:self.itemModel sender:self];
    }
}

- (IBAction)handleSeeMorePost:(id)sender {
    if ([self.delegate respondsToSelector:@selector(seeMorePost:)]) {
        [self.delegate seeMorePost:self.itemModel.sellerModel];
    }
}

- (IBAction)handleFollowersButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openFollowersPage:)]) {
        [self.delegate openFollowersPage:self.itemModel.sellerModel];
    }
}

- (IBAction)handleLikeButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(likeItem:)]) {
        [self.delegate likeItem:_itemModel];
    }
}

- (IBAction)handleWishlistButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(wishlistItem:)]) {
        [self.delegate wishlistItem:_itemModel];
    }
}

- (IBAction)handleShareButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shareItem:)]) {
        [self.delegate shareItem:_itemModel];
    }
}

- (IBAction)handleCommentButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openCommentPage:sender:)]) {
        [self.delegate openCommentPage:_itemModel sender:self];
    }
}

- (IBAction)handleMoreInfoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openMoreInfoPage:sender:)]) {
        [self.delegate openMoreInfoPage:_itemModel sender:self];
    }
}

- (IBAction)handleBuyNowButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(buyNow:sender:)]) {
        [self.delegate buyNow:_itemModel sender:self];
    }
}

- (IBAction)handleLikeNumberButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openLikersPage:)]) {
        [self.delegate openLikersPage:_itemModel];
    }
}

- (IBAction)handleCommentNumberButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openCommentsPage:sender:)]) {
        [self.delegate openCommentsPage:_itemModel sender:self];
    }
}

- (IBAction)handleMenuButton:(id)sender {
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

- (IBAction)handleEditItemButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editItem:)]) {
        [self.delegate editItem:self.itemModel];
    }
}

- (IBAction)handleUnavailableButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(updateItemStatus:withStatus:)]) {
        [self.delegate updateItemStatus:self.itemModel withStatus:(!self.btnUnavailable.selected) ? STATUS_UNAVAILABLE : @""];
    }
}

- (IBAction)handleRemoveButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(removeItem:)]) {
        [self.delegate removeItem:self.itemModel];
    }
}

- (IBAction)handleRemoveFromWishlistButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(removeItemFromWishlist:)]) {
        [self.delegate removeItemFromWishlist:self.itemModel];
    }
}

- (IBAction)handleSizeButton:(id)sender {
    NSString *message = (self.itemModel.describe_size.length > 0) ? self.itemModel.describe_size : NSLocalizedString(@"no_description", @"");
    [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"size_description", @"") message:message];
}
- (IBAction)handleFollowButton:(id)sender {
    if (!self.itemModel.sellerModel.followed) {
        if ([self.delegate respondsToSelector:@selector(updateSellerFollowStatus:)]) {
            [self.delegate updateSellerFollowStatus:self.itemModel];
        }
    }
}

- (IBAction)handleSellerName:(id)sender {
    if (self.itemModel.sellerModel.followed || [self.itemModel isMine]) {
        if ([self.delegate respondsToSelector:@selector(openSellerProfilePage:sender:)]) {
            [self.delegate openSellerProfilePage:self.itemModel sender:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(updateSellerFollowStatus:)]) {
            [self.delegate updateSellerFollowStatus:self.itemModel];
        }
    }
}

- (IBAction)handleInAppropriateButton:(id)sender {
    if (self.itemModel.flagged == NO) {
        if ([self.delegate respondsToSelector:@selector(markInAppropriate:)]) {
            [self.delegate markInAppropriate:self.itemModel];
        }
    }
}

#pragma mark - SupViewOfMoreInfoDelegate
- (void)openSellerProfilePage:(SellerModel *)seller {
    if ([self.delegate respondsToSelector:@selector(openLikerProfilePage:)]) {
        [self.delegate openLikerProfilePage:seller];
    }
}

- (void)openLikersPage:(ItemModel *)item {
    if ([self.delegate respondsToSelector:@selector(openLikersPage:)]) {
        [self.delegate openLikersPage:self.itemModel];
    }
}
@end
