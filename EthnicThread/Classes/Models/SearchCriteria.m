//
//  SearchCriteria.m
//  EthnicThread
//
//  Created by Katori on 12/5/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SearchCriteria.h"

@implementation SearchCriteria

- (NSDictionary *)makeDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.size.length > 0)
        [dict setObject:[self.size lowercaseString] forKey:@"size"];
    if (self.gender.length > 0)
        [dict setObject:[self.gender lowercaseString] forKey:@"gender"];
    if (self.purchases.length > 0)
        [dict setObject:[self.purchases lowercaseString] forKey:@"purchases"];
    if (self.tags.length > 0)
        [dict setObject:[self.tags lowercaseString] forKey:@"tags"];
    if (self.condition.length > 0)
        [dict setObject:[self.condition lowercaseString] forKey:@"condition"];
    if (self.keywords.length > 0)
        [dict setObject:[self.keywords lowercaseString] forKey:@"keyword"];
    if (self.desc.length > 0)
        [dict setObject:[self.desc lowercaseString] forKey:@"description"];
    if (self.sellerName.length > 0)
        [dict setObject:[self.sellerName lowercaseString] forKey:@"sellerName"];
    if (self.category.length > 0)
        [dict setObject:[self.category lowercaseString] forKey:@"category"];
    if (self.location) {
        [dict setObject:[NSString stringWithFormat:@"%f", self.location.coordinate.longitude] forKey:@"longitude"];
        [dict setObject:[NSString stringWithFormat:@"%f", self.location.coordinate.latitude] forKey:@"latitude"];
    }
    
    if (self.radius > 0 && self.location) {// search by miles
        [dict setObject:[NSString stringWithFormat:@"%ld", (long)self.radius] forKey:@"radius"];
    }
    else {// search by anywhere
//        if (self.city.length > 0)
//            [dict setObject:[self.city lowercaseString] forKey:@"city"];
//        if (self.state.length > 0)
//            [dict setObject:[self.state lowercaseString] forKey:@"state"];
        if (self.country.length > 0)
            [dict setObject:[self.country lowercaseString] forKey:@"country"];
    }
    
    [dict setObject:[NSString stringWithFormat:@"%d", self.limitFollow] forKey:@"limitFollow"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.limitAvailable] forKey:@"onlyAvailable"];
    return dict;
}
@end
