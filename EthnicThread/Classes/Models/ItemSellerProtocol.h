//
//  ItemSellerProtocol.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ItemSellerProtocol <NSObject>
- (NSString *)getIdString;
@optional
- (void)updateLatestComment:(NSDictionary *)dict;
- (void)updateLatestReview:(NSDictionary *)dict;
@end
