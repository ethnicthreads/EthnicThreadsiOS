//
//  InboxViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@interface InboxViewController : BaseViewController
- (void)openContactPageWithUser:(NSNumber *)userId andFulName:(NSString *)fullName;
@end
