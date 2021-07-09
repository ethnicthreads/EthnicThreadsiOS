//
//  SearchedUserModel.h
//  EthnicThread
//
//  Created by PhuocDuy on 3/26/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

@interface BasicInfoUserModel : AssetModel
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * display_name;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * address;

@property (nonatomic, assign) BOOL       isAnySeller;

- (id)initAnySelerText;
- (void)setSpecialValue:(NSDictionary *)dict;
- (NSString *)getDisplayName;
- (NSString *)getFullName;
- (NSString *)getFullAddress;
- (NSString *)getLocation;
- (BOOL)isMe;
@end
