//
//  UserSettings.m
//  WithIt
//
//  Created by Francesca Nannizzi on 4/4/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

// Ensure that only one instance of UserSettings is ever instantiated
+ (UserSettings*)sharedInstance
{
    static UserSettings *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[UserSettings alloc] init];
    });
    return _sharedInstance;
}

@end
