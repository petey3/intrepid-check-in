//
//  ICRequestManager.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/17/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ICRequestManager.h"
@implementation ICRequestManager
static const NSString *slackEndPoint = @"https://hooks.slack.com/services/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";

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
    NSDictionary *postDictionary = @{@"text": @"Hey, remind me again who is here"};
    [self postToSlack:postDictionary];
}

- (void) notifySlackExit {
    
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
        NSLog(@"success");}
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
}


@end
