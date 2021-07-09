//
//  MapLoadingView.h
//  EthnicThread
//
//  Created by PhuocDuy on 3/19/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import <MapKit/MapKit.h>

@protocol MapLoadingViewDelegate <NSObject>
- (void)didScanLocation:(CLLocationCoordinate2D)coordinate;
@end

@interface MapLoadingView : BaseView
@property (weak, nonatomic) IBOutlet MKMapView      *mvItemLocation;
@property (nonatomic, assign) IBOutlet id <MapLoadingViewDelegate> delegate;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString              *address;

- (void)displayLocationWithAddress:(NSString *)aAddress;
- (void)displayLocationWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)aAddress;
@end
