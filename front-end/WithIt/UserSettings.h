//
//  UserSettings.h
//  WithIt
//
//  Created by Francesca Nannizzi on 4/4/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSNumber *ID;

+ (UserSettings*)sharedInstance;

@end
