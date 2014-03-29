//
//  User.h
//  WithIt
//
//  Created by Patrick Dalton on 1/29/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
//probably don't even need this class...
@property NSNumber *ID;
@property NSDate *created_at;
@property NSDate *updated_at;
@property NSString *username;
@property NSString *email;
@property NSString *first_name;
@property NSString *last_name;
@property NSString *fb_id;
@property NSString *fb_token;
@property NSDate *fb_synced_at;
@property NSMutableArray *friendshipID;
@property NSMutableArray *invitationID;
@property NSMutableArray *membershipID;


@end
