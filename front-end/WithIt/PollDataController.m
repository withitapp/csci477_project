//
//  PollDataController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataController.h"
#import "PollDataController.h"
#include "AppDelegate.h"
#import "Poll.h"
#import "User.h"

#define serverURL [NSURL URLWithString:@"http://api.withitapp.com"]
//#define dummyURL [NSURL URLWithString:@"https://gist.githubusercontent.com/oguzbilgic/9280772/raw/5712b87f2c3dc7908290f936bf8bc6821eb65c14/polls.json"]
#define dummyURL [NSURL URLWithString:@"http://gist.githubusercontent.com/oguzbilgic/9283570/raw/9e63c13790a74ffc51c5ea4edb9004d7e5246622/polls.json"]
#define userDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/users.json"]
#define pollDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/polls.json"]

@interface PollDataController ()
- (id)init;
@end

@implementation PollDataController

- (void)loadData
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
  /*  // Get user data including polls
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
    }*/
    [self retrievePolls];
    
    
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
 /*
- (void)initializeDefaultDataList {
    
    NSMutableArray *pollsList = [[NSMutableArray alloc] init];
    self.masterPollsList = pollsList;
    
    NSMutableArray *createdPollsList = [[NSMutableArray alloc] init];
    self.masterPollsCreatedList = createdPollsList;
    
    Poll *poll;
  //  NSDate *today = [NSDate date];
    poll = [[Poll alloc] initWithName:@"Default member poll" creatorName:@"Francesca" description:@"No description given"];
    [self addPollWithPoll:poll];
    
    poll = [[Poll alloc] initWithName:@"Default creator poll" creatorName:@"Francesca" description:@"No description given"];
    [self addPollCreatedWithPoll:poll];
}*/

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
        semaphore = dispatch_semaphore_create(0);
   // if (self = [super init]) { ?? commented out by patrick
        //self.dummyURL
        //self.serverURL = serverURL;
        
        NSMutableArray *pollsList = [[NSMutableArray alloc] init];
        self.masterPollsList = pollsList;
        
        NSMutableArray *createdPollsList = [[NSMutableArray alloc] init];
        self.masterPollsCreatedList = createdPollsList;
        
        [self retrievePolls];
    
        
      //  poll = [[Poll alloc] initWithName:@"Default creator poll" creatorName:@"Francesca" description:@"No description given"];
       // [self addPollCreatedWithPoll:poll];
        return self;
        //[self initializeDefaultDataList];
  //      return self;
    //}
   // return nil;
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

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    NSURLRequest *newRequest = request;
    
    if (redirectResponse)
    {
        newRequest = nil;
    }
    return newRequest;
}

- (void)retrievePolls//:(NSArray *)polls
{
    NSLog(@"Retrieving Poll Data");
  //  NSURL *weatherURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%F%@%f", self.weatherURLStr1, coordinate.latitude, self.weatherURLStr2, coordinate.longitude]];
    NSURL *pollsURL = dummyURL;
    NSLog(@"URL: %@", dummyURL);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:dummyURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSMutableArray *updatePollsList = [[NSMutableArray alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *httpResponse = nil;
                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   httpResponse = (NSHTTPURLResponse *) response;
                               }
                               
                               // NSURLConnection's completionHandler is called on the background thread.
                               // Prepare a block to show an alert on the main thread:
                               __block NSString *message = @"";
                               void (^showAlert)(void) = ^{
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                       [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   }];
                               };
                               
                               // Check for error or non-OK statusCode:
                               if (error || httpResponse.statusCode != 200) {
                                   message = @"Error fetching polls";
                                   NSLog(@"URL error: %@", error);
                                   showAlert();
                                   return;
                               }
                               
                               // Parse the JSON response:
                               NSError *jsonError = nil;
                               
                               
                               ////poll data
                               // Get poll data
                               NSData *pollsData = [[NSData alloc] initWithContentsOfURL:dummyURL];
                               NSError *pollDataError;
                               NSLog(@"Trying to load JSON data");
                               NSMutableArray *polls = [NSJSONSerialization JSONObjectWithData:pollsData options:NSJSONReadingMutableContainers error:&pollDataError];//[@"polls"];
                               
                               NSLog(@"JSON poll data loaded.");
                               if(pollDataError){
                                   NSLog(@"Error loading poll data JSON: %@", [pollDataError localizedDescription]);
                                   message = @"Error parsing response";
                                   showAlert();
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
                                   
                                       // NSString *pollID = thePoll[@"id"];
                                 //  for(NSString *theID in self.userPollsList){
                                     //  if([pollID isEqualToString:theID]){
                                    NSLog(@"-Adding poll to masterpolls list-");
                                   poll = [[Poll alloc] init];
                                   poll.pollID = thePoll[@"ID"];
                                   [self dateFromString:thePoll[@"CreatedAt"]];
                                  // poll.createDate = thePoll[@"created_at"];
                                   poll.updatedAt = thePoll[@"UpdatedAt"];
                                   poll.title = thePoll[@"Title"];
                                   poll.description = thePoll[@"Description"];
                                   poll.creatorID = thePoll[@"UserID"];
                                   poll.endDate = thePoll[@"EndsAt"];
                                 //  [self dateFromString:thePoll[@"CreatedAt"]];
                                   //NSMutableArray *members = [NSJSONSerialization JSONObjectWithData:thePoll[@"member_ids"] options:NSJSONReadingMutableContainers error:&memberDataError];
                              //     poll.members = [polls valueForKey:@"member_ids"];
                              //     poll.membershipIDs = [polls valueForKey:@"membership_ids"];
                                //   description = [[weather objectAtIndex:0] objectForKey:@"description"];
                                  // poll.members = thePoll[@"member_ids"];
                                  // poll.membershipIDs = thePoll[@"membership_ids"];
                                   [updatePollsList addObject:poll];
                                          // break;
                                   
                               }
                               self.masterPollsList = [updatePollsList mutableCopy];
                               [updatePollsList removeAllObjects];
                               
                               
                               dispatch_semaphore_signal(semaphore);
                           }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //return polls;
}

- (NSDate *) dateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SS'Z'"];
    
	NSDate *result = [dateFormatter dateFromString:dateString];
    NSLog(@"Date from string is: %@", [dateFormatter stringFromDate:result] );
	return result;

}

@end
