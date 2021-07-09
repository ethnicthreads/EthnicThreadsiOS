//
//  UserModel.m
//  EthnicThread
//
//  Created by Katori on 12/3/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "UserModel.h"
#import "AppManager.h"
#import "UserManager.h"

@implementation UserModel

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        self.isFullDesc = [[dict objectForKey:@"is_full_description_allowed"] boolValue];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    [super updateWithDictionary:dict];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    [super setSpecialValue:dict];
    self.latitude = [[Utils checkNil:[dict objectForKey:@"latitude"] defaultValue:@"0"] doubleValue];
    self.longitude = [[Utils checkNil:[dict objectForKey:@"longitude"] defaultValue:@"0"] doubleValue];
    self.total_rates = [[Utils checkNil:[dict objectForKey:@"total_rates"] defaultValue:@"0"] integerValue];
    self.average_rating = [[Utils checkNil:[dict objectForKey:@"average_rating"] defaultValue:@"0"] integerValue];
    self.rated = [[Utils checkNil:[dict objectForKey:@"rated"] defaultValue:@"0"] boolValue];
    self.total_followers = [[Utils checkNil:[dict objectForKey:@"total_followers"] defaultValue:@"0"] integerValue];
    self.birth_day = [[Utils checkNil:[dict objectForKey:@"birth_day"] defaultValue:@"0"] doubleValue];
}

- (NSString *)getFollowersText {
    return [NSString stringWithFormat:@"%ld %@", (long)self.total_followers, (self.total_followers <= 1) ? NSLocalizedString(@"follower", @"") : NSLocalizedString(@"followers", @"")];
}

- (NSString *)getFollowersTextBy:(NSInteger)numberOfFollower {
    return [NSString stringWithFormat:@"%@", (numberOfFollower <= 1) ? NSLocalizedString(@"follower", @"") : NSLocalizedString(@"followers", @"")];
}

- (USER_GENDER)getGender {
    if ([self.gender isEqualToString:@"male"])
        return GENDER_MALE;
    else if ([self.gender isEqualToString:@"female"])
        return GENDER_FEMALE;
    return GENDER_NONE;
}

- (NSString *)getBirthDayString {
    NSDate *dateTime = [self getBirthDayDate];
    return [dateTime convertToStringWithFormat:DATE_FORMAT_STRING];
}

- (NSDate *)getBirthDayDate {
    return [NSDate dateWithTimeIntervalSince1970:self.birth_day];
}

- (NSString *)getGenderText {
    NSString *aGender = [self.gender capitalizedString];
    return aGender.length > 0 ? aGender : @"";
}

- (NSString *)getPhoneText {
    return self.phone.length > 0 ? self.phone : @"";
}

- (NSString *)getTermsText {
    return self.terms.length > 0 ? self.terms : NSLocalizedString(@"terms_of_sales_default_text", @"");
}
@end
