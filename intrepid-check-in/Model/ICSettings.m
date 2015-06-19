//
//  ICSettings.m
//  intrepid-check-in
//
//  Created by Eric Peterson on 6/19/15.
//  Copyright (c) 2015 Eric Peterson. All rights reserved.
//

#import "ICSettings.h"

@implementation ICSettings

#pragma mark - Class Methods
+ (instancetype)sharedSettings {
    static id sharedSettings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    
    return sharedSettings;
}

@end
