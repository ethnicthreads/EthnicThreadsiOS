//
//  BaseObject.m
//  HeyDenmark
//
//  Created by Phan Nam on 12/31/13.
//  Copyright (c) 2013 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"

@implementation BaseObject

- (id)initWithDictionary:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    if (self  = [super init]) {
        NSArray *keys = [dict allKeys];
        for (NSString *key in keys) {
            [self setValue:[dict objectForKey:key] forKey:key];
        }
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        [self setValue:[dict objectForKey:key] forKey:key];
    }
}

- (NSMutableDictionary*)toDictionary {
    return [NSMutableDictionary dictionary];
}


- (void)setValue:(id)value forKey:(NSString *)key {
    @try {
        if (![value isKindOfClass:[NSNull class]]) {
            if (![value isKindOfClass:[NSString class]] ||
                [value caseInsensitiveCompare:@"null"] != NSOrderedSame) {
                [super setValue:value forKey:key];
            }
        }
        else {
            [super setNilValueForKey:key];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}
@end
