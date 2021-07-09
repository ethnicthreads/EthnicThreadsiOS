//
//  BaseItemModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

#define CONDITION_NONE          @""
#define CONDITION_NEW           @"new"
#define CONDITION_LIKENEW       @"like_new"

#define GENDER_WOMEN            @"Women"
#define GENDER_MEN              @"Men"
#define GENDER_BOYS             @"Kids/Boys"
#define GENDER_GIRLS            @"Kids/Girls"
#define GENDER_HOME             @"Home"
#define GENDER_OTHER            @"Other"
#define GENDER_FUN              @"Fun"
#define GENDER_SERVICES         @"Service"

#define PURCHASES_SALE          @"Sale"
#define PURCHASES_RENT          @"Rent"
#define PURCHASES_EXCHANGE      @"Exchange"
#define PURCHASES_FUN           @"Fun"

#define SIZE_S                  @"S"
#define SIZE_M                  @"M"
#define SIZE_L                  @"L"
#define SIZE_XL                 @"XL"

@interface BaseItemModel : AssetModel
@property (strong, nonatomic) NSString          *name;
@property (strong, nonatomic) NSString          *desc;
@property (nonatomic) double                    price;
@property (nonatomic) double                    shipping;
@property (strong, nonatomic) NSString          *currency;
@property (strong, nonatomic) NSString          *gender;
@property (nonatomic) double                    latitude;
@property (nonatomic) double                    longitude;
@property (strong, nonatomic) NSString          *address;
@property (strong, nonatomic) NSString          *city;
@property (strong, nonatomic) NSString          *state;
@property (strong, nonatomic) NSString          *country;
@property (strong, nonatomic) NSString          *describe_size;
@property (strong, nonatomic) NSString          *condition;
@property (strong, nonatomic) NSString          *youtube_link;
@property (strong, nonatomic) NSString          *category;

- (void)setSpecialValue:(NSDictionary *)dict;
- (NSString *)getLocation;
- (BOOL)existYoutubeLink;
- (BOOL)isService;
- (NSString *)conditionString;
@end
