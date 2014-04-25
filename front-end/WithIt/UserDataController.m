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
#import "Membership.h"
#import "Poll.h"
#import "User.h"

@interface PollDataController () <NSURLConnectionDelegate>
- (id)init;
@end
@implementation UserDataController


#define friendsURL [NSURL URLWithString:@"http://withitapp.com:3000/friends"]
#define membersURL [NSURL URLWithString:@"http://withitapp.com:3000/members"]
#define membershipURL [NSURL URLWithString:@"http://withitapp.com:3000/memberships"]

- (void)loadData
{
    
    NSLog(@"Loading data for UserDataController");
    [self retrieveFriends];
}

- (id)init {
    semaphore_users = dispatch_semaphore_create(0);
    
   
    self.masterFriendsList = [[NSMutableDictionary alloc] init];
    //self.masterFriendsList = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.masterEveryoneList = [[NSMutableDictionary alloc] init];
    
    
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:membersURL];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"poll_id=%@",poll.pollID];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
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
      //  NSString *userid = [user.ID stringValue];
     //   user.ID = userid;
        if([poll.members containsObject:user.ID]){
            NSLog(@"1Poll already contains user: %@", user.first_name);
        }
        else{
            [poll.members addObject:user.ID];
            }
        
        if([self.masterEveryoneList objectForKey: user.ID]){
            
             NSLog(@"1Master everyone list already contains user - %@ -", user.first_name);
        }
        else{
            
            // Add user profile picture
            user.profilePictureView = [[UIImageView alloc] init];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.fb_id]]];
                if (!imageData){
                    NSLog(@"Failed to download user profile picture.");
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    user.profilePictureView.image = [UIImage imageWithData: imageData];
                });
            });
           
            NSString * name = [user.first_name stringByAppendingString:@" "];
            user.full_name = [name stringByAppendingString:user.last_name];
        NSLog(@"User [%@] added to everyone list.", user.first_name);
        [self.masterEveryoneList setObject:user forKey:user.ID];
        }}
    NSLog(@"Number of members in poll: %lu", (unsigned long)[poll.members count]);
    [updateMembersList removeAllObjects];

}

- (void)retrieveFriends{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"Retrieving friends with URL: %@  User id: %@", friendsURL, appDelegate.ID);
    // Create the request with an appropriate URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:friendsURL];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@", appDelegate.ID];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
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
        NSString *userid = [user.ID stringValue];
        user.ID = userid;
        //add all friends to local dictionary storage
        if([self.masterFriendsList objectForKey: user.fb_id]){
            
            NSLog(@"Master friends list already contains user - %@ -", user.first_name);
        }
        else{
            
            NSLog(@"User [%@] added to friends list. ID: %@", user.first_name, user.fb_id);
            NSString * name = [user.first_name stringByAppendingString:@" "];
            user.full_name = [name stringByAppendingString:user.last_name];
            
            [self.masterFriendsList setObject:user forKey:user.fb_id];
            
        }
        //make sure all friends are in everyone list... may want to remove later, not sure now 4/11
        if([self.masterEveryoneList objectForKey: user.ID]){
            NSLog(@"Master everyone list already contains user - %@ -", user.first_name);
            
        }
        else{
            // Add user profile picture
            //user.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.fb_id]]];
                if (!imageData){
                    NSLog(@"Failed to download user profile picture.");
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    user.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
                    user.profilePictureView.image = [UIImage imageWithData: imageData];
                });
            });
            
            NSString * name = [user.first_name stringByAppendingString:@" "];
            user.full_name = [name stringByAppendingString:user.last_name];
    
            
        [self.masterEveryoneList setObject:user forKey:user.ID];
        }
    }
    [updateFriendsList removeAllObjects];
}

- (void)postMembership:(Poll *)poll user:(NSNumber *)userid Response:(NSString *)response
{
    NSLog(@"Posting MEMBERSHIP for URL: %@ and userid: %@", membershipURL, userid);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:membershipURL];
    [request setHTTPMethod:@"POST"];
    //dummy data, need to implement correct data
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&poll_id=%@&response=%@",userid, poll.pollID, response ];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    NSDictionary *membershipFeedback = [[NSDictionary alloc] init];
    membershipFeedback  = [self makeServerRequestWithRequest:request];
    //TODO: retrieve full membership info here
  //  [poll.memberships setObject: membershipFeedback[@"id"]];
    NSLog(@"Membership feedback: %@", membershipFeedback[@"id"]);
}

-(void)updateMembership:(NSNumber *) mem_id Response:(NSString *) response{
    
    NSString *s = [NSString stringWithFormat:@"http://withitapp.com:3000/memberships?id=%@&response=%@", mem_id, response];
    NSLog(@"Updating membership with mem_id: %@ and response: %@", mem_id, response);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
    // Create the request with an appropriate URL
  //  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:membershipURL];
    [request setHTTPMethod:@"PATCH"];
    NSString *postString = [NSString stringWithFormat:@"id=%@&response=%@", mem_id, response];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    // Dispatch the request and save the returned data
    NSDictionary *membership = [self makeServerRequestWithRequest:request];
}

-(void)deleteMembership:(NSNumber *) mem_id{
    
    NSString *s = [NSString stringWithFormat:@"http://withitapp.com:3000/memberships?id=%@", mem_id];
    NSLog(@"Deleting membership with mem_id: %@", mem_id);
    // Create the request with an appropriate URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
    [request setHTTPMethod:@"DELETE"];
    /*NSString *postString = [NSString stringWithFormat:@"id=%@", mem_id];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];*/
    // Dispatch the request and save the returned data
    NSDictionary *membership = [self makeServerRequestWithRequest:request];
    if(membership!=nil){
        NSLog(@"Got return in deleteMembership: %@", membership);
    }
    
}

-(void)retrieveMemberships:(Poll *) poll{
   // NSLog(@"Attempting to retrieve Memberships from URL %@ *** id: %@", membershipURL, poll.pollID);
   
    NSString *s = [NSString stringWithFormat:@"http://withitapp.com:3000/memberships?poll_id=%@",poll.pollID];
 
    NSLog(@"Sending to this endpoint: %@", s);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    
    if(!poll.memberships){
        NSLog(@"memberships count is 0, init alloc");
        poll.memberships = [[NSMutableDictionary alloc] init]; //becomes immutable here
    }
    NSDictionary *memberships = [self makeServerRequestWithRequest:request];
    Membership *membership;
    Membership *m;
    NSMutableArray *updateMembershipsList = [[NSMutableArray  alloc] init];//question: should we create this object every time?
    //[poll.memberships addObject:membership];
    for(NSDictionary *mship in memberships){
        membership = [[Membership alloc] init];
        NSLog(@"Got membership: %@", mship[@"id"]);
        membership.ID = mship[@"id"];
        NSLog(@"Got membership: %@", membership.ID);
        //if(mship[@"created_at"]=!nil && mship[@"updated_at"]!=nil){
        membership.created_at = mship[@"created_at"];
        NSLog(@"Got membership: %@", mship[@"created_at"]);
        membership.updated_at = mship[@"updated_at"];
        NSLog(@"Got membership: %@", mship[@"updated_at"]);
        membership.user_id = mship[@"user_id"];
        NSLog(@"Got membership: %@", mship[@"user_id"]);
        membership.poll_id = mship[@"poll_id"];
        NSLog(@"Got membership: %@", mship[@"poll_id"]);
        membership.response = mship[@"response"];
       /* if(mship[@"response"] == 1){
            membership.response = @"true";
        }
        else
            membership.response = @"false";*/
        
        [updateMembershipsList addObject:membership];
        
    }
    for(int i=0; i<[updateMembershipsList count]; i++){
        m = [updateMembershipsList objectAtIndex: i];
        NSLog(@"mem_id = %@", m.ID);
    }
    for(m in updateMembershipsList){
    
        NSLog(@"Poll %@, doesnt contain membership %@ , adding it now", poll.pollID, m.ID);
        [poll.memberships setObject:m forKey:m.ID];
        NSLog(@"Memberships in the pollid %@: %lu", poll.pollID, (unsigned long)[poll.memberships count]);
    }
    
    
}

-(User *)getUser:(NSNumber *) userID{
    User * user;
    user = [self.masterEveryoneList objectForKey:userID];
    if(user == nil){
        NSLog(@"In getUser, could not find user in local dictionary *HELP*");
        
    }
    if(user.profilePictureView.image == nil){
      //  user.profilePictureView.image = [[UIImage alloc] init];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.fb_id]]];
            if (!imageData){
                NSLog(@"Failed to download user profile picture.");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                user.profilePictureView.image = [UIImage imageWithData: imageData];
            });
        });
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
