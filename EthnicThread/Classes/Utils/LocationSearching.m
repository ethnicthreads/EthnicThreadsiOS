//
//  LocationSearching.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/11/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "LocationSearching.h"
#import "Constants.h"
#import "Utils.h"
#import "AppManager.h"
#import "EventManager.h"

@interface LocationSearching() <CLLocationManagerDelegate>
@property (nonatomic, strong) MKLocalSearch                     *localSearch;
@property (nonatomic, strong) CLLocationManager                 *locationManager;
@property (nonatomic, strong) CLGeocoder                        *geocoder;
@end

@implementation LocationSearching

- (id)init {
    self = [super init];
    if (self) {
        self.localSearch = nil;
        self.locationManager = nil;
    }
    return self;
}

- (void)startSearchByAddress:(NSString *)addressString
{
//    if([CLLocationManager locationServicesEnabled] &&
//       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if ([self.delegate respondsToSelector:@selector(locationServicesEnabled:)]) {
            [self.delegate locationServicesEnabled:YES];
        }
        if (self.localSearch.searching)
        {
            [self.localSearch cancel];
        }
        
        // setup the area spanned by the map region:
        // we use the delta values to indicate the desired zoom level of the map,
        //      (smaller delta values corresponding to a higher zoom level)
        //
        MKCoordinateRegion newRegion;
        newRegion.span.latitudeDelta = 0.2;
        newRegion.span.longitudeDelta = 0.2;
        
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = addressString;
        request.region = newRegion;
        
        MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
            if (error != nil) {
                NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
                if (errorStr.length > 0 &&[self.delegate respondsToSelector:@selector(errorLocationSearchingMessage:)]) {
                    [self.delegate errorLocationSearchingMessage:errorStr];
                }
            }
            else {
                NSArray *places = [response mapItems];
                MKMapItem *mapItem = [places objectAtIndex:0];
                if ([self.delegate respondsToSelector:@selector(didUpdateLocation:)]) {
                    [self.delegate didUpdateLocation:mapItem.placemark.location];
                }
                if ([self.delegate respondsToSelector:@selector(searchedLocation:andAddressText:)]) {
                    [self.delegate searchedLocation:response andAddressText:addressString];
                }
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        };
        
        if (self.localSearch != nil)
        {
            self.localSearch = nil;
        }
        self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        
        [self.localSearch startWithCompletionHandler:completionHandler];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
//    else {
//        if ([self.delegate respondsToSelector:@selector(locationServicesEnabled:)]) {
//            [self.delegate locationServicesEnabled:NO];
//        }
//    }
}

- (void)stopAndQuit {
    self.delegate = nil;
    [self.localSearch cancel];
    [self.locationManager stopUpdatingLocation];
}

- (void)startStandardLocationUpdates
{
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        if ([self.delegate respondsToSelector:@selector(locationServicesEnabled:)]) {
            [self.delegate locationServicesEnabled:YES];
        }
        if (nil == self.geocoder)
        {
            self.geocoder = [[CLGeocoder alloc] init];
        }
        // Create the location manager if this object does not
        // already have one.
        if (nil == self.locationManager)
        {
            self.locationManager = [[CLLocationManager alloc] init];
        }
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        // Set a movement threshold for new events.
        self.locationManager.distanceFilter = 100; // 100 meters to make changes
        [self.locationManager startUpdatingLocation];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(locationServicesEnabled:)]) {
            [self.delegate locationServicesEnabled:NO];
        }
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    if ([self.delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        [self.delegate didUpdateLocation:location];
    }
    // Reverse Geocoding
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *addressString = CFBridgingRelease(CFBridgingRetain(ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)));
            
            if ([self.delegate respondsToSelector:@selector(searchedLocation:andAddressText:)]) {
                [self.delegate searchedLocation:nil andAddressText:addressString];
            }
            
            if ([self.delegate respondsToSelector:@selector(didUpdateLocation:address:city:state:country:)]) {
                NSString *address = [[Utils generateLocationStringFrom:[Utils checkNil:placemark.subThoroughfare] city:[Utils checkNil:placemark.thoroughfare] state:[Utils checkNil:placemark.subLocality] country:[Utils checkNil:placemark.subAdministrativeArea]] trimText];
                
                NSString *key = placemark.ISOcountryCode;
                NSDictionary *countryDict = [[AppManager sharedInstance] loadCountries];
                NSString *country = placemark.country;
                if (key.length > 0 && countryDict) {
                    NSDictionary *dict = [countryDict objectForKey:key];
                    country = [dict objectForKey:@"name"];
                }
                [self.delegate didUpdateLocation:location
                                         address:address
                                            city:[Utils checkNil:placemark.locality]
                                           state:[Utils checkNil:placemark.administrativeArea]
                                         country:[Utils checkNil:country]];
            }
        }
    }]; }

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(errorLocationUpdating:)]) {
        [self.delegate errorLocationUpdating:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    DLog("Authorized Status:%d", status);
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [[EventManager shareInstance] fireEventWithType:ET_DID_TURN_ON_LOCATION result:nil channel:CHANNEL_UI];
    } else {
        [[EventManager shareInstance] fireEventWithType:ET_DISABLE_LOCATION result:nil channel:CHANNEL_UI];
    }
}
@end
