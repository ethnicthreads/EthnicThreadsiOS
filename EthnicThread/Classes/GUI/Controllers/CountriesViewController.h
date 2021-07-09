//
//  CountriesViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/24/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@protocol CountriesViewControllerDelegate <NSObject>
- (void)searchCountryResult:(NSString *)country;
@end

@interface CountriesViewController : BaseViewController
@property (strong, nonatomic) NSArray        *countries;
@property (nonatomic, assign) id <CountriesViewControllerDelegate> delegate;
@end
