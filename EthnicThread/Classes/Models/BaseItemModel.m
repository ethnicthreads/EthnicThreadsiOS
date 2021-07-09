//
//  BaseItemModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseItemModel.h"

@implementation BaseItemModel
- (id)initWithDictionary:(NSDictionary *)dict {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [mDict setObject:[mDict objectForKey:@"description"] forKey:@"desc"];
    [mDict removeObjectForKey:@"description"];
    self = [super initWithDictionary:mDict];
    if (self) {
        [self setSpecialValue:dict];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [mDict setObject:[mDict objectForKey:@"description"] forKey:@"desc"];
    [mDict removeObjectForKey:@"description"];
    [super updateWithDictionary:mDict];
    [self setSpecialValue:dict];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    self.price = [[Utils checkNil:[dict objectForKey:@"price"] defaultValue:@"0"] doubleValue];
    self.shipping = [[Utils checkNil:[dict objectForKey:@"shipping"]defaultValue:@"0"] doubleValue];
    self.latitude = [[Utils checkNil:[dict objectForKey:@"latitude"] defaultValue:@"0"] doubleValue];
    self.longitude = [[Utils checkNil:[dict objectForKey:@"longitude"] defaultValue:@"0"] doubleValue];
}

- (NSString *)getLocation {
    return [Utils generateLocationStringFrom:nil city:self.city state:self.state country:self.country];
}

- (BOOL)existYoutubeLink {
    return ([self.youtube_link containString:@"youtube.com"] || [self.youtube_link containString:@"youtu.be"]);
}

- (BOOL)isService {
    return [self.category isEqualToString:@"service"];
}

- (NSString *)createAtString {
    return nil;
}

- (NSString *)conditionString {
    if ([self.condition isEqualToString:CONDITION_NEW]) {
        return NSLocalizedString(@"text_new", @"");
    }
    else if ([self.condition isEqualToString:CONDITION_LIKENEW]) {
        return NSLocalizedString(@"text_likenew", @"");
    }
    return @"";
}
@end
