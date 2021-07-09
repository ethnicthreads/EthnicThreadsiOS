//
//  LocationSearching.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/11/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>

@protocol LocationSearchingDelegate <NSObject>

@optional
- (void)errorLocationSearchingMessage:(NSString *)message;
- (void)locationServicesEnabled:(BOOL)enabled;
- (void)searchedLocation:(MKLocalSearchResponse *)response andAddressText:(NSString *)addressString;
- (void)didUpdateLocation:(CLLocation *)location;
- (void)didUpdateLocation:(CLLocation *)aLocation address:(NSString *)anAddress city:(NSString *)aCity state:(NSString *)aState country:(NSString *)aCountry;
- (void)errorLocationUpdating:(NSError *)error;
@end

@interface LocationSearching : NSObject
@property (nonatomic, assign) id <LocationSearchingDelegate>   delegate;

- (void)startSearchByAddress:(NSString *)addressString;
- (void)startStandardLocationUpdates;
- (void)stopAndQuit;
@end
