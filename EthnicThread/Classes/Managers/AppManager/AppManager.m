//
//  AppManager.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AppManager.h"
#import "Categories.h"
#import "Utils.h"
#import "OperationManager.h"
#import "CloudManager.h"
#import "UserManager.h"
#import "CachedManager.h"
#import "SignupViewController.h"
#import "DateTimeUtil.h"
#import "ETActivityItemProvider.h"
#import "PromotionCriteria.h"

#define CONFIG_FOLDER               @"Services"

#define DOWNLOAED_ADDRESSES_KEY     @"DOWNLOAED_ADDRESSES"
#define DOWNLOAED_TAG_KEY           @"DOWNLOAED_TAGS"
#define DOWNLOAED_SERVICE_TAG_KEY   @"DOWNLOAED_SERVICE_TAGS"
#define REMOTE_NOTIFICATIONS_KEY    @"remote_notifications"

#define TIME_INTERVAL_UPDATE_TAGS   86400

@interface AppManager()
@property (nonatomic, strong) NSMutableDictionary       *cloudDict;
@property (nonatomic, strong) NSMutableArray            *promotionCriterias;
@property (nonatomic, strong) NSString                  *selectedCountry;
@end

@implementation AppManager

+ (AppManager *)sharedInstance {
    static AppManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppManager alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.cloudDict = [NSMutableDictionary dictionaryWithCapacity:20];
        [self loadCloudService];
        [self configureDateTimeFormatter];
        self.promotionCriterias = [NSMutableArray array];
    }
    return self;
}

- (NSDictionary *)getServiceApis {
    return self.cloudDict;
}

- (NSString *)getCloudHostBaseUrl {
//    [Utils showAlertNoInteractiveWithTitle:nil message:[self.cloudDict objectForKey:@"cloud.host.base.url"]];
    return [self.cloudDict objectForKey:@"cloud.host.base.url"];
}

- (Addresses *)getAddresses {
    NSDictionary *addressDict = [[NSUserDefaults standardUserDefaults] objectForKey:DOWNLOAED_ADDRESSES_KEY];
    NSDictionary *countryDict = [self loadCountries];
    Addresses *ad = [[Addresses alloc] initWithAddressDict:addressDict andCountries:countryDict];
    return ad;
}

- (NSDictionary *)loadCountries {
    NSString *serviceFolder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:CONFIG_FOLDER];
    NSString *countryFile = [serviceFolder stringByAppendingPathComponent:@"countries.json"];
    NSData *theData = [NSData dataWithContentsOfFile:countryFile];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *countriesDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in array) {
        NSString *key = [[dict allKeys] firstObject];
        if (key) {
            [countriesDict setObject:[dict objectForKey:key] forKey:key];
        }
    }
    return countriesDict;
}

- (void)saveInvitationCode:(NSString *)code {
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"inviteCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getInvitationCode {
    NSString *code =[[NSUserDefaults standardUserDefaults] objectForKey:@"inviteCode"];
    if (code.length > 0) {
        return code;
    }
    return @"";
}

- (NSArray *)loadCountryNames {
    NSDictionary *countryDict = [self loadCountries];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [countryDict allValues]) {
        [array addObject:[dict objectForKey:@"name"]];
    }
    return array;
}

- (PromotionCriteria *)getAllCriteria {
    PromotionCriteria *allCrit = [[PromotionCriteria alloc] init];
    allCrit.promotionType = PROMOTION_TYPE_ALL;
    allCrit.displayText = NSLocalizedString(@"promotion_all", @"");
    return allCrit;
}

- (NSArray *)getPromotionCriteriaList:(NSArray *)promotionList {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:promotionList];
    PromotionCriteria *allCrit = [self getAllCriteria];
    [arr insertObject:allCrit atIndex:0];
    
    PromotionCriteria *moreCrit = [[PromotionCriteria alloc] init];
    moreCrit.promotionType = PROMOTION_TYPE_MORE;
    moreCrit.displayText = NSLocalizedString(@"promotion_more", @"");
    [arr addObject:moreCrit];
    return arr;
}

- (void)updateAddresses:(BOOL)updateNow {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval interval = [[userDefaults objectForKey:@"updated_addesses"] integerValue];
    if (updateNow || interval + TIME_INTERVAL_UPDATE_TAGS < [[NSDate date] timeIntervalSince1970] || ![userDefaults objectForKey:DOWNLOAED_ADDRESSES_KEY]) {
        [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeGetAddress:threadObj:) argument:@""];
        interval = [[NSDate date] timeIntervalSince1970];
        [userDefaults setObject:@(interval) forKey:@"updated_addesses"];
        [userDefaults synchronize];
    }
}

- (NSDictionary *)getTags:(BOOL)isServiceTag {
    NSString *key = DOWNLOAED_TAG_KEY;
    if (isServiceTag) {
        key = DOWNLOAED_SERVICE_TAG_KEY;
    }
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!dict) {
        dict = [[NSDictionary alloc] init];
    }
    return dict;
}

- (void)updateTags:(BOOL)updateNow andListener:(id<AppManagerProtocol>)listener {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval interval = [[userDefaults objectForKey:@"updated_tags"] integerValue];
    if (updateNow || interval + TIME_INTERVAL_UPDATE_TAGS < [[NSDate date] timeIntervalSince1970] ||
        ![userDefaults objectForKey:DOWNLOAED_TAG_KEY] || ![userDefaults objectForKey:DOWNLOAED_SERVICE_TAG_KEY]) {
        id arg = @(YES);
        if (listener) {
            arg = listener;
        }
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetTags:threadObj:) argument:arg];
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetServiceTags:threadObj:) argument:arg];
        interval = [[NSDate date] timeIntervalSince1970];
        [userDefaults setObject:@(interval) forKey:@"updated_tags"];
        [userDefaults synchronize];
    }
}

- (void)updateDeviceToken:(NSString *)deviceToken {
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:deviceToken, @"token", uuid, @"uuid", ENVIRONMENT, @"environment", nil];
    self.deviceToken = deviceToken;
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUpdateDeviceToken:threadObj:) argument:dict];
}

#pragma mark - Internal Methods
- (void)acceptFriendInvitationWithCode:(NSString *)code {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeAcceptFriendInvitation:threadObj:) argument:code];
}

- (void)loadCloudService {
    [self.cloudDict removeAllObjects];
    NSString *serviceFolder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:CONFIG_FOLDER];
    NSString *configFile = [serviceFolder stringByAppendingPathComponent:@"cloudconfig.plist"];
    NSDictionary *rootConfig = [NSDictionary dictionaryWithContentsOfFile:configFile];
#ifdef CONFIGURATION_QA
    [self.cloudDict setObject:[rootConfig objectForKey:@"cloud.stage.host.base.url"] forKey:@"cloud.host.base.url"];
#elif CONFIGURATION_DEBUG
    // Using App.ET.Com
    [self.cloudDict setObject:[rootConfig objectForKey:@"cloud.stage.host.base.url"] forKey:@"cloud.host.base.url"];
    // Using App.Stage.ET.Com
//    [self.cloudDict setObject:[rootConfig objectForKey:@"cloud.host.base.url"] forKey:@"cloud.host.base.url"];
#else
    [self.cloudDict setObject:[rootConfig objectForKey:@"cloud.host.base.url"] forKey:@"cloud.host.base.url"];
#endif
//    if ([userdefaul objectForKey:CONFIG_HOST_BASEURL] != nil) {
//        [self.cloudDict setObject:[userdefaul objectForKey:CONFIG_HOST_BASEURL] forKey:@"cloud.host.base.url"];
//    }
//    else {
//        if ([ENVIRONMENT isEqualToString:@"production"]) {
////
//        [self.cloudDict setObject:[rootConfig objectForKey:@"cloud.stage.host.base.url"] forKey:@"cloud.host.base.url"];
//        } else {
//            [self.cloudDict setObject:[rootConfig objectForKey:@"cloud.stage.host.base.url"] forKey:@"cloud.host.base.url"];
//        }
//    }
    
    //parse service apis
    NSArray *serviceFiles= [rootConfig objectForKey:@"cloud.service.files"];
    for (NSString *serviceConfigFile in serviceFiles) {
        NSString *path = [serviceFolder stringByAppendingPathComponent:serviceConfigFile];
        NSDictionary *serviceConfig = [NSDictionary dictionaryWithContentsOfFile:path];
        [self.cloudDict addEntriesFromDictionary:serviceConfig];
    }
    
    NSArray *keys = [self.cloudDict allKeys];
    for (NSString *key in keys) {
        NSString *value = [self.cloudDict objectForKey:key];
        if ([value containString:@"${"]) {
            [self replaceSpecificCharaterForKey:key services:self.cloudDict];
        }
    }
}

- (void)replaceSpecificCharaterForKey:(NSString *)specKey services:(NSMutableDictionary *)services {
    NSRange begin;
    NSRange end;
    NSRange body;
    
    NSString *specValue = [services objectForKey:specKey];
    begin = [specValue rangeOfString:@"${"];
    end = [specValue rangeOfString:@"}"];
    body = NSMakeRange(begin.location + begin.length, end.location - begin.location - begin.length);
    if(body.location == NSNotFound || body.length + body.location >= [specValue length]) {
        DLog(@"can not fix value: %@", specValue);
    }
    else {
        NSString *replacedKey = [specValue substringWithRange:body];
        if ([[services objectForKey:replacedKey] containString:@"${"]) {
            [self replaceSpecificCharaterForKey:replacedKey services:services];
        }
        specValue = [specValue stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"${%@}", replacedKey] withString:[services objectForKey:replacedKey]];
        [services setObject:specValue forKey:specKey];
    }
}

- (void)executeGetAddress:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    Response *response = [CloudManager getAddress:RQ_NOCACHE];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        NSDictionary *dict = response.getJsonObject;
        
        [userDefaults setObject:dict forKey:DOWNLOAED_ADDRESSES_KEY];
        [userDefaults synchronize];
    }
    [threadObj releaseOperation];
}

- (void)executeGetTags:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager getTags:RQ_NOCACHE];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        NSDictionary *dict = response.getJsonObject;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dict forKey:DOWNLOAED_TAG_KEY];
        [userDefaults synchronize];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([dummy conformsToProtocol:@protocol(AppManagerProtocol)]) {
                id <AppManagerProtocol> listener = dummy;
                if ([listener respondsToSelector:@selector(didFinishDownloadingTags:)]) {
                    [listener didFinishDownloadingTags:dict];
                }
            }
        });
    }
    [threadObj releaseOperation];
}

- (void)executeGetServiceTags:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager getServiceTags:RQ_NOCACHE];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        NSDictionary *dict = response.getJsonObject;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dict forKey:DOWNLOAED_SERVICE_TAG_KEY];
        [userDefaults synchronize];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([dummy conformsToProtocol:@protocol(AppManagerProtocol)]) {
                id <AppManagerProtocol> listener = dummy;
                if ([listener respondsToSelector:@selector(didFinishDownloadingServiceTags:)]) {
                    [listener didFinishDownloadingServiceTags:dict];
                }
            }
        });
    }
    [threadObj releaseOperation];
}

- (void)executeUpdateDeviceToken:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [CloudManager updateDeviceToken:body];
    [threadObj releaseOperation];
}

- (void)executeAcceptFriendInvitation:(NSString *)invitationCode threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager acceptFriendInvitation:invitationCode];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UserModel *inviter = [[UserModel alloc] initWithDictionary:response.getJsonObject];
            [Utils showAlertNoInteractiveWithTitle:nil message:[NSString stringWithFormat:@"You are friend with %@", inviter.getDisplayName]];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils showAlertNoInteractiveWithTitle:nil message:[response.getJsonObject objectForKey:@"message"]];
        });
    }
    [threadObj releaseOperation];
}

- (void)configureDateTimeFormatter {
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_minute" value:NSLocalizedString(@"format_date_friendly_minute", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_minutes" value:NSLocalizedString(@"format_date_friendly_minutes", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_hour_minute" value:NSLocalizedString(@"format_date_friendly_hour_minute", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_hours_minute" value:NSLocalizedString(@"format_date_friendly_hours_minute", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_hour_minutes" value:NSLocalizedString(@"format_date_friendly_hour_minutes", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_hours_minutes" value:NSLocalizedString(@"format_date_friendly_hours_minutes", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_hour" value:NSLocalizedString(@"format_date_friendly_hour", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_hours" value:NSLocalizedString(@"format_date_friendly_hours", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_day_hour" value:NSLocalizedString(@"format_date_friendly_day_hour", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_days_hour" value:NSLocalizedString(@"format_date_friendly_days_hour", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_day_hours" value:NSLocalizedString(@"format_date_friendly_day_hours", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_days_hours" value:NSLocalizedString(@"format_date_friendly_days_hours", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_day" value:NSLocalizedString(@"format_date_friendly_day", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_days" value:NSLocalizedString(@"format_date_friendly_days", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_month_day" value:NSLocalizedString(@"format_date_friendly_month_day", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_months_day" value:NSLocalizedString(@"format_date_friendly_months_day", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_month_days" value:NSLocalizedString(@"format_date_friendly_month_days", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_months_days" value:NSLocalizedString(@"format_date_friendly_months_days", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_month" value:NSLocalizedString(@"format_date_friendly_month", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_months" value:NSLocalizedString(@"format_date_friendly_months", @"")];
    
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_minute" value:NSLocalizedString(@"format_date_friendly_duration_minute", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_minutes" value:NSLocalizedString(@"format_date_friendly_duration_minutes", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_hour_minute" value:NSLocalizedString(@"format_date_friendly_duration_hour_minute", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_hours_minute" value:NSLocalizedString(@"format_date_friendly_duration_hours_minute", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_hour_minutes" value:NSLocalizedString(@"format_date_friendly_duration_hour_minutes", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_hours_minutes" value:NSLocalizedString(@"format_date_friendly_duration_hours_minutes", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_hour" value:NSLocalizedString(@"format_date_friendly_duration_hour", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_hours" value:NSLocalizedString(@"format_date_friendly_duration_hours", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_day_hour" value:NSLocalizedString(@"format_date_friendly_duration_day_hour", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_days_hour" value:NSLocalizedString(@"format_date_friendly_duration_days_hour", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_day_hours" value:NSLocalizedString(@"format_date_friendly_duration_day_hours", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_days_hours" value:NSLocalizedString(@"format_date_friendly_duration_days_hours", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_day" value:NSLocalizedString(@"format_date_friendly_duration_day", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_days" value:NSLocalizedString(@"format_date_friendly_duration_days", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_month_day" value:NSLocalizedString(@"format_date_friendly_duration_month_day", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_months_day" value:NSLocalizedString(@"format_date_friendly_duration_months_day", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_month_days" value:NSLocalizedString(@"format_date_friendly_duration_month_days", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_months_days" value:NSLocalizedString(@"format_date_friendly_duration_months_days", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_month" value:NSLocalizedString(@"format_date_friendly_duration_month", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_duration_months" value:NSLocalizedString(@"format_date_friendly_duration_months", @"")];
    
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_simplepattern" value:NSLocalizedString(@"format_date_friendly_simplepattern", @"")];
    [DateTimeUtil setLocalizationStringKey:@"format_date_friendly_fullpattern" value:NSLocalizedString(@"format_date_friendly_fullpattern", @"")];
}

- (void)openActivityViewcontroller:(NSArray *)activityItems viewContronller:(UIViewController *)viewController {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypePostToWeibo,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypeAirDrop];
    
    activityVC.excludedActivityTypes = excludeActivities;
    [viewController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Public Method
- (ETActivityItemProvider *)prepareActivityItemProviderForShareApp {
    ETActivityItemProvider *provider = [[ETActivityItemProvider alloc] initWithPlaceholderItem:@""];
    ActivityItem *normalShare = [[ActivityItem alloc] initWithSubject:@"" message:NSLocalizedString(@"text_to_share_this_app", @"")];
    ActivityItem *item;
    provider.normalItem = normalShare;
    NSMutableArray *otherActivity = [[NSMutableArray alloc] init];
    //email
    item = [[ActivityItem alloc] initWithSubject:NSLocalizedString(@"email_subjcet_share_this_app", @"") message:NSLocalizedString(@"text_to_share_this_app", @"")];
    item.id = UIActivityTypeMail;
    [otherActivity addObject:item];
    
    //message
    item = [[ActivityItem alloc] initWithSubject:@"" message:NSLocalizedString(@"text_to_share_this_app", @"")];
    item.id = UIActivityTypeMessage;
    [otherActivity addObject:item];
    
    //facebook, weibo
    item = [[ActivityItem alloc] initWithSubject:@"" message:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"email_subjcet_share_this_app", @""), NSLocalizedString(@"text_to_share_this_app", @"")]];
    item.id = UIActivityTypePostToFacebook;
    [otherActivity addObject:item];
    
    item = [[ActivityItem alloc] initWithSubject:@"" message:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"email_subjcet_share_this_app", @""), NSLocalizedString(@"text_to_share_this_app", @"")]];
    item.id = UIActivityTypePostToWeibo;
    [otherActivity addObject:item];
    
    item = [[ActivityItem alloc] initWithSubject:@"" message:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"email_subjcet_share_this_app", @""), NSLocalizedString(@"text_to_share_this_app_twitter", @"")]];
    item.id = UIActivityTypePostToTwitter;
    [otherActivity addObject:item];
    
    provider.supportedItems = [NSArray arrayWithArray:otherActivity];
    return provider;
}

- (ETActivityItemProvider *)prepareActivityItemProviderForInviteFriendsWithMessage:(NSString *)inviteText {
    AccountModel *account = [[UserManager sharedInstance] getAccount];
    NSString *baseText = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"applink", @""), inviteText, [account getDisplayName]];
    NSString *message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"invite_friend_string", @""), baseText];

    ETActivityItemProvider *provider = [[ETActivityItemProvider alloc] initWithPlaceholderItem:@""];
    ActivityItem *normalShare = [[ActivityItem alloc] initWithSubject:@"" message:message];
    ActivityItem *item;
    provider.normalItem = normalShare;
    NSMutableArray *otherActivity = [[NSMutableArray alloc] init];
    //email
    item = [[ActivityItem alloc] initWithSubject:NSLocalizedString(@"email_subject_invite_friends", @"") message:message];
    item.id = UIActivityTypeMail;
    [otherActivity addObject:item];
    
    //message
    item = [[ActivityItem alloc] initWithSubject:@"" message:message];
    item.id = UIActivityTypeMessage;
    [otherActivity addObject:item];
    
    //facebook, weibo
    item = [[ActivityItem alloc] initWithSubject:@"" message:message];
    item.id = UIActivityTypePostToFacebook;
    [otherActivity addObject:item];
    
    item = [[ActivityItem alloc] initWithSubject:@"" message:message];
    item.id = UIActivityTypePostToWeibo;
    [otherActivity addObject:item];
    
    item = [[ActivityItem alloc] initWithSubject:@"" message:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"invite_friend_string_twitter", @""), baseText]];
    item.id = UIActivityTypePostToTwitter;
    [otherActivity addObject:item];
    
    provider.supportedItems = [NSArray arrayWithArray:otherActivity];
    return provider;
}

- (ETActivityItemProvider *)prepareActivityItemProviderForShareItem:(ItemModel *)sharedItem {
    NSString *baseText = [NSString stringWithFormat:@"%@\n%@\n%@\n%@: %@", sharedItem.name, [sharedItem getPriceWithCurencyText], [sharedItem getLocation], NSLocalizedString(@"seller", @""), [sharedItem.sellerModel getDisplayName]];
    NSString *content = [NSString stringWithFormat:@"%@\n%@", baseText, sharedItem.desc];
    if ([sharedItem conditionString].length > 0 > 0) {
        content = [NSString stringWithFormat:@"%@\n%@", content, [NSString stringWithFormat:@"Condition: %@", [sharedItem conditionString]]];
    }
    NSString *message = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"text_checkout_app", @""), content];
    
    ETActivityItemProvider *provider = [[ETActivityItemProvider alloc] initWithPlaceholderItem:@""];
    ActivityItem *normalShare = [[ActivityItem alloc] initWithSubject:@"" message:message];
    ActivityItem *item;
    provider.normalItem = normalShare;
    
    
    NSMutableArray *otherActivity = [[NSMutableArray alloc] init];
    //email
    item = [[ActivityItem alloc] initWithSubject:NSLocalizedString(@"email_subject_share_item", @"") message:message];
    item.id = UIActivityTypeMail;
    [otherActivity addObject:item];
    
    
    //message
    item = [[ActivityItem alloc] initWithSubject:@"" message:message];
    item.id = UIActivityTypeMessage;
    [otherActivity addObject:item];
    
    //facebook, weibo
    item = [[ActivityItem alloc] initWithSubject:@"" message:message];
    item.id = UIActivityTypePostToFacebook;
    [otherActivity addObject:item];
    
    item = [[ActivityItem alloc] initWithSubject:@"" message:message];
    item.id = UIActivityTypePostToWeibo;
    [otherActivity addObject:item];
    
    item = [[ActivityItem alloc] initWithSubject:@"" message:content];
    item.id = UIActivityTypePostToTwitter;
    [otherActivity addObject:item];
    
    provider.supportedItems = [NSArray arrayWithArray:otherActivity];
    return provider;
}

- (void)shareItem:(ItemModel *)item viewController:(UIViewController *)viewController {
    UIImage *image = [[DownloadManager shareInstance] getCachedImageForUrl:[item getFirstImageUrl]];

    NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
    [objectsToShare addObject:[self prepareActivityItemProviderForShareItem:item]];
    
    if (image != nil) {
        [objectsToShare addObject:image];
    }
    [objectsToShare addObject:[NSString stringWithFormat:@"\n%@: %@",NSLocalizedString(@"see_it_here", @""), [NSURL URLWithString:item.getItemShareLink]]];
    if ([[UserManager sharedInstance] isLogin]) {
        [objectsToShare addObject:[NSString stringWithFormat:@"\n%@", [[[UserManager sharedInstance] getAccount] getFullName]]];
    }
    
    [self openActivityViewcontroller:objectsToShare viewContronller:viewController];
}

- (void)shareThisApp:(UIViewController *)viewController {
    UIImage *image = [UIImage imageNamed:@"appicon"];
    NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
    [objectsToShare addObject:[self prepareActivityItemProviderForShareApp]];
    
    if (image != nil) {
        [objectsToShare addObject:image];
    }
    [objectsToShare addObject:APP_LINK];
    if ([[UserManager sharedInstance] isLogin]) {
        [objectsToShare addObject:[NSString stringWithFormat:@"\n%@", [[[UserManager sharedInstance] getAccount] getFullName]]];
    }
    
    [self openActivityViewcontroller:objectsToShare viewContronller:viewController];
}

- (void)inviteFriendsToUseAppWithMessage:(NSString *)message viewController:(UIViewController *)viewController {
    AccountModel *account = [[UserManager sharedInstance] getAccount];
    UIImage *image = [[DownloadManager shareInstance] getCachedImageForUrl:account.avatar];
    NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
    [objectsToShare addObject:[self prepareActivityItemProviderForInviteFriendsWithMessage:message]];
    
    if (image != nil) {
        [objectsToShare addObject:image];
    }
    
    [[AppManager sharedInstance] openActivityViewcontroller:objectsToShare viewContronller:viewController];
}

- (void)showAlertWorkingSoon {
    [Utils showAlertNoInteractiveWithTitle:@"Sorry" message:@"Comming soon!"];
}

- (void)setCountryFromCountrySelector:(NSString *)country {
    _selectedCountry = country;
}

- (NSString *)getCountryFromCountrySelector {
    return self.selectedCountry;
}
@end
