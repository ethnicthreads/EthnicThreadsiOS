//
//  MapLoadingView.m
//  EthnicThread
//
//  Created by PhuocDuy on 3/19/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "MapLoadingView.h"
#import "LocationSearching.h"
#import "PlaceAnnotation.h"

@interface MapLoadingView() <LocationSearchingDelegate, MKMapViewDelegate> {
    BOOL shouldReloadLocation;
}
@property (strong, nonatomic) MKLocalSearch         *localSearch;
@property (assign, nonatomic) UIAlertView           *alertView;
@property (strong, nonatomic) LocationSearching     *locationSearch;
@property (nonatomic, assign) id <NSObject>         notificationObserver;
@end

@implementation MapLoadingView

- (void)initVariables {
    [super initVariables];
    self.locationSearch = [[LocationSearching alloc] init];
    self.locationSearch.delegate = self;
    self.mvItemLocation.delegate = self;
}

- (void)initGUI {
    [super initGUI];
    self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification *noti) {
                                                                                  if (shouldReloadLocation) {
                                                                                      if (self.address.length > 0) {
                                                                                          [self.locationSearch startSearchByAddress:self.address];
                                                                                      }
                                                                                  }
                                                                              }];
}

- (void)stopAllThreads {
    if (self.notificationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
        self.notificationObserver = nil;
    }
    [self.locationSearch stopAndQuit];
    [super stopAllThreads];
}

- (void)removeFromSuperview {
    [self.mvItemLocation removeAnnotations:self.mvItemLocation.annotations];
    [super removeFromSuperview];
}

- (void)displayLocationWithAddress:(NSString *)aAddress {
    self.address = aAddress;
    if (self.address.length > 0) {
        [self.locationSearch startSearchByAddress:self.address];
    }
}

- (void)displayLocationWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)aAddress {
    self.address = aAddress;
    self.coordinate = coordinate;
    [self loadingMap:coordinate andAddress:aAddress];
}

- (void)loadingMap:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)aAddress {
    PlaceAnnotation *ann = [[PlaceAnnotation alloc] init];
    ann.placeTitle = aAddress;
    ann.coordinate = coordinate;
    [self.mvItemLocation addAnnotation:ann];
    
    MKCoordinateRegion region;
    region.span.longitudeDelta = 0.4;
    region.span.latitudeDelta = 0.4;
    // the center point is the average of the max and mins
    region.center = coordinate;
    @try {
        [self.mvItemLocation setRegion:region animated:YES];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
    @finally {
        
    }
}
#pragma mark - MKMapViewDelegate
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    DLog(@"Fail Error:%@", error);
}

#pragma mark - LocationSearchingDelegate
- (void)errorLocationSearchingMessage:(NSString *)message {
    [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_error", @"") message:message];
}

- (void)locationServicesEnabled:(BOOL)enabled {
    if (!enabled && shouldReloadLocation == NO) {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_warning", @"")
                                       message:NSLocalizedString(@"alert_please_enable_location_service", @"")];
    }
    shouldReloadLocation = !enabled;
}

- (void)searchedLocation:(MKLocalSearchResponse *)response andAddressText:(NSString *)addressString {
    if (response) {
        NSArray *places = [response mapItems];
        MKMapItem *mapItem = [places objectAtIndex:0];
        self.coordinate = mapItem.placemark.location.coordinate;
        [self loadingMap:mapItem.placemark.location.coordinate andAddress:addressString];
        
        if ([self.delegate respondsToSelector:@selector(didScanLocation:)]) {
            [self.delegate didScanLocation:self.coordinate];
        }
    }
}
@end
