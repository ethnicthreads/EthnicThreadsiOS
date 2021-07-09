//
//  LocationManager.h
//  EthnicThread
//
//  Created by Duy Nguyen on 3/13/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject
+ (LocationManager *)sharedInstance;
- (void)updateLocation;
- (BOOL)isReadyCurrentLocation;
- (NSString *)getCurrentAddress;
- (NSString *)getCurrentCity;
- (NSString *)getCurrentState;
- (NSString *)getCurrentCountry;
- (void)setCurrentCountry:(NSString *)country;
- (CLLocation *)getCurrentLocation;
- (BOOL)authorizationStatusEnable;
@end
