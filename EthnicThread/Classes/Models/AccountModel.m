//
//  AccountModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AccountModel.h"

@implementation AccountModel
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        dict = [Utils checkNull:dict];
        NSDictionary *fbDict = [dict objectForKey:@"facebook_account"];
        if (fbDict.count > 0) {
            self.facebook_id = [fbDict objectForKey:@"facebook_id"];
        }
        self.sign_in_count = [[Utils checkNil:[dict objectForKey:@"sign_in_count"] defaultValue:@"0"] integerValue];
        self.unread_notifications = [[Utils checkNil:[dict objectForKey:@"unread_notifications"] defaultValue:@"0"] integerValue];
    }
    return self;
}

- (BOOL)isLoginViaFacebook {
    return (self.facebook_id.length > 0);
}

- (BOOL)checkRequiredFields {
//    return (self.first_name.length > 0 && self.last_name.length > 0 && self.gender.length > 0 && [self getFullAddress].length > 0 && !(self.latitude == 0 && self.longitude == 0) && self.city.length > 0 && self.state.length > 0 && self.country.length > 0 && self.avatar.length > 0);
    return (self.first_name.length > 0 && self.last_name.length > 0 && self.gender.length > 0 && [self getFullAddress].length > 0 && self.city.length > 0 && self.state.length > 0 && self.country.length > 0 && self.avatar.length > 0);
}

- (void)setUnread_notifications:(NSInteger)unread_notifications {
    _unread_notifications = (unread_notifications >= 0) ? unread_notifications : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.unread_notifications;
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_BADGE_NUMBER object:nil userInfo:nil];
}

- (SellerModel *)makeSeller {
    SellerModel *seller = [[SellerModel alloc] init];
    seller.id = self.id;
    seller.total_items = self.total_items;
    seller.total_reviews = self.total_reviews;
    seller.followed = self.followed;
    seller.hasFullData = self.hasFullData;
    seller.email = [self.email copy];
    seller.first_name = [self.first_name copy];
    seller.last_name = [self.last_name copy];
    seller.country = [self.country copy];
    seller.city = [self.city copy];
    seller.state = [self.state copy];
    seller.gender = [self.gender copy];
    seller.address = [self.address copy];
    seller.latitude = self.latitude;
    seller.longitude = self.longitude;
    seller.avatar = [self.avatar copy];
    seller.total_rates = self.total_rates;
    seller.total_followers = self.total_followers;
    seller.about_me = [self.about_me copy];
    seller.phone = [self.phone copy];
    seller.terms = [self.terms copy];
    seller.birth_day = self.birth_day;
    seller.average_rating = self.average_rating;
    seller.rated = self.rated;
    seller.currency = [self.currency copy];
    return seller;
}
@end
