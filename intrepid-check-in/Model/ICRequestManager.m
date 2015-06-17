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
    NSDictionary *postDictionary = @{@"text": @"Don't mind me I'm just testing my super cool code! Maybe I'll write a song about it!",
                                     @"username": @"Rebecca Black",
                                     @"icon_url": @"http://i.ytimg.com/vi/kfVsfOSbJY0/maxresdefault.jpg"};
                                     //@"icon_emoji": @":kiss:"};
    [self postToSlack:postDictionary];
}

- (void) notifySlackExit {
    NSDictionary *postDictionary = @{@"text": @"Peace out fans!",
                                     @"username": @"Rebecca Black",
                                     @"icon_url": @"http://i.ytimg.com/vi/kfVsfOSbJY0/maxresdefault.jpg"};
                                     //@"icon_emoji": @":kiss:"};
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
        NSLog(@"success");}
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
}


@end
