//
//  ItemView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/28/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemView.h"
#import "Constants.h"
#import "CustomImageView.h"
#import "AvatarButton.h"
#import "LikersView.h"

@interface ItemView()
@property (nonatomic, assign) IBOutlet UIView               *vPriceContainer;
@property (nonatomic, assign) IBOutlet UILabel              *lbPrice;
@property (nonatomic, assign) IBOutlet UILabel              *lbPurchares;
@property (nonatomic, assign) IBOutlet UIView               *vPriceLine;
@property (nonatomic, assign) IBOutlet UIImageView          *imvItemStatus;
@property (nonatomic, assign) IBOutlet UILabel              *lbStatus;
@property (nonatomic, assign) IBOutlet UILabel              *lbDescription;
@property (nonatomic, assign) IBOutlet UIButton             *btnGender;
@property (nonatomic, assign) IBOutlet UIButton             *btnSize;
@property (nonatomic, assign) IBOutlet UIButton             *btnViewmore;
@property (nonatomic, assign) IBOutlet UIButton             *btnLike;
@property (nonatomic, assign) IBOutlet UIButton             *btnWishlist;
@property (nonatomic, assign) IBOutlet UIButton             *btnShare;
@property (nonatomic, assign) IBOutlet UIView               *vTop;
@property (nonatomic, strong) UIView                        *sclContentView;
@property (nonatomic, assign) IBOutlet UIButton             *btnLikeNumber;
@property (nonatomic, assign) IBOutlet AvatarButton         *btnSellerAvatar;
@property (nonatomic, assign) IBOutlet LikersView           *vLikers;
@property (nonatomic, assign) IBOutlet UIView               *vAction;
@property (nonatomic, assign) IBOutlet UIButton             *btnYoutube;
@property (nonatomic, assign) IBOutlet UIView               *vSizeContainer;
@property (nonatomic, assign) IBOutlet UILabel              *lblTag;
@property (nonatomic, assign) IBOutlet UIView               *vTagContainer;
@property (nonatomic, assign) IBOutlet UILabel              *lblCreateAt;
@property (nonatomic, assign) IBOutlet UIButton             *btnInAppropriate;

@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightSocialView;
@property (nonatomic, strong) NSLayoutConstraint            *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint            *bottomConstraint;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTopViewMoreButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightViewMoreButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightLikeNumView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightActionView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightYoutubeButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeihgtSizeContainerView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcWidthPriceLabel;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcLeadingDescLabel;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTrailingDescLabel;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightDescTextView;

@property (nonatomic, assign) IBOutlet UIView               *vSocial;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditPrice;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditPuschases;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditThumb;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditGender;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditTag;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditSize;
@property (nonatomic, assign) IBOutlet UIButton             *btnEditDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnTitle;


- (IBAction)handleViewmoreButton:(id)sender;
- (IBAction)handleLikeButton:(id)sender;
- (IBAction)handleWishlistButton:(id)sender;
- (IBAction)handleShareButton:(id)sender;
@end

@implementation ItemView

- (void)initVariables {
    [super initVariables];
    self.btnViewmore.layer.borderColor = PURPLE_COLOR.CGColor;
    self.btnViewmore.layer.borderWidth = 1;
    self.btnYoutube.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)updateConstraints {
    if (self.allowEdit) {
        self.lcHeightSocialView.constant = 0;
        self.lcHeightActionView.constant = 0;
    }
    self.lcHeightLikeNumView.constant = (self.itemModel.total_likes == 0) ? 50 : 50;
    self.lcHeightYoutubeButton.constant = (self.itemModel.youtube_link.length > 0) ? 37 : 0;
    [self.btnYoutube setHidden:(self.itemModel.youtube_link.length == 0)];
    
    if ([self.itemModel isService]) {
        self.lcHeihgtSizeContainerView.constant = 0;
    }
    if ([self.lbPrice isHidden]) {
        self.lcWidthPriceLabel.constant = 0;
    }
    else {
        self.lcWidthPriceLabel.constant = 79;
    }
    [super updateConstraints];
}

- (void)layoutComponents {
    [super layoutComponents];
    [self.btnEditPuschases setHidden:YES];
    if (self.allowEdit) {
        [self.vSocial setHidden:YES];
        [self.btnEditPrice setHidden:self.itemModel.isService];
        [self.btnEditThumb setHidden:NO];
        [self.btnEditGender setHidden:NO];
        [self.btnEditTag setHidden:NO];
        [self.btnEditSize setHidden:NO];
        [self.btnEditDescription setHidden:NO];
        [self.vAction setHidden:YES];
        [self.imvItemStatus setHidden:YES];
        [self.lbStatus setHidden:YES];
    }
}
- (IBAction)handleBtnTitle:(id)sender {
}

- (void)setItemModel:(ItemModel *)itemModel {
    _itemModel = itemModel;
    
    [self.scvGallery setImages:[self.itemModel getAllImageUrls] andSize:GALLERY_SCROLLVIEW_SIZE];
    
    if ([self.itemModel isService]) {
        [self.vSizeContainer setHidden:YES];
        [self.vPriceContainer setHidden:YES];
    }
    else {
        [self.lbPrice setHidden:(self.itemModel.price == 0)];
        self.lbPrice.text = [self.itemModel getPriceWithCurencyText];
        self.lbPurchares.text = [self.itemModel getPurchasesText];
    }
    
    if ([self.itemModel isUnavallable] || ![self.itemModel.condition isEqualToString:CONDITION_NONE]) {
        [self.lbStatus setHidden:NO];
        [self.imvItemStatus setHidden:NO];
    }
    else {
        [self.lbStatus setHidden:YES];
        [self.imvItemStatus setHidden:YES];
    }
    self.lbStatus.font = [UIFont systemFontOfSize:[self.itemModel isUnavallable] ? SMALL_FONT_SIZE : MEDIUM_FONT_SIZE];
    self.lbStatus.text = [self.itemModel getStatusString];
    
    NSString *formatText = @"%@";
    formatText = self.itemModel.desc.length == 0 ? @"%@" : @"%@\n%@";
    self.lbDescription.text = [NSString stringWithFormat:formatText,self.itemModel.name, self.itemModel.desc];
    [self.btnSize setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"size", @""), self.itemModel.sizes] forState:UIControlStateNormal];
    [self.btnGender setTitle:[self.itemModel getGenderString] forState:UIControlStateNormal];
    [self.btnGender setImage:[self.itemModel getGenderImage] forState:UIControlStateNormal];
    [self.btnLikeNumber setTitle:[self.itemModel getNumberOfLikesText] forState:UIControlStateNormal];
    
    [self.btnLikeNumber setHidden:self.itemModel.total_likes == 0];
    [self updateLikeUI:self.itemModel.liked];
    [self updateWishlistUI:self.itemModel.in_wish_list];
    
    [self.vLikers setItemModel:self.itemModel];
    self.lblTag.text = [self.itemModel getDisplayedTags];
    [self.vTagContainer setHidden:(self.lblTag.text.length == 0)];
    [self.btnYoutube setTitle:self.itemModel.youtube_link forState:UIControlStateNormal];
    
    [self.btnTitle setTitle:[itemModel.sellerModel getDisplayName] forState:UIControlStateNormal];
    
    CGFloat widthOfDescLabel = [UIScreen mainScreen].bounds.size.width - (self.lcLeadingDescLabel.constant + self.lcTrailingDescLabel.constant);
    NSInteger height = [Utils calculateHeightForString:self.itemModel.desc withWidth:widthOfDescLabel andFont:self.lbDescription.font];
    NSInteger maxHeight = [Utils calculateHeightForNumberOfLine:self.lbDescription.numberOfLines width:widthOfDescLabel font:self.lbDescription.font];
//    if (height <= maxHeight) {
//        [self.btnViewmore setHidden:YES];
        self.lcHeightViewMoreButton.constant = 0;
//        self.lcTopViewMoreButton.constant = 0;
//    }
//    else {
//        [self.btnViewmore setHidden:NO];
//        self.lcHeightViewMoreButton.constant = 38;
//        self.lcTopViewMoreButton.constant = 11;
//    }
        [self.btnViewmore setHidden:YES];
    self.lblCreateAt.text = [self.itemModel createAtString];
    
    [self.btnInAppropriate setSelected:self.itemModel.flagged];
    [self.btnInAppropriate setUserInteractionEnabled:!self.itemModel.flagged];
}

- (void)setAvatar:(UIImage *)avatarImage {
    if (avatarImage) {
        [self.btnSellerAvatar setBackgroundImage:avatarImage forState:UIControlStateNormal];
    }
    else {
        [self.btnSellerAvatar loadImageForUrl:self.itemModel.sellerModel.avatar];
    }
}

- (void)setFirstImage:(UIImage *)firstImage {
    if (firstImage)
        [self.scvGallery displayFirstImage:firstImage];
    else {
        [self.scvGallery displayFirstImageUrl:[self.itemModel getFirstImageUrl]];
    }
}

- (void)setDelegate:(id<SupViewOfMoreInfoDelegate>)delegate {
    _delegate = delegate;
    self.vLikers.delegate = delegate;
}

- (void)updateImages:(NSMutableArray *)images {
    [self.scvGallery setImages:images andSize:GALLERY_SCROLLVIEW_SIZE];
}

- (void)updateLikeUI:(BOOL)liked {
    self.btnLike.selected = liked;
}

- (void)updateWishlistUI:(BOOL)wishlisted {
    self.btnWishlist.selected = wishlisted;
//    self.btnWishlist.userInteractionEnabled = !wishlisted;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *contraints = [self.sclContentView constraints];
    for (NSLayoutConstraint *lc in contraints) {
        if ([lc.firstItem isKindOfClass:[UIImageView class]] && lc.firstAttribute == NSLayoutAttributeWidth) {
            lc.constant = self.frame.size.width;
        }
    }
}

- (IBAction)handleSizeButton:(id)sender {
    [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"size_description", @"") message:self.itemModel.describe_size];
}

- (IBAction)handleViewmoreButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openFullDescription:andDescription:)]) {
        [self.delegate openFullDescription:NSLocalizedString(@"text_description", @"") andDescription:self.itemModel.desc];
    }
}

- (IBAction)handleLikeButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(likeItem:)]) {
        [self.delegate likeItem:self.itemModel];
    }
}

- (IBAction)handleWishlistButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(wishlistItem:)]) {
        [self.delegate wishlistItem:self.itemModel];
    }
}

- (IBAction)handleShareButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shareItem:)]) {
        [self.delegate shareItem:self.itemModel];
    }
}

- (IBAction)handleLikeNumberButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openLikersPage:)]) {
        [self.delegate openLikersPage:self.itemModel];
    }
}

- (IBAction)handleSellerAvatarButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openSellerProfilePage:)]) {
        [self.delegate openSellerProfilePage:self.itemModel.sellerModel];
    }
}

- (IBAction)handleYoutubeButton:(id)sender {
    NSURL *url = [NSURL URLWithString:self.itemModel.youtube_link];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"") message:NSLocalizedString(@"alert_can_not_open_youtube", @"")];
    }
}

- (IBAction)handleInAppropriateButton:(id)sender {
    if (self.itemModel.flagged == NO) {
        if ([self.delegate respondsToSelector:@selector(markInAppropriate:)]) {
            [self.delegate markInAppropriate:self.itemModel];
        }
    }
}

#pragma mark - Handle edit item Button
- (IBAction)handleEditPriceButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editOptionalFields)]) {
        [self.editDelegate editOptionalFields];
    }
}

- (IBAction)handleEditThumbButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editRequitedFields)]) {
        [self.editDelegate editRequitedFields];
    }
}

- (IBAction)handleEditGenderButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editRequitedFields)]) {
        [self.editDelegate editRequitedFields];
    }
}

- (IBAction)handleEditSizeButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editOptionalFields)]) {
        [self.editDelegate editOptionalFields];
    }
}

- (IBAction)handleEditDescriptionButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editOptionalFields)]) {
        [self.editDelegate editOptionalFields];
    }
}

- (IBAction)handleEditPurchasesButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editRequitedFields)]) {
        [self.editDelegate editRequitedFields];
    }
}
@end
