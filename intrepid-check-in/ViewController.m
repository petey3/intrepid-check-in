//
//  ViewController.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/16/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *monitorToggle;
@property (weak, nonatomic) IBOutlet UILabel *monitorLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) CLCircularRegion *intrepidRegion;

@property (nonatomic) CLLocationCoordinate2D intrepidCenter;
@property (nonatomic) CLLocationDistance radius;
@property (strong, nonatomic) NSString *intrepidID;

@end

@implementation ViewController

#pragma mark - Initializers
- (CLLocationManager *)locationManager {
    if(!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
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

- (CLLocationCoordinate2D)intrepidCenter {
    CLLocationDegrees longitude = 42.36;
    CLLocationDegrees lattitude = -71.08;
    _intrepidCenter.longitude = longitude;
    _intrepidCenter.latitude = lattitude;
    
    return _intrepidCenter;
}

- (CLLocationDistance)radius {
    _radius = 50.0;
    return _radius;
}

- (NSString *)intrepidID {
    if(!_intrepidID) {
        _intrepidID = @"Intrepid Pursits";
    }
    return _intrepidID;
}

#pragma mark - ViewControllerDelegate
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mapView.layer.borderColor = self.monitorToggle.onTintColor.CGColor;
    self.mapView.layer.borderWidth = 5.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Arrived at Intrepid!");
}

#pragma mark - Monitoring
- (IBAction)toggleMonitoring:(UISwitch *)sender {
    if(sender.on) {
        [self.locationManager startMonitoringForRegion:self.intrepidRegion];
        [self.locationManager startUpdatingLocation];
        [self registerNotification];
        
        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.intrepidCenter, 500, 500);
        [self.mapView setRegion:mapRegion animated:YES];
        
    } else {
        [self.locationManager stopMonitoringForRegion:self.intrepidRegion];
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - UILocalNotification
- (void)registerNotification {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You arrived at Intrepid!";
    localNotification.region = self.intrepidRegion;
    localNotification.regionTriggersOnce = YES;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
