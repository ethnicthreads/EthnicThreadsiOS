//
//  QueryStringPair.h
//  EthnicThread
//
//  Created by Phan Nam on 9/5/14.
//  Copyright (c) 2014 Codebox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"

@interface QueryStringPair : BaseObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end
