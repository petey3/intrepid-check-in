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
    CLLocationDegrees longitude = -71.080171;
    CLLocationDegrees latitude = 42.367059;
    _intrepidCenter.longitude = longitude;
    _intrepidCenter.latitude = latitude;
    
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
    //TODO: also trigger an alert
    NSLog(@"Arrived at Intrepid!");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"Receiving Updates");
}

#pragma mark - Monitoring
- (IBAction)toggleMonitoring:(UISwitch *)sender {
    if(sender.on) {
        [self.locationManager startMonitoringForRegion:self.intrepidRegion];
        [self.locationManager startUpdatingLocation];
        [self registerNotification];
        [self setMap];
        
    } else {
        [self.locationManager stopMonitoringForRegion:self.intrepidRegion];
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)setMap {
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.intrepidCenter, 250, 250);
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = self.intrepidCenter;
    pin.title = @"Intrepid Offices";
    [self.mapView addAnnotation:pin];
    [self.mapView setRegion:mapRegion animated:YES];
}

#pragma mark - UILocalNotification
- (void)registerNotification {
    
    //set up the actions for the notification
    UIMutableUserNotificationAction *acceptAction = [self createAcceptAction];
    UIMutableUserNotificationAction *declineAction = [self createDeclineAction];
    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = @"CHECK_IN_CATEGORY";
    NSArray *actions = @[acceptAction, declineAction];
    [notificationCategory setActions:actions forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:actions forContext:UIUserNotificationActionContextMinimal];
    
    //set up the setting and register the notification
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                   UIUserNotificationTypeSound|
                                   UIUserNotificationTypeBadge);
    NSSet *categories = [NSSet setWithObject:notificationCategory];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                             categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    //set up the notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You arrived at Intrepid!";
    localNotification.region = self.intrepidRegion;
    localNotification.regionTriggersOnce = YES;
    
    localNotification.category = notificationCategory.identifier;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - Notification Actions
- (UIMutableUserNotificationAction *)createAcceptAction {
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Post to Slack";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    return acceptAction;
}

- (UIMutableUserNotificationAction *)createDeclineAction {
    UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
    
    declineAction.identifier = @"DECLINE_IDENTIFIER";
    declineAction.title = @"I know.";
    declineAction.activationMode = UIUserNotificationActivationModeBackground;
    declineAction.destructive = NO;
    declineAction.authenticationRequired = NO;
    
    return declineAction;
}

@end
