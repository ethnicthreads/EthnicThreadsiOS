//
//  AppManager.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <UIKit/UIKit.h>
#import "ItemModel.h"
#import "UIImageView+Custom.h"
#import "UIButton+Custom.h"
#import "Addresses.h"
#import "AppManagerProtocol.h"
#import "PromotionCriteria.h"

@interface AppManager : NSObject

+ (AppManager *)sharedInstance;
@property (nonatomic, strong) PromotionCriteria *currentCriteria;
- (NSDictionary *)getServiceApis;
- (NSString *)getCloudHostBaseUrl;
@property (nonatomic, strong) NSString *deviceToken;
- (void)shareItem:(ItemModel *)item viewController:(UIViewController *)viewController;
- (void)shareThisApp:(UIViewController *)viewController;
- (void)inviteFriendsToUseAppWithMessage:(NSString *)message viewController:(UIViewController *)viewController;
- (void)showAlertWorkingSoon;
- (PromotionCriteria *)getAllCriteria;
- (void)setCountryFromCountrySelector:(NSString *)country;
- (void)acceptFriendInvitationWithCode:(NSString *)code;
- (NSString *)getCountryFromCountrySelector;
- (Addresses *)getAddresses;
- (NSDictionary *)loadCountries;
- (void)saveInvitationCode:(NSString *)code;
- (NSString *)getInvitationCode;
- (NSArray *)loadCountryNames;
- (void)updateAddresses:(BOOL)updateNow;
- (NSDictionary *)getTags:(BOOL)isServiceTag;
- (NSArray *)getPromotionCriteriaList:(NSArray *)promotionList;
- (void)updateTags:(BOOL)updateNow andListener:(id <AppManagerProtocol>)listener;
- (void)updateDeviceToken:(NSString *)deviceToken;
- (void)openActivityViewcontroller:(NSArray *)activityItems viewContronller:(UIViewController *)viewController;
@end
