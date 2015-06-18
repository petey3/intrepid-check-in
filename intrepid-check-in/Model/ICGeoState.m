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
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        //Set intrepid center
        _intrepidCenter.longitude = -71.080171;
        _intrepidCenter.latitude = 42.367059;
        
        //Set radius
        _radius = 50.0;
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if(self.autoPost) [[ICRequestManager manager] notifySlackArrival];
    
    //TODO: also trigger an alert
    NSLog(@"Arrived at Intrepid!");
    self.enteredRegion = YES;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if(self.enteredRegion) {
        if(self.autoPost) [[ICRequestManager manager] notifySlackExit];
        
        NSLog(@"Left Intrepid!");
        //TODO: reregister the notification so we can get it again
        self.enteredRegion = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"Receiving Updates");
}


@end
