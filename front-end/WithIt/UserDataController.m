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
    
    NSMutableDictionary *friendsList = [[NSMutableDictionary alloc] init];
    self.masterFriendsList = friendsList;
    
    NSMutableDictionary *everyoneList = [[NSMutableDictionary alloc] init];
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
    NSDictionary *members = [self makeServerRequestWithRequest:request];
    User *user;
    
    NSMutableArray *updateMembersList = [[NSMutableArray alloc] init];//question: should we create this object every time?
    
    for(NSDictionary *theUser in members){
        
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
        [updateMembersList addObject:user];
    }
    for(user in updateMembersList){
        if([poll.members containsObject:user.ID]){
            NSLog(@"Poll already contains user: %@", user.first_name);
        }
        else{
            [poll.members addObject:user.ID];
            }
        
        if([self.masterEveryoneList objectForKey: user.ID]){
            
             NSLog(@"Master everyone list already contains user - %@ -", user.first_name);
        }
        else{
            
            // Add user profile picture
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.ID]]];
                if (!imageData){
                    NSLog(@"Failed to download user profile picture.");
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    user.profilePictureView.image = [UIImage imageWithData: imageData];
                });
            });
           
        
        user.full_name = [user.first_name stringByAppendingString:user.last_name];
        NSLog(@"User [%@] added to everyone list.", user.first_name);
        [self.masterEveryoneList setObject:user forKey:user.ID];
        }}
    [updateMembersList removeAllObjects];

}

- (void)retrieveFriends{
    
    NSLog(@"Retrieving friends with URL: %@", friendsURL);
    // Create the request with an appropriate URL
    NSURLRequest *request = [NSURLRequest requestWithURL:friendsURL];
    // Dispatch the request and save the returned data
    NSDictionary *friends = [self makeServerRequestWithRequest:request];
    User *user;
    NSMutableArray *updateFriendsList = [[NSMutableArray alloc] init];//question: should we create this object every time?
    
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
        [updateFriendsList addObject:user];
    }
    for(user in updateFriendsList){
        //add all friends to local dictionary storage
        if([self.masterFriendsList objectForKey: user.ID]){
            NSLog(@"User [%@] added to friends list.", user.first_name);
            [self.masterFriendsList setObject:user forKey:user.ID];
        }
        else{
            NSLog(@"Master friends list already contains user - %@ -", user.first_name);
        }
        //make sure all friends are in everyone list... may want to remove later, not sure now 4/11
        if([self.masterEveryoneList objectForKey: user.ID]){
            NSLog(@"Master everyone list already contains user - %@ -", user.first_name);
            
        }
        else{
            // Add user profile picture
            //user.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.ID]]];
                if (!imageData){
                    NSLog(@"Failed to download user profile picture.");
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    user.profilePictureView.image = [UIImage imageWithData: imageData];
                });
            });
            
        
        user.full_name = [user.first_name stringByAppendingString:user.last_name];
        NSLog(@"User [%@] added to everyone list.", user.first_name);
        [self.masterEveryoneList setObject:user forKey:user.ID];
        }
    }
    [updateFriendsList removeAllObjects];
}

-(User *)getUser:(NSNumber *) userID{
    User * user;
    user = [self.masterEveryoneList objectForKey:userID];
    if(user == nil){
        NSLog(@"In getUser, could not find user in local dictionary *HELP*");
        
    }

    return user;
}

+ (UserDataController*)sharedInstance
{
    static UserDataController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[UserDataController alloc] init];
    });
    return _sharedInstance;
}



@end
