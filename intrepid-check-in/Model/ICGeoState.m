//
//  ICGeoState.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/17/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ICGeoState.h"
#import "ICRequestManager.h"

@interface ICGeoState()
@property (nonatomic, readwrite) BOOL enteredRegion;
@end

@implementation ICGeoState
#pragma mark - Initializers
- (instancetype)init {
    self = [super init];
    
    if(self){
        //Set location manager
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = nil;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        //Set intrepid center
        _intrepidCenter.longitude = -71.080171;
        _intrepidCenter.latitude = 42.367059;
        
        //Set radius
        _radius = 50.0;
        
        _alertInApp = YES;
    }
    
    return self;
}

- (CLLocation *)lastLocation {
    if(!_lastLocation) _lastLocation = [[CLLocation alloc] init];
    return _lastLocation;
}

- (CLCircularRegion *)intrepidRegion {
    if(!_intrepidRegion) {
        _intrepidRegion = [[CLCircularRegion alloc] initWithCenter:self.intrepidCenter
                                                            radius:self.radius
                                                        identifier:self.intrepidID];
    }
    return _intrepidRegion;
}

- (NSString *)intrepidID {
    if(!_intrepidID) {
        _intrepidID = @"Intrepid Pursits";
    }
    return _intrepidID;
}

-(void)selfDelegate {
    _locationManager.delegate = self;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self enterRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self exitRegion];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"Receiving Updates");
}

#pragma mark - Utility 
- (void)forceRegionCheck {
    if(!self.enteredRegion) {
        CLLocation *currentLocation = self.locationManager.location;
        CLLocation *center = [[CLLocation alloc] initWithLatitude:self.intrepidCenter.latitude
                                                        longitude:self.intrepidCenter.longitude];
        CLLocationDistance distanceFromCenter = [currentLocation distanceFromLocation:center];
        
        if(distanceFromCenter <= self.radius) {
            [self enterRegion];
        }
    }
}

- (void)enterRegion {
    if(self.autoPost) [[ICRequestManager manager] notifySlackArrival];
    if(self.alertInApp) {
        [self.delegate alertInApp];
    }
    NSLog(@"Arrived at Intrepid!");
    self.enteredRegion = YES;
}

- (void)exitRegion {
    if(self.enteredRegion) {
        if(self.autoPost) [[ICRequestManager manager] notifySlackExit];
        
        NSLog(@"Left Intrepid!");
        //TODO: reregister the notification so we can get it again
        self.enteredRegion = NO;
    }
}


@end
