//
//  SearchResultViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/8/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemsViewController.h"
#import "SearchCriteria.h"

#define ANYWHERE_EQUAL_DISTANCE       0

@interface SearchResultViewController : ItemsViewController
@property (nonatomic, strong) SearchCriteria        *criteria;
@end
