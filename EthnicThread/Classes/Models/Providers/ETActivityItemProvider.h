//
//  ETActivityItemProvider.h
//  EthnicThread
//
//  Created by PhuocDuy on 5/9/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityItem.h"

@interface ETActivityItemProvider : UIActivityItemProvider
@property (nonatomic, strong) ActivityItem *normalItem;
@property (nonatomic, strong) NSArray *supportedItems;
@end
