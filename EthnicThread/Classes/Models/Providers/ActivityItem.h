//
//  ActivityItem.h
//  EthnicThread
//
//  Created by Nam Phan on 9/15/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

@interface ActivityItem : AssetModel
- (id)initWithSubject:(NSString *)subject message:(NSString *)message;
- (NSString *)getSubject;
- (NSString *)getMessage;
@end
