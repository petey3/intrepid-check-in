//
//  ICRequestManager.h
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/17/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface ICRequestManager : NSObject
+ (instancetype) manager;
- (void) notifySlackArrival;
- (void) notifySlackExit;
@end
