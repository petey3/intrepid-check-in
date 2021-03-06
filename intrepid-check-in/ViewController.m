//
//  ViewController.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/16/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ViewController.h"
#import "ICRequestManager.h"
#import "ICGeoState.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *monitorToggle;
@property (weak, nonatomic) IBOutlet UILabel *monitorLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISwitch *autoPostToggle;
@property (strong, nonatomic) ICGeoState *geoState;

@end

@implementation ViewController

#pragma mark - Initializers
- (ICGeoState *)geoState {
    if(!_geoState) _geoState = [[ICGeoState alloc] init];
    return _geoState;
}

#pragma mark - ViewControllerDelegate
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mapView.layer.borderColor = self.monitorToggle.onTintColor.CGColor;
    self.mapView.layer.borderWidth = 5.0f;
    self.geoState.delegate = self;
}

#pragma mark - Monitoring
- (IBAction)toggleMonitoring:(UISwitch *)sender {
    if(sender.on) {
        [self.geoState selfDelegate];
        [self.geoState.locationManager startMonitoringForRegion:self.geoState.intrepidRegion];
        [self.geoState.locationManager startUpdatingLocation];
        [self registerNotification];
        [self setMap];
        [self.geoState forceRegionCheck];
        
    } else {
        [self.geoState.locationManager stopMonitoringForRegion:self.geoState.intrepidRegion];
        [self.geoState.locationManager stopUpdatingLocation];
        self.geoState.locationManager.delegate = nil;
    }
}

- (IBAction)toggleAutoPost:(UISwitch *)sender {
    self.geoState.autoPost = sender.on;
    
    //If the user has entered the region but did not post
    //Then turns on auto-post, we will post it for them
    if(sender.on &&
       self.geoState.enteredRegion &&
       ![ICRequestManager manager].postedToSlack) {
        [[ICRequestManager manager] notifySlackArrival];
    }
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
    localNotification.region = self.geoState.intrepidRegion;
    localNotification.region.notifyOnExit = NO;
    localNotification.regionTriggersOnce = NO;
    
    localNotification.category = notificationCategory.identifier;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - Notification Actions
- (UIMutableUserNotificationAction *)createAcceptAction {
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Post to Slack!";
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

#pragma mark - ICGeoStateDelegate
- (void)alertInApp {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Arrived!"
                                        message:@"Do you want to post to Slack?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *post =
    [UIAlertAction actionWithTitle:@"Yes"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               NSLog(@"Post to slack");
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }];
    
    UIAlertAction *ignore =
    [UIAlertAction actionWithTitle:@"No"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction *action) {
                               NSLog(@"Ignore slack");
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }];
    
    [alert addAction:post];
    [alert addAction:ignore];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MapKit
- (void)setMap {
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.geoState.intrepidCenter, 250, 250);
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = self.geoState.intrepidCenter;
    pin.title = @"Intrepid Offices";
    [self.mapView addAnnotation:pin];
    [self.mapView setRegion:mapRegion animated:YES];
}

@end
