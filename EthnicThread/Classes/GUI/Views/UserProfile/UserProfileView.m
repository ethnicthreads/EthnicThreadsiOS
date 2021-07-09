//
//  UserProfileView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/2/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UserProfileView.h"
#import "StarRatingView.h"
#import "Constants.h"

@interface UserProfileView()
@property (nonatomic, strong) SellerModel         *sellerModel;
//outlet
@property (nonatomic, assign) IBOutlet UIView               *vThumbBG;
@property (nonatomic, assign) IBOutlet UILabel              *lblNoImage;
@property (nonatomic, assign) IBOutlet CustomImageView      *imvThumb;
@property (nonatomic, assign) IBOutlet UILabel              *lblName;
@property (nonatomic, assign) IBOutlet UILabel              *lblLocation;
@property (nonatomic, assign) IBOutlet UIButton             *btnFolowersCount;
@property (nonatomic, assign) IBOutlet UIButton             *btnFolowerText;
@property (nonatomic, assign) IBOutlet UILabel              *lblRatingCount;
@property (nonatomic, assign) IBOutlet StarRatingView       *ratingView;
@property (nonatomic, assign) IBOutlet UIButton             *btnItemCount;
@property (nonatomic, assign) IBOutlet UILabel              *lblDescription;
@property (nonatomic, assign) IBOutlet UILabel              *lblTerm;
@property (nonatomic, assign) IBOutlet UIButton             *btnRateSeller;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightRateButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTopRateButton;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTopAboutMeLabel;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomAboutMeLabel;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightAboutMeLabel;
@end

@implementation UserProfileView

- (void)initGUI {
    [super initGUI];
    self.btnRateSeller.layer.borderColor = ORANGE_COLOR.CGColor;
    self.btnRateSeller.layer.borderWidth = 1;
    [self.btnRateSeller setTintColor:ORANGE_COLOR];
    
    self.imvThumb.contentMode = UIViewContentModeScaleAspectFit;
    [self.vThumbBG setBackgroundColor:GRAY_COLOR];
    [self.lblNoImage setTextColor:[UIColor whiteColor]];
}

- (void)updateConstraints {
    if (self.sellerModel.about_me.length == 0) {
        self.lcTopAboutMeLabel.constant = 0;
        self.lcBottomAboutMeLabel.constant = 0;
    }
    else {
        self.lcHeightAboutMeLabel.constant = 34;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)displayUserProfile:(SellerModel *)aUser {
    self.sellerModel = aUser;
    self.ratingView.rating = self.sellerModel.average_rating;
    self.lblRatingCount.text = [NSString stringWithFormat:@"%ld", (long)self.sellerModel.total_rates];
    [self.btnFolowersCount setTitle:[NSString stringWithFormat:@"%ld", (long)self.sellerModel.total_followers] forState:UIControlStateNormal];
    [self.btnFolowerText setTitle:[self.sellerModel getFollowersTextBy:self.sellerModel.total_followers] forState:UIControlStateNormal];
    self.lblName.text = [self.sellerModel getDisplayName];
    self.lblLocation.text = [self.sellerModel getLocation];
    self.ratingView.rating = self.sellerModel.average_rating;
    self.lblTerm.text = [self.sellerModel getTermsText];
    [self.btnItemCount setTitle:[self.sellerModel getItemsCountText] forState:UIControlStateNormal];
    self.lblDescription.text = self.sellerModel.about_me;
    [self.imvThumb loadImageForUrl:self.sellerModel.avatar type:IMAGE_DONOTHING];
    [self.lblNoImage setHidden:(self.sellerModel.avatar.length > 0)];
    
    if ((!(self.sellerModel.rated == NO && [[UserManager sharedInstance] isLogin])) || [self.sellerModel isMe]) {
        self.lcHeightRateButton.constant = 0;
        self.lcTopRateButton.constant = 0;
        [self.btnRateSeller setHidden:YES];
    }
}

- (IBAction)handleRateSellerButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(rateSeller:)]) {
        [self.delegate rateSeller:self.sellerModel];
    }
}

- (IBAction)handleFollowerButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openFollowerPage:)]) {
        [self.delegate openFollowerPage:self.sellerModel];
    }
}

- (IBAction)handleItemsListedButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openListedItemsPage:)]) {
        [self.delegate openListedItemsPage:self.sellerModel];
    }
}
@end
