//
//  DiscoverViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemsViewController.h"

@interface DiscoverViewController : ItemsViewController

- (void)openMyProfilePage:(NSNumber *)userId;
- (void)openMoreInfoByItemId:(NSNumber *)itemId shouldOpenComments:(BOOL)shouldOpenComments;
- (void)openAdvertisingUrl:(NSString *)url;
@end
