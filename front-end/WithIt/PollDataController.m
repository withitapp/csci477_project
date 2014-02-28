//
//  PollDataController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "PollDataController.h"
#include "AppDelegate.h"
#import "Poll.h"
#import "User.h"

#define userDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/users.json"]
#define pollDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/polls.json"]

@interface PollDataController ()
- (void)initializeDefaultDataList;
@end

@implementation PollDataController

- (void)loadData
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // Get user data including polls
    NSData *userData = [[NSData alloc] initWithContentsOfURL:userDataURL];
    NSError *userDataError;
    NSDictionary *users = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:&userDataError][@"users"];
    
    if(userDataError){
        NSLog(@"Error loading user data JSON: %@", [userDataError localizedDescription]);
    }
    else {
        NSLog(@"JSON user data loaded.");
        //NSLog(@"%@", users);
    }
    
    // Parse user data
    for(NSDictionary *theUser in users){
        NSString *theID = theUser[@"id"];
        if([theID isEqualToString:appDelegate.userID]){
            self.userID = theUser[@"id"];
            self.userName = theUser[@"name"]; // We actually want to check our stored name for the user with their current Facebook name here
            self.userFriendsList = theUser[@"friends"];
            self.userPollsList = theUser[@"polls"];
            break;
        }
    }
    
    // Get poll data
    NSData *pollsData = [[NSData alloc] initWithContentsOfURL:pollDataURL];
    NSError *pollDataError;
    NSDictionary *polls = [NSJSONSerialization JSONObjectWithData:pollsData options:NSJSONReadingMutableContainers error:&pollDataError][@"polls"];
	
    if(pollDataError){
        NSLog(@"Error loading poll data JSON: %@", [pollDataError localizedDescription]);
    }
    else {
        NSLog(@"JSON poll data loaded.");
        //NSLog(@"%@", polls);
    }
    
    // Parse poll data
    Poll *poll;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hhmmss"];
    
    for(NSDictionary *thePoll in polls){
        NSString *pollID = thePoll[@"id"];
        for(NSString *theID in self.userPollsList){
            if([pollID isEqualToString:theID]){
                poll = [[Poll alloc] init];
                poll.pollID = pollID;
                poll.title = thePoll[@"title"];
                poll.description = thePoll[@"description"];
                poll.creatorID = thePoll[@"creator"];
                [self addPollWithPoll:poll];
                break;
            }
        }
    }
}

// Ensure that only instance of PollDataController is ever instantiated
+ (PollDataController*)sharedInstance
{
    static PollDataController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PollDataController alloc] init];
    });
    return _sharedInstance;
}
    
- (void)initializeDefaultDataList {
    
    NSMutableArray *pollsList = [[NSMutableArray alloc] init];
    self.masterPollsList = pollsList;
    
    NSMutableArray *createdPollsList = [[NSMutableArray alloc] init];
    self.masterPollsCreatedList = createdPollsList;
    
    Poll *poll;
  //  NSDate *today = [NSDate date];
    poll = [[Poll alloc] initWithName:@"Default member poll" creatorName:@"Francesca" description:@"No description given"];
    [self addPollWithPoll:poll];
    //why is there a poll "created with" poll?
    poll = [[Poll alloc] initWithName:@"Default creator poll" creatorName:@"Francesca" description:@"No description given"];
    [self addPollCreatedWithPoll:poll];
}

- (void)setMasterPollsList:(NSMutableArray *)newList {
    if (_masterPollsList != newList) {
        _masterPollsList = [newList mutableCopy];
    }
}

- (void)setMasterPollsCreatedList:(NSMutableArray *)newList {
    if (_masterPollsCreatedList != newList) {
        _masterPollsCreatedList = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

- (Poll *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.masterPollsList objectAtIndex:theIndex];
}

- (void)addPollWithPoll:(Poll *)poll {
    [self.masterPollsList addObject:poll];
}

- (Poll *)objectInCreatedListAtIndex:(NSUInteger)theIndex {
    return [self.masterPollsCreatedList objectAtIndex:theIndex];
}

- (void)addPollCreatedWithPoll:(Poll *)poll {
    [self.masterPollsCreatedList addObject:poll];
}

@end
