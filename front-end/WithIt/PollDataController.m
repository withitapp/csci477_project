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
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

#define serverURL [NSURL URLWithString:@"http://api.withitapp.com"]
//#define dummyURL [NSURL URLWithString:@"https://gist.githubusercontent.com/oguzbilgic/9280772/raw/5712b87f2c3dc7908290f936bf8bc6821eb65c14/polls.json"]
#define dummyURL [NSURL URLWithString:@"http://gist.githubusercontent.com/oguzbilgic/9283570/raw/9e63c13790a74ffc51c5ea4edb9004d7e5246622/polls.json"]
#define dummyPostURL [NSURL URLWithString:@"http://withitapp.com:3000/auth"]
//#define dummyURL [NSURL URLWithString:@"http://withitapp.com:3000/polls"]
//#define userDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/users.json"]
#define userDataURL [NSURL URLWithString:@"http://withitapp.com:3000/auth"]
#define pollDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/polls.json"]
#define userDataPopURL [NSURL URLWithString:@"http://withitapp.com:3000/users?id=1"]

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
    }
   
   token:
   CAAIK6ZAZCePloBAC556xyZAEJUR7dvgY0mkHDvOwx4PqUexQDLKp0soudZCkxfB722VkZAICGb7BiW01qGh54Lc8bwo1cxLfc9bcbwqKyAVcriZBrsCLA3ZBZBCrnsJyZCp2Q6BGZBk7KBFop1EcZAWodTMa9U6nICwszd1noAczkNAdQ5pgRpt9ILoavdWnXFtrc0VKPY58YJj1kZBjSaXiTYRZCol8EGPTb65cZD*/
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [[FBSessionTokenCachingStrategy alloc] init];
    FBAccessTokenData * fbtoken = [tokenCachingStrategy fetchFBAccessTokenData];
    NSLog(@"FB token string %@", fbtoken.accessToken);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSLog(@"FB token expiration date %@", [formatter stringFromDate:fbtoken.expirationDate]);
    NSLog(@"FB token refresh date %@", [formatter stringFromDate:fbtoken.permissionsRefreshDate]);
    
    [self postUser:fbtoken.accessToken fbID:appDelegate.userID];
    //[self retrievePolls];
    
    
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
        
       // [self retrievePolls];
    
       // [self addPollCreatedWithPoll:poll];
        return self;
    
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
                               
                               for(NSDictionary *thePoll in polls){
                                   
                                       // NSString *pollID = thePoll[@"id"];
                                 //  for(NSString *theID in self.userPollsList){
                                     //  if([pollID isEqualToString:theID]){
                                    NSLog(@"-Adding poll to masterpolls list-");
                                   poll = [[Poll alloc] init];
                                   poll.pollID = thePoll[@"id"];
                                  // poll.createDate = [self convertJSONDate:thePoll[@"created_at"]];
                                   poll.createDate = thePoll[@"created_at"];
                                  // poll.updatedAt = [self convertJSONDate:thePoll[@"updated_at"]];
                                   poll.updatedAt = thePoll[@"updated_at"];
                                   poll.title = thePoll[@"title"];
                                   poll.description = thePoll[@"description"];
                                   poll.creatorID = thePoll[@"user_id"];
                                  // poll.endDate = [self convertJSONDate:thePoll[@"ends_at"]];
                                   poll.endDate = thePoll[@"ends_at"];
                                 
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


//post request of token
- (void)postUser:(NSString *)fbToken fbID:(NSString *)fbID//:(NSArray *)polls
{
    NSLog(@"Posting user token to session");
   // NSURL *pollsURL = dummyPostURL;
    NSLog(@"URL posting to is: %@", dummyPostURL);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:dummyPostURL];
   
    /*NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 fbID, @"facebook_id",
                                 fbToken, @"fb_token",
                                 nil]; */
   // [postRequest setValue:requestData forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"fb_id=%@&fb_token=%@",fbID,fbToken];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest setHTTPBody:requestBodyData];
    
    
   // NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
    
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:postRequest
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
                               
                                // Get user data including polls
                                NSData *userData = [[NSData alloc] initWithContentsOfURL:userDataURL];
                                NSError *userDataError;
                                NSDictionary *users = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:&userDataError][@"users"];
                                
                                if(userDataError){
                                NSLog(@"Error loading user data JSON: %@", [userDataError localizedDescription]);
                                }
                                else {
                                NSLog(@"JSON user data loaded after post request.");
                                //NSLog(@"%@", users);
                                }
                               
                               User *user;
                               
                                // Parse user data
                                for(NSDictionary *theUser in users){
                                   // user.ID = theUser[@"id"];
                                    NSLog(@"id: %@", theUser[@"id"]);
                                //if([theID == appDelegate.userID]){
                               // self.userID = theUser[@"id"];
                                    user.created_at = theUser[@"created_at"];
                                    user.updated_at = theUser[@"updated_at"];
                                    user.username = theUser[@"username"];
                                    user.email = theUser[@"email"];
                                    user.first_name = theUser[@"first_name"];
                                    NSLog(@"user name: %@", user.first_name);
                                    user.last_name = theUser[@"last_name"];
                                    user.fb_id = theUser[@"fb_id"];
                                    user.fb_token = theUser[@"fb_token"];
                                    user.fb_synced_at = theUser[@"fb_synced_at"];
                             /*
                                self.userName = theUser[@"name"]; // We actually want to check our stored name for the user with their current Facebook name here
                                self.userFriendsList = theUser[@"friends"];
                                self.userPollsList = theUser[@"polls"];*/
                                break;
                                
                                }
                               
                              
                               
                               
                               dispatch_semaphore_signal(semaphore);
                           }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //return polls;
}


//- (void)retrieveUser

- (NSDate *) convertJSONDate:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SS'Z'"];
    
	NSDate *result = [dateFormatter dateFromString:dateString];
    NSLog(@"Date from string is: %@", dateString );
	return result;

}

@end
