//
//  Addresses.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/4/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"

@interface Addresses : BaseObject
- (id)initWithAddressDict:(NSDictionary *)addressDict andCountries:(NSDictionary *)countryDict;
- (NSArray *)getCountries;
- (NSArray *)getCities;
- (NSArray *)getStates;
@end
