//
//  ICSettings.h
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/19/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICSettings : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *arriveMsg;
@property (strong, nonatomic) NSString *departureMsg;

@property (nonatomic) BOOL autoPost;
@property (nonatomic) BOOL alertInApp;

+ (instancetype)sharedSettings;

@end
