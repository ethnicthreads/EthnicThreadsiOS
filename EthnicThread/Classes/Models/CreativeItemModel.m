//
//  CreatedItemModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CreativeItemModel.h"
#import "CachedManager.h"
#import "UserManager.h"
#import "Constants.h"
#import "LocationManager.h"

#define NA_TEXT          @"N/A"

@interface CreativeItemModel()
@property (strong, nonatomic) NSMutableArray    *purchases;
@end

@implementation CreativeItemModel
- (id)init {
    self = [super init];
    if (self) {
        self.gender = GENDER_FUN;
        self.condition = CONDITION_NONE;
        [self useDefaultAddress];
        self.images = [[NSMutableArray alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:PURCHASES_FUN];
        [self updatePurchases:array];
        self.tags = [[NSMutableArray alloc] init];
        self.sizes = [[NSMutableArray alloc] init];
        [self.sizes addObject:NA_TEXT];
        self.price = 0;
        AccountModel *account = [[UserManager sharedInstance] getAccount];
        self.currency = account.currency.length > 0 ? account.currency : [CURRENCIES objectAtIndex:DEFAULT_CURENTCY_INDEX];
        self.category = @"listed";
    }
    return self;
}

- (BOOL)checkExistedTag:(NSString *)aTag {
    for (NSString *tag in self.tags) {
        if ([tag isEqualToString:aTag]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkExistedSize:(NSString *)aSize {
    for (NSString *size in self.sizes) {
        if ([size isEqualToString:aSize]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkExistedPurchase:(NSString *)aPurchase {
    for (NSString *purchase in self.purchases) {
        if ([purchase isEqualToString:aPurchase]) {
            return YES;
        }
    }
    return NO;
}

- (void)useDefaultAddress {
    AccountModel *account = [[UserManager sharedInstance] getAccount];
    self.address = account.address;
    self.city = account.city;
    self.state = account.state;
    self.country = account.country;
    self.latitude = account.latitude;
    self.longitude = account.longitude;
    self.isDefaultAddress = YES;
}

- (void)useCurrentLocation {
    LocationManager *lm = [LocationManager sharedInstance];
    if ([lm isReadyCurrentLocation]) {
        self.address = [lm getCurrentAddress];
        self.city = [lm getCurrentCity];
        self.state = [lm getCurrentState];
        self.country = [lm getCurrentCountry];
        self.latitude = [lm getCurrentLocation].coordinate.latitude;
        self.longitude = [lm getCurrentLocation].coordinate.longitude;
    }
    else {
        self.address = @"";
        self.city = @"";
        self.state = @"";
        self.country = @"";
        self.latitude = 0;
        self.longitude = 0;
    }
    self.isDefaultAddress = NO;
}

- (ItemModel *)generateItemModel {
    ItemModel *item = [[ItemModel alloc] init];
//    item.name = ([self isForFun] && self.name.length == 0) ? NSLocalizedString(@"for_fun", @"") : [self.name description];
    DLog(@"Name:%@", ([self isForFun] && self.name.length == 0) ? NSLocalizedString(@"for_fun", @"") : [self.name description]);
    if (self.isForFun && self.name.length == 0) {
        item.name = NSLocalizedString(@"for_fun", @"");
    } else {
        item.name = [Utils convertEmojiToUnicode:self.name];
    }
    item.desc = self.desc;
    item.status = @"";
    item.price = self.price;
    item.shipping = self.shipping;
    item.currency = self.currency;
    item.gender = ([self isForFun] && [self.gender isEqualToString:GENDER_OTHER]) ? GENDER_FUN : self.gender;
    item.latitude = self.latitude;
    item.longitude = self.longitude;
    item.address = self.address;
    item.city = self.city;
    item.state = self.state;
    item.country = self.country;
    item.youtube_link = self.youtube_link;
    item.tags = [self.tags componentsJoinedByString:@","];
    item.sellerModel = [[[UserManager sharedInstance] getAccount] makeSeller];
    item.category = self.category;
    item.purchases = [self.purchases componentsJoinedByString:@","];
    item.created_at = [[NSDate date] timeIntervalSince1970];
    if (self.isService) {
        item.sizes = @"";
        item.describe_size = @"";
    }
    else {
        item.sizes = [self.sizes componentsJoinedByString:@","];
        item.describe_size = self.describe_size;
    }
    return item;
}

- (NSString *)getSizeString {
    return [self.sizes componentsJoinedByString:@","];
}

- (NSArray *)scaleImagesAndMakeFileUrls:(NSArray *)imageUIs {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageUIs.count; i++) {
        UIImage *image = [imageUIs objectAtIndex:i];
        UIImage *scaledImage = [image scaleByWidth:IMAGE_ITEM_WIDTH];
        NSString *key = [NSString stringWithFormat:@"image%d.JPEG", i + 1];
        NSString *filePath = [[CachedManager sharedInstance] cacheTempJPEGImage:scaledImage withFileName:key];
        [array addObject:filePath];
    }
    return array;
}

- (NSMutableDictionary *)makeDictionaryForBaseValue {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *aName = ([self isForFun] && self.name.length == 0) ? NSLocalizedString(@"for_fun", @"") : [Utils convertEmojiToUnicode:self.name];
    [dict setObject:[Utils checkNil:aName] forKey:@"name"];
    [dict setObject:[Utils checkNil:self.desc] forKey:@"description"];
    [dict setObject:[self.tags componentsJoinedByString:@","] forKey:@"tags"];
    [dict setObject:@(self.latitude) forKey:@"latitude"];
    [dict setObject:@(self.longitude) forKey:@"longitude"];
    [dict setObject:[Utils checkNil:self.address] forKey:@"address"];
    [dict setObject:[Utils checkNil:self.city] forKey:@"city"];
    [dict setObject:[Utils checkNil:self.state] forKey:@"state"];
    [dict setObject:[Utils checkNil:self.country] forKey:@"country"];
    [dict setObject:self.category forKey:@"category"];
    [dict setObject:[Utils checkNil:self.condition] forKey:@"condition"];
    if (self.isService) {
        [dict setObject:GENDER_SERVICES forKey:@"gender"];
        [dict setObject:@"" forKey:@"condition"];
    }
    else {
        [dict setObject:[self getSizeString] forKey:@"sizes"];
        [dict setObject:[Utils checkNil:self.describe_size] forKey:@"describeSize"];
        [dict setObject:[self.purchases componentsJoinedByString:@","] forKey:@"purchases"];
        [dict setObject:[Utils checkNil:self.currency] forKey:@"currency"];
        [dict setObject:@(self.price) forKey:@"price"];
        [dict setObject:@(self.shipping) forKey:@"shipping"];
        [dict setObject:[Utils checkNil:self.youtube_link] forKey:@"youtubeLink"];
        NSString *aGender = [Utils checkNil:self.gender];
        if ([self isForFun] && [aGender isEqualToString:GENDER_OTHER]) {
            [dict setObject:GENDER_FUN forKey:@"gender"];
        }
        else {
            [dict setObject:aGender forKey:@"gender"];
        }
    }
    return dict;
}

- (NSMutableDictionary *)makeDictionary {
    NSMutableDictionary *dict = [self makeDictionaryForBaseValue];
    [dict setObject:[self scaleImagesAndMakeFileUrls:self.images] forKey:IMAGE_URLS_KEY];
    return dict;
}

- (void)updatePurchases:(NSMutableArray *)purchases {
    self.purchases = purchases;
    if ([self isForFun]) {
//        if (self.desc.length == 0) {
//            self.desc = NSLocalizedString(@"for_fun", @"");
//        }
        if (self.sizes.count == 1 && [[self.sizes firstObject] isEqualToString:SIZE_M]) {
            [self.sizes removeAllObjects];
            [self.sizes addObject:NA_TEXT];
        }
        if (self.tags.count == 0 && [self.gender isEqualToString:GENDER_WOMEN]) {
            self.gender = GENDER_OTHER;
        }
        self.condition = CONDITION_NONE;
    }
    else {
//        if ([self.desc isEqualToString:NSLocalizedString(@"for_fun", @"")]) {
//            self.desc = @"";
//        }
        if (self.sizes.count == 1 && [[self.sizes firstObject] isEqualToString:NA_TEXT]) {
            [self.sizes removeAllObjects];
            [self.sizes addObject:SIZE_M];
        }
        if (self.tags.count == 0 && [self.gender isEqualToString:GENDER_OTHER]) {
            self.gender = GENDER_WOMEN;
        }
        if ([self.condition isEqualToString:CONDITION_NONE]) {
            self.condition = CONDITION_LIKENEW;
        }
    }
}

- (NSMutableArray *)getPurchases {
    return self.purchases;
}

- (BOOL)checkRequiredFields {
    BOOL checked = [self isForFun] ? YES : (self.name.length > 0);
    checked = (checked && self.images.count > 0);
    if (self.isService) {
        return checked;
    }
    return (checked && self.purchases.count > 0);
}

- (BOOL)checkOptionalFields {
    BOOL check = ([self getLocation].length > 0);
    if (self.isService) {
        return check;
    }
    if ([self isForFun]) {
        // only for fun
        return YES;
    }
    return (check && self.sizes.count > 0 && self.price > 0);
}

- (BOOL)shouldShowSoftWarningForUS {
    return [self.country caseInsensitiveCompare:@"United States"] == NSOrderedSame && self.price > 50 && [self.currency isEqualToString:@"$"];
}

- (void)setIsService:(BOOL)isService {
    if (isService) {
        self.category = @"service";
        self.gender = GENDER_SERVICES;
        NSMutableArray *arr = [NSMutableArray arrayWithObjects:PURCHASES_SALE, nil];
        [self updatePurchases:arr];
        self.condition = CONDITION_NONE;
    }
    else {
        self.category = @"listed";
        self.gender = GENDER_WOMEN;
        NSMutableArray *arr = [NSMutableArray arrayWithObjects:PURCHASES_FUN, nil];
        [self updatePurchases:arr];
    }
    [self.tags removeAllObjects];
}

- (BOOL)isForFun {
    return (self.purchases.count == 1 && [[self.purchases objectAtIndex:0] isEqualToString:PURCHASES_FUN]);
}
@end
