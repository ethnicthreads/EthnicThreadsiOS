//
//  SearchViewController.h
//  EthnicThread
//
//  Created by Katori on 12/4/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SearchCriteria.h"
#import "PickerViewController.h"

@interface SearchViewController : BaseViewController <PickerViewControllerDelegate, AppManagerProtocol>
@property (nonatomic, assign) BOOL      canBackToMainMenu;
@property (nonatomic, assign) BOOL      isService;
@end
