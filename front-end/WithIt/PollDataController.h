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
#import "UserDataController.h"

@interface PollDataController : DataController
{
    NSMutableData *_responseData;
}



// User information
// User specific information
@property (strong, nonatomic) UserDataController *userDataController;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSMutableArray *userFriendsList;
@property (strong, nonatomic) NSMutableArray *userPollsList;
@property NSString *dummyURL;
@property NSString *serverURL;

//@property (nonatomic, copy) NSMutableArray *updatePollsList; //maybe make this a local array in datacontroller retrieve polls
@property (nonatomic, copy) NSMutableArray *masterPollsList;
@property (nonatomic, copy) NSMutableArray *masterPollsCreatedList;
@property (nonatomic, copy) NSMutableArray *masterPollsExpiredList;

- (Poll *)objectInListAtIndex:(NSUInteger)theIndex;
- (void)addPollWithPoll:(Poll *)poll;
- (void)deleteObjectInListAtIndex:(NSUInteger)theIndex;

- (Poll *)objectInCreatedListAtIndex:(NSUInteger)theIndex;
- (void)addPollCreatedWithPoll:(Poll *)poll;
- (void)deleteObjectInCreatedListAtIndex:(NSUInteger)theIndex;

- (Poll *)objectInExpiredListAtIndex:(NSUInteger)theIndex;
- (void)addPollExpiredWithPoll:(Poll *)poll;
- (void)deleteObjectInExpiredListAtIndex:(NSUInteger)theIndex;


- (void)loadData;
+ (PollDataController*)sharedInstance;
//api calls
- (NSDate *)convertJSONDate:(NSString *) dateString;
- (void)postUser:(NSString *)appLinkToken fbID:(NSString *) fbID;

//all 4 done
- (Poll *)postPoll:(Poll *) poll;
- (void)retrievePolls;
- (void)updatePoll:(Poll *)poll;
- (void)deletePoll:(Poll *)poll;



- (void)determineExpiredPoll;

    
@end
