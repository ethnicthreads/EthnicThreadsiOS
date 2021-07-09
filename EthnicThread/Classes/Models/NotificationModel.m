//
//  NotificationModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 3/9/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "NotificationModel.h"
#import "AppManager.h"

@interface NotificationModel()
@property (strong, nonatomic) NSDictionary  *sender;
@property (strong, nonatomic) NSDictionary  *target;
@end

@implementation NotificationModel

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        self.dismissed = [[Utils checkNil:[dict objectForKey:@"dismissed"] defaultValue:@"1"] boolValue];
        NSString *type = [self.target objectForKey:@"type"];
        if ([type isEqualToString:@"Comment"]) {
            self.type = PNT_COMMENT;
        }
        else if ([type isEqualToString:@"Like"]) {
            self.type = PNT_LIKE;
        }
        else if ([type isEqualToString:@"Review"]) {
            self.type = PNT_REVIEW;
        }
        else if ([type isEqualToString:@"Follow"]) {
            self.type = PNT_FOLLOW;
        }
        else if ([type isEqualToString:@"Message"]) {
            self.type = PNT_MESSAGE;
        }
        else if ([type isEqualToString:@"SellingItem"]) {
            self.type = PNT_SELLINGITEM;
        }
        else {
            self.type = PNT_NOTHING;
        }
        
        NSString *url = [[self.target objectForKey:@"picture_url"] description];
        if (![url hasPrefix:@"http"]) {
            url = [[[AppManager sharedInstance] getCloudHostBaseUrl] stringByAppendingFormat:@"%@", url];
        }
        self.pictureUrl = url;
    }
    return self;
}

- (NSString *)getSenderId {
    return [[self.sender objectForKey:@"id"] description];
}

- (NSString *)getSenderFirstName {
    return [self.sender objectForKey:@"first_name"];
}

- (NSString *)getSenderLastName {
    return [self.sender objectForKey:@"last_name"];
}

- (NSString *)getSenderFullName {
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [self getSenderFirstName], [self getSenderLastName]];
    return fullName;
}

- (NSString *)getItemId {
    if (self.type == PNT_COMMENT || self.type == PNT_LIKE || self.type == PNT_SELLINGITEM) {
        return [[self.target objectForKey:@"item_id"] description];
    }
    return nil;
}

- (NSString *)getMessage {
    NSString *message = [Utils checkNil:[self.target objectForKey:@"message"] defaultValue:@""];
    return [Utils convertUnicodeToEmoji:message];
}

- (NSDate *)getCreatedDate {
    return [NSDate dateWithTimeIntervalSince1970:[[Utils checkNil:[self.target objectForKey:@"created_at"] defaultValue:@"0"] doubleValue]];
}

- (NSString *)getTargetId {
    return [[self.target objectForKey:@"id"] description];
}
@end
