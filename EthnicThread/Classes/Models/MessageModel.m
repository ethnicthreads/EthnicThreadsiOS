//
//  MessageModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "MessageModel.h"
#import "Constants.h"
#import "UserManager.h"
#import "DateTimeUtil.h"

@interface MessageModel()
@end

@implementation MessageModel
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        dict = [Utils checkNull:dict];
        self.created_at = [[Utils checkNil:[dict objectForKey:@"created_at"] defaultValue:@"0"] doubleValue];
        self.contentType = [Utils checkNil:[dict objectForKey:@"content_type"] defaultValue:@""];
        self.threadType = [Utils checkNil:[dict objectForKey:@"thread_type"] defaultValue:@""];
        self.imageUrl = [Utils checkNil:[dict objectForKey:@"image_url"] defaultValue:@""];
        self.sender = [[SellerModel alloc] initWithDictionary:[dict objectForKey:@"sender"]];
        self.receiver = [[SellerModel alloc] initWithDictionary:[dict objectForKey:@"receiver"]];
        self.itemModel = nil;
        if ([dict objectForKey:@"item"]) {
            self.itemModel = [[ItemModel alloc] initWithDictionary:[dict objectForKey:@"item"]];
        }
        self.message = [Utils convertUnicodeToEmoji:self.message];
    }
    return self;
}

- (NSString *)getCreatedDateString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.created_at];
    return [DateTimeUtil formatFriendlyDuration:date];
}

- (BOOL)isMine {
    if (![[UserManager sharedInstance] isLogin]) return NO;
    return [[[UserManager sharedInstance] getAccount].getIdString isEqualToString:[self.sender getIdString]];
}

- (SellerModel *)getTargetSeller {
    return ([self isMine]) ? self.receiver : self.sender;
}

- (BOOL)isImageType {
    return [self.contentType hasPrefix:@"image"];
}

- (BOOL)isTextType {
    return [self.contentType hasPrefix:@"text"];
}
@end
