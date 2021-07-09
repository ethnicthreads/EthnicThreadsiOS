//
//  AppManagerProtocol.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/13/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppManagerProtocol <NSObject>
@optional
- (void)didFinishDownloadingTags:(NSDictionary *)tags;
- (void)didFinishDownloadingServiceTags:(NSDictionary *)tags;
@end
