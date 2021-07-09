//
//  MultipartData.m
//  EthnicThread
//
//  Created by Nam Phan on 9/25/14.
//  Copyright (c) 2014 Codebox Solutions Ltd. All rights reserved.
//

#import "MultipartData.h"

@implementation MultipartData

- (NSData *)data {
    NSData *result = nil;
    if (!_data || [_data isEqual:[NSNull null]]) {
        result = [NSData data];
    }
    else if ([_data isEqual:[NSData class]]) {
        result = _data;
    }
    else {
        result = [[_data description] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return result;
}
@end
