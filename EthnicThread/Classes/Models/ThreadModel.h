//
//  ThreadModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/29/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "MessageModel.h"
#import "ItemModel.h"

@interface ThreadModel : MessageModel
- (id)initWithMessage:(MessageModel *)aMessage;
- (void)updateWithMessage:(MessageModel *)messageModel;
- (void)justOpened;
- (BOOL)hasNewMessage;
- (BOOL)checkMessageBelong:(MessageModel *)message;
@end
