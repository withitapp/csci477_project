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
@property NSInteger *ID;
@property NSDate *createdAt;
@property NSDate *updateAt;
@property NSString *userName;
@property NSString *email;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *fbID;
@property NSMutableArray *friendshipID;
@property NSMutableArray *invitationID;
@property NSMutableArray *membershipID;


@end
