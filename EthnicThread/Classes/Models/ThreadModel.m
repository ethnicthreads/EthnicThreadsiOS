//
//  ThreadModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/29/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ThreadModel.h"
#import "UserManager.h"

@implementation ThreadModel
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        dict = [Utils checkNull:dict];
        self.itemModel = nil;
        if ([dict objectForKey:@"item"]) {
            self.itemModel = [[ItemModel alloc] initWithDictionary:[dict objectForKey:@"item"]];
        }
    }
    return self;
}

- (id)initWithMessage:(MessageModel *)aMessage {
    self = [super self];
    if (self) {
        self.message = aMessage.message;
        self.itemModel = aMessage.itemModel;
        self.created_at = aMessage.created_at;
        self.sender = aMessage.sender;
        self.receiver = aMessage.receiver;
    }
    return self;
}

- (void)updateWithMessage:(MessageModel *)messageModel {
    self.message = messageModel.message;
    self.created_at = messageModel.created_at;
    self.sender = messageModel.sender;
    self.receiver = messageModel.receiver;
    [self justOpened];
}

- (NSString *)makeKey {
    NSString *meId = [[[UserManager sharedInstance] getAccount] getIdString];
    NSString *otherId = [meId isEqualToString:[self.sender getIdString]] ? [self.receiver getIdString] : [self.sender getIdString];
    NSString *key = [NSString stringWithFormat:@"%@_%@", meId, otherId];
    return key;
}

- (void)justOpened {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@(self.created_at) forKey:[self makeKey]];
    [userDefault synchronize];
}

- (BOOL)hasNewMessage {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    double created = [[userDefault objectForKey:[self makeKey]] doubleValue];
    if (created < self.created_at) {
        return YES;
    }
    return NO;
}

- (BOOL)checkMessageBelong:(MessageModel *)message {
    if (([[self.sender getIdString] isEqualToString:[message.sender getIdString]] && [[self.receiver getIdString] isEqualToString:[message.receiver getIdString]]) ||
        ([[self.sender getIdString] isEqualToString:[message.receiver getIdString]] && [[self.receiver getIdString] isEqualToString:[message.sender getIdString]])) {
        return YES;
    }
    return NO;
}
@end
