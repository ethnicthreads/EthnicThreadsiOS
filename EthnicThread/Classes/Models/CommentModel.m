//
//  CommentModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/2/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CommentModel.h"
#import "Constants.h"
#import "DateTimeUtil.h"

@implementation CommentModel
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        [self setSpecialValue:dict];
        self.owner = [[SellerModel alloc] initWithDictionary:[dict objectForKey:@"user"]];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    [super updateWithDictionary:dict];
    [self setSpecialValue:dict];
    [self.owner updateWithDictionary:[dict objectForKey:@"user"]];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    self.date = 0;
    if (dict.count > 0) {
        self.date = [[Utils checkNil:[dict objectForKey:@"date"] defaultValue:@"0"] doubleValue];
    }
    self.comment = [Utils convertUnicodeToEmoji:self.comment];
}

- (NSString *)getCreatedDateString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.date];
    return [DateTimeUtil formatFriendlyDuration:date];
}
@end
