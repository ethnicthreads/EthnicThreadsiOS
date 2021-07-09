//
//  CreateProfileViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/20/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "AvatarButton.h"

@interface CreateProfileViewController : BaseViewController <UIViewControllerTransitioningDelegate>
@property (nonatomic, assign) IBOutlet AvatarButton         *btnAvatar;
@property (nonatomic, assign) IBOutlet UIButton             *btnChangePicture;
@property (nonatomic, assign) IBOutlet UIView               *containView;
@property (nonatomic, strong) CreativeAccountModel          *creativeAccount;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTopContentView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightContentView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcBottomContentView;

- (void)setAvatarImage:(UIImage *)image;
- (void)justChangeAvatar;
@end
