//
//  Poll.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property NSString *pollID;
@property NSString *title;
@property NSString *description;
@property NSString *creatorID;
@property NSDate *endDate;
@property NSDate *endTime;
@property NSMutableArray *members;

-(id)initWithName:(NSString *)name creatorName:(NSString *)creatorName dateCreated:(NSDate *)dateCreated;
@end
