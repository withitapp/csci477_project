//
//  Membership.h
//  WithIt
//
//  Created by Patrick Dalton on 4/11/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Membership : NSObject

@property NSNumber *ID;
@property NSString *created_at;
@property NSString *updated_at;
@property NSNumber *user_id;
@property NSNumber *poll_id;
@property NSString *response;

@end
