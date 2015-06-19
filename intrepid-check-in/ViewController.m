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
#import "ICSettings.h"
#import "ICSettingsViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *monitorToggle;
@property (weak, nonatomic) IBOutlet UILabel *monitorLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) ICGeoState *geoState;
@property (nonatomic) BOOL inSettings;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewVerticalAlignment;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) UIColor *goldColor;
@property (strong, nonatomic) UIColor *darkGrey;

@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;
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
    if(!_goldColor) self.goldColor = [UIColor colorWithCGColor:self.monitorToggle.onTintColor.CGColor];
    if(!_darkGrey) self.darkGrey = self.view.backgroundColor;
    self.mapView.layer.borderColor = self.goldColor.CGColor;
    self.mapView.layer.borderWidth = 5.0f;
    self.geoState.delegate = self;
    [self collapseMap];
    [self hideSettings];
}

#pragma mark - IBAction
- (IBAction)toggleMonitoring:(UISwitch *)sender {
    if(sender.on) {
        [self.geoState selfDelegate];
        [self.geoState.locationManager startMonitoringForRegion:self.geoState.intrepidRegion];
        [self.geoState.locationManager startUpdatingLocation];
        [self registerNotification];
        [self setMap];
        [self.geoState forceRegionCheck];
        if(!self.inSettings) [self expandMap];
        
    } else {
        [self.geoState.locationManager stopMonitoringForRegion:self.geoState.intrepidRegion];
        [self.geoState.locationManager stopUpdatingLocation];
        self.geoState.locationManager.delegate = nil;
        [self collapseMap];
    }
}

- (IBAction)settingsButton:(UIButton *)sender {
    if(self.inSettings) {
        self.inSettings = NO;
        [self hideSettings];
        
        if(self.monitorToggle.on) {
            [self expandMap];
        }
        
    } else {
        self.inSettings = YES;
        [self showSettings];
        
        if(self.monitorToggle.on) {
            [self collapseMap];
        }
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

#pragma mark - Subview Utility
- (void)addSettingsView {
    //UIView *settingsView = [[[NSBundle mainBundle] loadNibNamed:@"Settings" owner:self options:nil] objectAtIndex:0];
    //[self.view addSubview:settingsView];
    
    ICSettingsViewController *settingsVC = [[ICSettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
    [self addChildViewController:settingsVC];
    settingsVC.view.frame = self.settingsContainerView.bounds;
    [self.settingsContainerView addSubview:settingsVC.view];
    [self didMoveToParentViewController:self];
    
}

#pragma mark - Animations
- (void)collapseMap {
    [self.view layoutIfNeeded];
    
    self.mapViewHeight.constant = 6;
    
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)expandMap {
    [self.view layoutIfNeeded];
    
    CGFloat mapHeight = self.view.frame.size.height - 220;
    self.mapViewHeight.constant = mapHeight;

    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showSettings {
    [self.view layoutIfNeeded];
    
    //Align the map center upwards
    CGFloat mapAlignment = (self.view.frame.size.height / 2) - 100;
    self.mapViewVerticalAlignment.constant = mapAlignment;
    
    //Add the settings subview
    [self addSettingsView];
    
    //Set the settings button background
    [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"gear-black"]
                                   forState:UIControlStateNormal];
    
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
        [self elementColor:[UIColor blackColor]
                 textColor:[UIColor blackColor]
                   bgColor:self.goldColor];
        [self.settingsButton setTransform:CGAffineTransformRotate(self.settingsButton.transform, (M_PI * -0.75))];
    }];
}

- (void)hideSettings {
    [self.view layoutIfNeeded];
    
    self.mapViewVerticalAlignment.constant = 0;
    [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"gear-color"]
                                   forState:UIControlStateNormal];
    
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
        [self elementColor:self.goldColor
                 textColor:[UIColor whiteColor]
                   bgColor:self.darkGrey];
        self.settingsButton.transform = CGAffineTransformRotate(self.settingsButton.transform, M_PI*0.75);
    }];
}

- (void)elementColor:(UIColor *)elementColor textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor {
    //Set the background
    [self.view setBackgroundColor:bgColor];
    
    //Set element colors (what should be highlighted in general)
    self.headerLabel.textColor = elementColor;
    self.mapView.layer.borderColor = elementColor.CGColor;
    [self.monitorToggle setOnTintColor:elementColor];
    
    //Now set the general purpose text
    self.monitorLabel.textColor = textColor;
}

@end
