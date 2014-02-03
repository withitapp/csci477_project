//
//  PollDataController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Poll.h"

@interface PollDataController : NSObject

@property (nonatomic, copy) NSMutableArray *masterPollsList;
@property (nonatomic, copy) NSMutableArray *masterPollsCreatedList;

- (Poll *)objectInListAtIndex:(NSUInteger)theIndex;
- (void)addPollWithPoll:(Poll *)poll;

- (Poll *)objectInCreatedListAtIndex:(NSUInteger)theIndex;
- (void)addPollCreatedWithPoll:(Poll *)poll;

+ (PollDataController*)sharedInstance;
    
@end
