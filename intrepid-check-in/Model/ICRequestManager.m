//
//  ICRequestManager.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/17/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ICRequestManager.h"
@interface ICRequestManager()
@property (nonatomic, readwrite) BOOL postedToSlack;
@end

@implementation ICRequestManager
static NSString *slackEndPoint = @"https://hooks.slack.com/services/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";
static NSString *profilePicture = @"https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-06-08/6128275456_5d5426e3532b10a50f36_192.jpg";
static NSString *profileName = @"doyunglee";

#pragma mark - Class Methods
+ (instancetype)manager {
    static id sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Instance Methods
- (void) notifySlackArrival {
    NSDictionary *postDictionary = @{@"text": @"Don't mind me, I'm just Doyung Lee!",
                                     @"username": profileName,
                                     @"icon_url": profilePicture};
    [self postToSlack:postDictionary];
}

- (void) notifySlackExit {
    NSDictionary *postDictionary = @{@"text": @"Brb",
                                     @"username": profileName,
                                     @"icon_url": profilePicture};
    [self postToSlack:postDictionary];
}

#pragma mark - Network Utilities
- (void) postToSlack:(NSDictionary *)postDictionary {
    //Set up the operations manager
    AFHTTPRequestOperationManager *manager =[AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //Post the operation
    [manager POST:slackEndPoint parameters:postDictionary
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.postedToSlack = YES;
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              self.postedToSlack = NO;
          }];
}


@end
