//
//  LocationView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/28/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "LocationView.h"
#import "MapLoadingView.h"

@interface LocationView()
@property (nonatomic, assign) IBOutlet MapLoadingView     *mapView;
@property (weak, nonatomic) IBOutlet UILabel        *lblItemLocation;
@property (nonatomic, assign) IBOutlet UIButton     *btnLocation;
@property (nonatomic, assign) id <NSObject>         notificationObserver;
@end

@implementation LocationView

- (void)layoutComponents {
    [super layoutComponents];
    if (self.allowEdit) {
        // enable editing buttons
        [self.btnLocation setHidden:NO];
    }
}

- (void)displayLocationWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)aAddress {
    self.lblItemLocation.text = aAddress;
    [self.mapView displayLocationWithCoordinate:coordinate andAddress:aAddress];
}

- (IBAction)handleEditLocationButton:(id)sender {
    if ([self.editDelegate respondsToSelector:@selector(editOptionalFields)]) {
        [self.editDelegate editOptionalFields];
    }
}
@end