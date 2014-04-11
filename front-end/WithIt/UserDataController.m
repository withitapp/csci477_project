//
//  UserDataController.m
//  WithIt
//
//  Created by Patrick Dalton on 4/11/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "UserDataController.h"
#import "DataController.h"
#include "AppDelegate.h"
#import "Poll.h"
#import "User.h"

@interface PollDataController () <NSURLConnectionDelegate>
- (id)init;
@end
@implementation UserDataController


#define friendsURL [NSURL URLWithString:@"http://withitapp.com:3000/friends"]
#define membersURL [NSURL URLWithString:@"http://withitapp.com:3000/members"]

- (void)loadData
{
    
    NSLog(@"Loading data for UserDataController");
    [self retrieveFriends];
}

- (id)init {
    semaphore_users = dispatch_semaphore_create(0);
    
    NSDictionary *friendsList = [[NSDictionary alloc] init];
    self.masterFriendsList = friendsList;
    
    NSDictionary *everyoneList = [[NSDictionary alloc] init];
    self.masterEveryoneList = everyoneList;
    
    
    
    NSLog(@"Init UserDataController");
    return self;
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
                                   dispatch_semaphore_signal(semaphore_users);
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
                               
                               dispatch_semaphore_signal(semaphore_users);
                           }];
    
    NSLog(@"Sempaphore dispatched");
    dispatch_semaphore_wait(semaphore_users, DISPATCH_TIME_FOREVER);
    return dataDictionary;
}


- (void)retrieveMembers:(Poll *) poll
{
    NSLog(@"Retrieving members with URL: %@", membersURL);
    // Create the request with an appropriate URL
    NSURLRequest *request = [NSURLRequest requestWithURL:membersURL];
    // Dispatch the request and save the returned data
    NSDictionary *users = [self makeServerRequestWithRequest:request];
    User *user;
    //NSLog(@"Type of data received: %@, ", [users class]);
    
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
}

- (void)retrieveFriends{
    
    NSLog(@"Retrieving friends with URL: %@", friendsURL);
    // Create the request with an appropriate URL
    NSURLRequest *request = [NSURLRequest requestWithURL:friendsURL];
    // Dispatch the request and save the returned data
    NSDictionary *friends = [self makeServerRequestWithRequest:request];
    User *user;
    NSMutableArray *updateFriendsList = [[NSMutableArray alloc] init];
    
    for(NSDictionary *theUser in friends){
    
        user = [[User alloc] init];
        user.ID = theUser[@"id"];
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
        [updateFriendsList addObject:poll];
    }
    for( poll in updateFriendsList){
        
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


@end
