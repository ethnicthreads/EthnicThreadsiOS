//
//  QueryStringPair.m
//  EthnicThread
//
//  Created by Phan Nam on 9/5/14.
//  Copyright (c) 2014 Codebox Solutions Ltd. All rights reserved.
//

#import "QueryStringPair.h"
#import "ETUtils.h"

@implementation QueryStringPair
- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return PercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", PercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), PercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}
@end
