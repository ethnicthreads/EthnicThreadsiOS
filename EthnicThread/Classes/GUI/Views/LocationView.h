//
//  LocationView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/28/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "EditItemDelegate.h"

@interface LocationView : BaseView
@property (nonatomic, assign) id <EditItemDelegate>          editDelegate;
@property (nonatomic, assign) BOOL                           allowEdit;

- (void)displayLocationWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)aAddress;
@end
