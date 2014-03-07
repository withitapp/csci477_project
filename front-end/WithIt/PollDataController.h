//
//  PollDataController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Poll.h"
#import "DataController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PollDataController : DataController

// User information
// User specific information
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSMutableArray *userFriendsList;
@property (strong, nonatomic) NSMutableArray *userPollsList;
@property NSString *dummyURL;
@property NSString *serverURL;

//@property (nonatomic, copy) NSMutableArray *updatePollsList; //maybe make this a local array in datacontroller retrieve polls
@property (nonatomic, copy) NSMutableArray *masterPollsList;
@property (nonatomic, copy) NSMutableArray *masterPollsCreatedList;
//@property (nonatomic, copy) NSMutableArray *masterPolls;

- (Poll *)objectInListAtIndex:(NSUInteger)theIndex;
- (void)addPollWithPoll:(Poll *)poll;

- (Poll *)objectInCreatedListAtIndex:(NSUInteger)theIndex;
- (void)addPollCreatedWithPoll:(Poll *)poll;

- (void)loadData;
+ (PollDataController*)sharedInstance;

- (NSDate *)convertJSONDate:(NSString *) dateString;
- (void)postUser:(NSString *)appLinkToken fbID:(NSString *)fbID;
//api calls
- (void)retrievePolls;//:(NSArray *)polls;
    
@end
