//
//  ICGeoState.h
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/17/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol ICGeoStateDelegate;

@interface ICGeoState : NSObject  <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) CLCircularRegion *intrepidRegion;
@property (nonatomic) CLLocationCoordinate2D intrepidCenter;
@property (nonatomic) CLLocationDistance radius;
@property (strong, nonatomic) NSString *intrepidID;
@property (nonatomic, readonly) BOOL enteredRegion;
@property (nonatomic) BOOL autoPost;
@property (nonatomic) BOOL alertInApp;
@property (nonatomic, weak) id <ICGeoStateDelegate> delegate;

- (void)selfDelegate;
- (void)forceRegionCheck;

@end

//Delegate protocol
@protocol ICGeoStateDelegate    
- (void)alertInApp;
@end
