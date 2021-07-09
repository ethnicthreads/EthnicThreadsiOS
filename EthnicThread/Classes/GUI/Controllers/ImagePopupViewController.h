//
//  ImagePopupViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@interface ImagePopupViewController : BaseViewController
@property (nonatomic, strong) NSArray       *images; // UIImage or NSString (url)
@property (nonatomic, assign) NSInteger     currentIndex;
@end
