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
#define dummyURL [NSURL URLWithString:@"http://gist.githubusercontent.com/oguzbilgic/9283570/raw/9e63c13790a74ffc51c5ea4edb9004d7e5246622/polls.json"]
#define dummyPostURL [NSURL URLWithString:@"http://withitapp.com:3000/auth"]
#define userDataURL [NSURL URLWithString:@"http://withitapp.com:3000/auth"]
#define pollDataURL [NSURL URLWithString:@"http://withitapp.com:3000/polls"]
#define userDataPopURL [NSURL URLWithString:@"http://withitapp.com:3000/users?id=1"]

@interface PollDataController () <NSURLConnectionDelegate>
- (id)init;
@end

@implementation PollDataController

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

- (void)loadData
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [[FBSessionTokenCachingStrategy alloc] init];
    FBAccessTokenData * fbtoken = [tokenCachingStrategy fetchFBAccessTokenData];
    NSLog(@"FB token string %@", fbtoken.accessToken);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSLog(@"FB token expiration date %@", [formatter stringFromDate:fbtoken.expirationDate]);
    NSLog(@"FB token refresh date %@", [formatter stringFromDate:fbtoken.permissionsRefreshDate]);
    
    [self postUser:fbtoken.accessToken fbID:appDelegate.userID];
    [self retrievePolls];
}

- (void)initializeDefaultDataList {
    
    NSMutableArray *pollsList = [[NSMutableArray alloc] init];
    self.masterPollsList = pollsList;
    
    NSMutableArray *createdPollsList = [[NSMutableArray alloc] init];
    self.masterPollsCreatedList = createdPollsList;
    
    NSMutableArray *expiredPollsList = [[NSMutableArray alloc] init];
    self.masterPollsExpiredList = expiredPollsList;
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

- (void)setMasterPollsExpiredList:(NSMutableArray *)newList {
    if (_masterPollsExpiredList != newList) {
        _masterPollsExpiredList = [newList mutableCopy];
    }
}

- (id)init {
        semaphore = dispatch_semaphore_create(0);
        
    NSMutableArray *pollsList = [[NSMutableArray alloc] init];
    self.masterPollsList = pollsList;
        
    NSMutableArray *createdPollsList = [[NSMutableArray alloc] init];
    self.masterPollsCreatedList = createdPollsList;
    
    NSMutableArray *expiredPollsList = [[NSMutableArray alloc] init];
    self.masterPollsExpiredList = expiredPollsList;
    
    // [self retrievePolls];
    NSLog(@"Init polldatacontroller");
    // [self addPollCreatedWithPoll:poll];
    return self;
    
        NSLog(@"Init polldatacontroller");
        return self;
}

- (Poll *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.masterPollsList objectAtIndex:theIndex];
}

- (void)addPollWithPoll:(Poll *)poll {
    [self.masterPollsList addObject:poll];
}

- (void)deleteObjectInListAtIndex:(NSUInteger)theIndex{
    if(theIndex < [self.masterPollsList count]){
        [self.masterPollsList removeObjectAtIndex:theIndex];
    }
}

- (Poll *)objectInCreatedListAtIndex:(NSUInteger)theIndex {
    return [self.masterPollsCreatedList objectAtIndex:theIndex];
}

- (void)addPollCreatedWithPoll:(Poll *)poll {
    [self.masterPollsCreatedList addObject:poll];
    [self postPoll:poll];
}

- (void)deleteObjectInCreatedListAtIndex:(NSUInteger)theIndex {
    if(theIndex < [self.masterPollsCreatedList count]){
        [self.masterPollsCreatedList removeObjectAtIndex:theIndex];
    }
}

- (Poll *)objectInExpiredListAtIndex:(NSUInteger)theIndex {
    return [self.masterPollsExpiredList objectAtIndex:theIndex];
}

- (void)addPollExpiredWithPoll:(Poll *)poll {
    [self.masterPollsExpiredList addObject:poll];
}

- (void)deleteObjectInExpiredListAtIndex:(NSUInteger)theIndex {
    if(theIndex < [self.masterPollsExpiredList count]){
        [self.masterPollsExpiredList removeObjectAtIndex:theIndex];
    }
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    NSLog(@"Redirect Response!!");
    NSURLRequest *newRequest = request;
    
    NSLog(@"Redirect!");
    if (redirectResponse)
    {
        newRequest = nil;
    }
    return newRequest;
}

-(NSDictionary*) makeServerRequestWithRequest:(NSURLRequest *)request
{
    __block NSDictionary *dataDictionary;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
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
                                   message = @"Error fetching data.";
                                   NSLog(@"URL error: %@", error);
                                   showAlert();
                                   return;
                               }
                               
                               // Get user data including polls
                               NSError *dataError;
                               //NSDictionary *dataDictionary;
                               @try{
                                    dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&dataError];
                               } @catch (NSException *NSInvalidArgumentException){
                                   NSLog(@"Got invalid data: %@", NSInvalidArgumentException);
                               }
                               if(dataError){
                                   NSLog(@"Error loading data JSON: %@", [dataError localizedDescription]);
                               }
                
                               dispatch_semaphore_signal(semaphore);
                           }];
    
    NSLog(@"Sempaphore dispatched");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return dataDictionary;
}

- (void)postPoll:(Poll *)poll
{
    NSLog(@"Posting poll with URL: %@", pollDataURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pollDataURL];
    [request setHTTPMethod:@"POST"];
    NSString *pollData = [poll convertToJSON];
    if(!pollData)
    {
        NSLog(@"Poll data didn't convert to JSON correctly!");
        return;
    }
    NSData *requestBodyData = [pollData dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    NSDictionary *feedback = [self makeServerRequestWithRequest:request];
}

// Retrieve poll data from the server
- (void)retrievePolls
{
    NSLog(@"Retrieving poll data with URL: %@", pollDataURL);
    
    // Create the request with an appropriate URL
    NSURLRequest *request = [NSURLRequest requestWithURL:pollDataURL];
    // Dispatch the request and save the returned data
    NSDictionary *polls = [self makeServerRequestWithRequest:request];
    // Copy the creatorID from AppDelegate
    NSNumber *creatorID = ((AppDelegate *)[UIApplication sharedApplication].delegate).ID;
    NSMutableArray *updatePollsList = [[NSMutableArray alloc] init];
    Poll *poll;
    
    for(NSDictionary *thePoll in polls){
        poll = [[Poll alloc] init];
        poll.pollID = thePoll[@"id"];
        poll.createDate = thePoll[@"created_at"];
        poll.updatedAt = thePoll[@"updated_at"];
        poll.title = thePoll[@"title"];
        poll.description = thePoll[@"description"];
        poll.creatorID = thePoll[@"user_id"];
        poll.endDate = thePoll[@"ends_at"];
        [updatePollsList addObject:poll];
    }
    for( poll in updatePollsList){
        
        if([creatorID isEqualToNumber:poll.creatorID]){
            NSLog(@"Poll %@ added to created list.", poll.title);
            [self.masterPollsCreatedList addObject:poll];
        }
        else{
            [self.masterPollsList addObject:poll];
        }
    }
    [updatePollsList removeAllObjects];
}

- (void)postUser:(NSString *)fbToken fbID:(NSString *)fbID
{
    NSLog(@"Posting user token to session with URL: %@", dummyPostURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dummyPostURL];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"fb_id=%@&fb_token=%@",fbID,fbToken];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    NSDictionary *users = [self makeServerRequestWithRequest:request];

    User *user;
    //NSLog(@"Type of data received: %@, ", [users class]);
    
    // Parse user data
    user = [[User alloc] init];
    user.ID = users[@"id"];
    user.created_at = users[@"created_at"];
    user.updated_at = users[@"updated_at"];
    user.username = users[@"username"];
    user.email = users[@"email"];
    user.first_name = users[@"first_name"];
    NSLog(@"user name: %@", user.first_name);
    user.last_name = users[@"last_name"];
    user.fb_id = users[@"fb_id"];
    user.fb_token = users[@"fb_token"];
    user.fb_synced_at = users[@"fb_synced_at"];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.ID = user.ID;
}

/*- (void)retrievePolls
{
    NSLog(@"Retrieving Poll Data");
    NSLog(@"URL: %@", pollDataURL);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSURLRequest *request = [NSURLRequest requestWithURL:pollDataURL];
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
                               NSData *pollsData;// = [[NSData alloc] initWithContentsOfURL:dummyPostURL];
                               NSError *pollDataError;
                               NSLog(@"Trying to load JSON data");
                               NSMutableArray *polls = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&pollDataError];//[@"polls"];
                               
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
                                   // poll.membershipIDs = thePoll[@"membership_ids"];  = [updatePollsList mutableCopy]
                                   [updatePollsList addObject:poll];
                                   // break;
                                   
                               }
                               for( poll in updatePollsList){
                                  
                                   if([appDelegate.ID isEqualToNumber:poll.creatorID]){
                                       NSLog(@"Poll %@ added to created list.", poll.title);
                                       [self.masterPollsCreatedList addObject:poll];
                                   }
                                   else{
                                       [self.masterPollsList addObject:poll];
                                   }
                               }
                               [updatePollsList removeAllObjects];
                               
                               
                               dispatch_semaphore_signal(semaphore);
                           }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //return polls;
}*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSLog(@"Got response in delegate method");
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"Got recieveData");
    [_responseData appendData:data];
}


//post request of token
/*- (void)postUser:(NSString *)fbToken fbID:(NSString *)fbID//:(NSArray *)polls
{
    NSLog(@"Posting user token to session");
    // NSURL *pollsURL = dummyPostURL;
    NSLog(@"URL posting to is: %@", dummyPostURL);
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:dummyPostURL];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
     fbID, @"facebook_id",
     fbToken, @"fb_token",
     nil];
    // [postRequest setValue:requestData forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"fb_id=%@&fb_token=%@",fbID,fbToken];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest setHTTPBody:requestBodyData];
    
    
    // NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
    
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSLog(@"Sending request");
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *httpResponse;
                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   httpResponse = (NSHTTPURLResponse *) response;
                                   NSLog(@"Got response!");
                               }
                               NSLog(@"response noted");
                               // NSURLConnection's completionHandler is called on the background thread.
                               // Prepare a block to show an alert on the main thread:
                               __block NSString *message = @"";
                               void (^showAlert)(void) = ^{
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                       NSLog(@"$$ in operation queue $$");
                                       [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   }];
                               };
                               
                               // Check for error or non-OK statusCode:
                               if (error || httpResponse.statusCode != 200) {
                                   message = @"Error fetching users";
                                   NSLog(@"URL error: %@", error);
                                   showAlert();
                                   return;
                               }
                               
                                // Get user data including polls
                              // NSData *userData= [[NSData alloc] init];
                               NSError *userDataError;
                    
                               
                               NSDictionary *users;
                               @try{
                                   users = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&userDataError];//[@"user"];
                               
                               } @catch (NSException *NSInvalidArgumentException){
                                   NSLog(@"Got invalid data from server when posting user error is: %@", NSInvalidArgumentException);
                               }
                               
                                if(userDataError){
                                NSLog(@"Error loading user data JSON: %@", [userDataError localizedDescription]);
                                }
                                else {
                                NSLog(@"JSON user data loaded after post request.");
                                //NSLog(@"%@", users);
                                }
                               
                               User *user;
                               NSLog(@"Type of data received: %@, ", [users class]);
                                // Parse user data
                               NSDictionary *theUser = users;
                               // for(theUser in users){
                                    user = [[User alloc] init];
                                  
                                    user.ID = theUser[@"id"];
                                   // NSLog(@"1User ID is: %@", theUser[@"id"]);
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
                          
                               appDelegate.ID = user.ID;
                               NSLog(@"2User ID is: %@", appDelegate.ID);
                               NSLog(@"3User ID is: %@", user.ID);
 
                                self.userName = theUser[@"name"]; // We actually want to check our stored name for the user with their current Facebook name here
                                self.userFriendsList = theUser[@"friends"];
                                self.userPollsList = theUser[@"polls"];
                                break;
                               
                               
                               NSLog(@"Outta here");
                               
                               dispatch_semaphore_signal(semaphore);
                           }];
    NSLog(@"Sempaphore dispatched");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //return polls;
}*/


//- (void)retrieveUser

- (NSDate *) convertJSONDate:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	NSDate *result = [dateFormatter dateFromString:dateString];
    NSLog(@"Date from string is: %@", dateString );
	return result;

}

-(void) determineExpiredPoll
{

     NSDate *currentDate=[NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit |NSMonthCalendarUnit | NSYearCalendarUnit fromDate:currentDate];
    NSInteger currentHour = [components hour];
    NSInteger currentMinute = [components minute];
    NSInteger currentSecond = [components second];
    NSInteger currentYear = [components year];
    NSInteger currentMonth = [components month];
    NSInteger currentDay = [components day];
    
    NSLog(@"Time now is: %ld / %ld / %ld / %ld :%ld: %ld ",currentMonth,currentDay,currentYear, currentHour,(long)currentMinute,(long)currentSecond);
    
    NSString *pollEndDate;
    NSDateFormatter* df;
    NSDate* pollDate; //nil

    
NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *pollComponents;
    NSInteger pollHour;
    NSInteger pollMinute;
    NSInteger pollSecond;
    NSInteger pollYear;
    NSInteger pollMonth;
    NSInteger pollDay;
    
    
    for(int d = 0; d < [_masterPollsList count];d++)
    {
        pollEndDate = [self objectInListAtIndex:d].endDate;
        df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        pollDate = [df dateFromString:pollEndDate]; //nil
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        pollDate = [df dateFromString:pollEndDate]; // Not nil
        
        pollComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit |NSMonthCalendarUnit | NSYearCalendarUnit fromDate:pollDate];
        pollHour = [pollComponents hour];
        pollMinute = [pollComponents minute];
        pollSecond = [pollComponents second];
        pollYear = [pollComponents year];
        pollMonth = [pollComponents month];
        pollDay = [pollComponents day];
        
        NSLog(@"Poll %d end time is %@ ",d, pollEndDate);
        NSLog(@"Poll %d is: %ld / %ld / %ld / %ld :%ld: %ld ",d,pollMonth,pollDay,pollYear, pollHour,(long)pollMinute,(long)pollSecond);
        if([currentDate compare:pollDate] == NSOrderedDescending)
        {
            NSLog(@"Expired Poll!!");
            [self addPollExpiredWithPoll:[self objectInListAtIndex:d]];
            [self deleteObjectInListAtIndex:d];
            d--;
        }
        
        }
    
    
    for(int d = 0; d < [_masterPollsCreatedList count];d++)
    {
        pollEndDate = [self objectInCreatedListAtIndex:d].endDate;
        df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        pollDate = [df dateFromString:pollEndDate]; //nil
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        pollDate = [df dateFromString:pollEndDate]; // Not nil
        
        pollComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit |NSMonthCalendarUnit | NSYearCalendarUnit fromDate:pollDate];
        pollHour = [pollComponents hour];
        pollMinute = [pollComponents minute];
        pollSecond = [pollComponents second];
        pollYear = [pollComponents year];
        pollMonth = [pollComponents month];
        pollDay = [pollComponents day];
        
        NSLog(@"Poll %d end time is %@ ",d, pollEndDate);
        NSLog(@"Poll %d is: %ld / %ld / %ld / %ld :%ld: %ld ",d,pollMonth,pollDay,pollYear, pollHour,(long)pollMinute,(long)pollSecond);
        if([currentDate compare:pollDate] == NSOrderedDescending)
        {
            NSLog(@"Expired Poll!!");
            [self addPollExpiredWithPoll:[self objectInCreatedListAtIndex:d]];
            [self deleteObjectInCreatedListAtIndex:d];
        }
        
    }
    
}

@end
