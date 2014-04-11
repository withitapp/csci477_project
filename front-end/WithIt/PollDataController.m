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
#define membershipURL [NSURL URLWithString:@"http://withitapp.com:3000/memberships"]
#define dummyPostURL [NSURL URLWithString:@"http://withitapp.com:3000/auth"]
#define userDataURL [NSURL URLWithString:@"http://withitapp.com:3000/users"]
#define pollDataURL [NSURL URLWithString:@"http://withitapp.com:3000/polls"]
#define userDataPopURL [NSURL URLWithString:@"http://withitapp.com:3000/users?id=1"]

//set to 1 for debug
static const NSInteger EXPIRE_TIME_DEBUG = 0;

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
    Poll *responsePoll = [self postPoll:poll];
    NSLog(@"Adding responsePoll to Master pollList");
    [self.masterPollsCreatedList addObject:responsePoll];
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
                                   // we should handle the error here
                                   dispatch_semaphore_signal(semaphore);
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
- (Poll *)postPoll:(Poll *)poll
{
    NSLog(@"Posting poll with URL: %@ and title: %@", pollDataURL, poll.title);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'SS'Z'"];
    NSString *endDate = [dateFormatter stringFromDate:poll.endDate];
    NSString *createDate = [dateFormatter stringFromDate:poll.endDate];
    NSString *updateDate = [dateFormatter stringFromDate:poll.endDate];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pollDataURL];
    [request setHTTPMethod:@"POST"];
   /* NSString *pollData = [poll convertToJSON];
    if(!pollData)
    {
        NSLog(@"Poll data didn't convert to JSON correctly!");
        return;
    }*/
    NSString *postString = [NSString stringWithFormat:@"id=%@&created_at=%@&updated_at=%@&title=%@&description=%@&user_id=%@&ends_at=%@", poll.pollID,createDate, updateDate, poll.title, poll.description, poll.creatorID, endDate];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    NSDictionary *pollFeedback = [[NSDictionary alloc] init];
    pollFeedback = [self makeServerRequestWithRequest:request];
    poll.pollID = pollFeedback[@"id"];
    [self postMembership:poll];
    NSLog(@"Got return in postPoll: %@", poll.pollID);
    return poll;
}

//- deletPoll

- (void)postMembership:(Poll *)poll
{
    NSLog(@"Posting MEMBERSHIP for URL: %@ and poll title %@", membershipURL, poll.title);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:membershipURL];
    [request setHTTPMethod:@"POST"];
    //dummy data, need to implement correct data
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&poll_id=%@&response=%@",poll.creatorID, poll.pollID, @"true" ];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    NSDictionary *membershipFeedback = [[NSDictionary alloc] init];
    membershipFeedback  = [self makeServerRequestWithRequest:request];
   
    [poll.membershipIDs addObject: membershipFeedback[@"id"]];
    NSLog(@"Membership feedback: %@", membershipFeedback[@"id"]);
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
        if (EXPIRE_TIME_DEBUG == 1){
        NSLog(@"Poll %d end time is %@ ",d, pollEndDate);
        NSLog(@"Poll %d is: %ld / %ld / %ld / %ld :%ld: %ld ",d,pollMonth,pollDay,pollYear, pollHour,(long)pollMinute,(long)pollSecond);
        }
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
