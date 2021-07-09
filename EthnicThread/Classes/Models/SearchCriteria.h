//
//  SearchCriteria.h
//  EthnicThread
//
//  Created by Katori on 12/5/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchCriteria : BaseObject
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *purchases;
@property (strong, nonatomic) NSString *tags;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *keywords;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *sellerName;
@property (strong, nonatomic) NSString *category;
@property (assign, nonatomic) BOOL      limitFollow;
@property (assign, nonatomic) BOOL      limitAvailable;
@property (assign, nonatomic) NSInteger         radius;// radius = 0: anywhere
@property (strong, nonatomic) CLLocation        *location;

- (NSDictionary *)makeDictionary;
@end
