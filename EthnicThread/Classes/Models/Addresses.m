//
//  Addresses.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/4/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "Addresses.h"

@interface Addresses()
@property (strong, nonatomic) NSDictionary             *addressDict;
@property (strong, nonatomic) NSDictionary             *countryDict;
@end

@implementation Addresses
- (id)init {
    self = [super init];
    if (self) {
        self.addressDict = [[NSDictionary alloc] init];
        self.countryDict = [[NSDictionary alloc] init];
    }
    return self;
}

- (id)initWithAddressDict:(NSDictionary *)addressDict andCountries:(NSDictionary *)countryDict {
    if (self = [self init]) {
        if (addressDict)
            self.addressDict = addressDict;
        if (countryDict)
            self.countryDict = countryDict;
    }
    return self;
}

- (NSArray *)getCountries {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [self.countryDict allValues]) {
        [array addObject:[dict objectForKey:@"name"]];
    }
    return [array sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)getCities {
    return [self.addressDict objectForKey:@"cities"];
}

- (NSArray *)getStates {
    return [self.addressDict objectForKey:@"states"];
}
@end
