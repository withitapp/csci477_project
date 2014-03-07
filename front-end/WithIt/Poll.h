//
//  Poll.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property NSNumber *pollID;
@property NSDate *updatedAt;
@property NSString *title;
@property NSString *description;
@property NSNumber *creatorID;
@property NSDate *createDate;
@property NSDate *endDate;
@property NSMutableArray *members;
@property NSMutableArray *membershipIDs;

-(id)initWithInfo:(NSString *)name creatorName:(NSString *)creatorName description:(NSString *)description endDate:(NSDate *)endDate;
-(id)initWithName:(NSString *)name creatorName:(NSString *)creatorName description:(NSString *)description;
-(id)init:(NSString *)creatorName;
-(void)populateMembers:(NSArray *) users;
-(void)addMember:(NSObject *) user;
-(void)removeMember:(NSObject *) user;


@end
