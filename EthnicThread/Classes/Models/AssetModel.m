//
//  AssetModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

@implementation AssetModel

- (NSString *)getIdString {
    return [_id description];
}

- (BOOL)isSameId:(NSString *)aId {
    return [[self getIdString] isEqualToString:aId];
}

- (BOOL)isSame:(AssetModel *)assetModel {
    return [[self getIdString] isEqualToString:[assetModel getIdString]];
}

#pragma mark - Override
- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *result = [super toDictionary];
    if (self.id != nil) {
        [result setObject:self.id forKey:@"id"];
    }
    return result;
}
@end
