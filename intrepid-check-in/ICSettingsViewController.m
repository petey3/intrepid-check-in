//
//  ICSettingsViewController.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/19/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ICSettingsViewController.h"
#import "ICRequestManager.h"
#import "ICSettings.h"

@interface ICSettingsViewController ()

@end

@implementation ICSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIElements

- (IBAction)toggleAutoPost:(UISwitch *)sender {
    [ICSettings sharedSettings].autoPost = sender.on;
    
    //If the user has entered the region but did not post
    //Then turns on auto-post, we will post it for them
    if(sender.on &&
       //self.geoState.enteredRegion && //TODO:Store a specific geo state in settings
       ![ICRequestManager manager].postedToSlack) {
        [[ICRequestManager manager] notifySlackArrival];
    }
}

- (IBAction)updateArrivalDistance:(UISlider *)sender {
}

- (IBAction)updatedUserName:(UITextField *)sender {
}

- (IBAction)updatedArrivalMessage:(UITextField *)sender {
}

- (IBAction)updatedDepartureMessage:(UITextField *)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
