//
//  UserModel.h
//  EthnicThread
//
//  Created by Katori on 12/3/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BasicInfoUserModel.h"

typedef enum _USER_STATUS {
    FACEBOOK_LOGIN,
    EMAIL_LOGIN
} USER_STATUS;

typedef enum _USER_GENDER {
    GENDER_MALE = 1,
    GENDER_FEMALE = 2,
    GENDER_NONE = 4
} USER_GENDER;

#define MALE_TEXT         @"male"
#define FEMALE_TEXT       @"female"

@interface UserModel : BasicInfoUserModel
@property (nonatomic, retain) NSString * access_token;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic) double             latitude;
@property (nonatomic) double             longitude;
@property (nonatomic) NSInteger          total_rates;
@property (nonatomic) NSInteger          total_followers;
@property (nonatomic, retain) NSString * about_me;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * terms;
@property (nonatomic) double             birth_day;
@property (nonatomic) NSInteger          average_rating;
@property (nonatomic) BOOL               rated;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, assign) BOOL          isFullDesc;

- (NSString *)getFollowersText;
- (NSString *)getFollowersTextBy:(NSInteger)numberOfFollower;
- (USER_GENDER)getGender;
- (NSString *)getBirthDayString;
- (NSDate *)getBirthDayDate;
- (NSString *)getGenderText;
- (NSString *)getPhoneText;
- (NSString *)getTermsText;
@end
