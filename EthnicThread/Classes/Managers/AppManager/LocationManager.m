//
//  LocationManager.m
//  EthnicThread
//
//  Created by Duy Nguyen on 3/13/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "LocationManager.h"
#import "LocationSearching.h"
#import "Constants.h"
#import "Utils.h"
#import "EventManager.h"

@interface LocationManager() <LocationSearchingDelegate>
@property (strong, nonatomic) LocationSearching     *locationSearch;
@property (strong, nonatomic) NSString              *address;
@property (strong, nonatomic) NSString              *city;
@property (strong, nonatomic) NSString              *state;
@property (strong, nonatomic, readonly) NSString    *country;
@property (strong, nonatomic) CLLocation            *location;
@end

@implementation LocationManager
+ (LocationManager *)sharedInstance {
    static LocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _country = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_country"];
        self.location = nil;
        [self updateLocation];
        [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)updateLocation {
    if (self.locationSearch) {
        [self.locationSearch stopAndQuit];
    }
    self.locationSearch = [[LocationSearching alloc] init];
    self.locationSearch.delegate = self;
    [self.locationSearch startStandardLocationUpdates];
}

- (void)timerTick:(NSTimer *)timer {
    [self updateLocation];
}

#pragma mark - Public Methods
- (BOOL)isReadyCurrentLocation {
    return (self.location != nil);
}

- (NSString *)getCurrentAddress {
    return self.address;
}

- (void)setCurrentCountry:(NSString *)country {
    _country = country;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.country forKey:@"current_country"];
    [userDefault synchronize];
}

- (NSString *)getCurrentCity {
    return self.city;
}

- (NSString *)getCurrentState {
    return self.state;
}

- (NSString *)getCurrentCountry {
    return self.country;
}

- (CLLocation *)getCurrentLocation {
    return self.location;
}

- (BOOL)authorizationStatusEnable {
    return ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
}

#pragma mark - LocationSearchingDelegate
- (void)errorLocationSearchingMessage:(NSString *)message {
    
}

- (void)didUpdateLocation:(CLLocation *)aLocation address:(NSString *)anAddress city:(NSString *)aCity state:(NSString *)aState country:(NSString *)aCountry {
    self.address = anAddress;
    self.city = aCity;
    self.state = aState;
    [self setCurrentCountry:aCountry];
    self.location = aLocation;
    [self.locationSearch stopAndQuit];
    self.locationSearch = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CURRENT_LOCATION object:nil userInfo:nil];
}

- (void)errorLocationUpdating:(NSError *)error {
    if(!([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied))
    {
        [[EventManager shareInstance] fireEventWithType:ET_DISABLE_LOCATION result:nil channel:CHANNEL_UI];
        
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"not_allow_location_permission"]) {
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"not_allow_location_permission"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_warning", @"")
//                                           message:NSLocalizedString(@"alert_not_allow_location_permission", @"")];
//        }
        
    }
}
@end
