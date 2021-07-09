//
//  ContactSellerViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/25/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "UserModel.h"
#import "ItemModel.h"
#import "ThreadModel.h"

@protocol ContactSellerViewControllerDelegate <NSObject>
- (void)updateThread:(MessageModel *)message;
@end

@interface ContactSellerViewController : BaseViewController
@property (nonatomic, strong) NSString          *userId;
@property (nonatomic, strong) NSString          *fullName;
@property (nonatomic, strong) ItemModel         *itemModel;
@property (nonatomic, strong) ThreadModel       *threadModel;
@property (nonatomic, assign) BOOL              shouldMarkOpened;
@property (nonatomic, assign) id <ContactSellerViewControllerDelegate> delegate;

- (void)setDefaultMessage:(NSString *)message;
- (void)didReceiveDerectMessage:(NSNumber *)messId notifId:(NSNumber *)notifId userId:(NSNumber *)userId;
@end
