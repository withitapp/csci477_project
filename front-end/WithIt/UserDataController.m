//
//  UserDataController.m
//  WithIt
//
//  Created by Patrick Dalton on 4/11/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "UserDataController.h"
#import "DataController.h"
#import "AppDelegate.h"
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
    [self retrieveFriends];
}

- (id)init {
    semaphore_users = dispatch_semaphore_create(0);
    
   
    self.masterFriendsList = [[NSMutableDictionary alloc] init];
    
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
    
    dispatch_semaphore_wait(semaphore_users, DISPATCH_TIME_FOREVER);
    return dataDictionary;
}


- (void)retrieveMembers:(Poll *) poll
{
    // Create the request with an appropriate URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:membersURL];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"poll_id=%@",poll.pollID];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    // Dispatch the request and save the returned data
    NSDictionary *members = [self makeServerRequestWithRequest:request];
    User *user;
    
    NSMutableArray *updateMembersList = [[NSMutableArray alloc] init];
    
    for(NSDictionary *theUser in members){
        
        user = [[User alloc] init];
        user.ID = theUser[@"id"];
        user.created_at = theUser[@"created_at"];
        user.updated_at = theUser[@"updated_at"];
        user.username = theUser[@"username"];
        user.email = theUser[@"email"];
        user.first_name = theUser[@"first_name"];
        user.last_name = theUser[@"last_name"];
        user.fb_id = theUser[@"fb_id"];
        user.fb_token = theUser[@"fb_token"];
        user.fb_synced_at = theUser[@"fb_synced_at"];
        [updateMembersList addObject:user];
    }
    for(user in updateMembersList){
        if([poll.members containsObject:user.ID]){
        }
        else{
            [poll.members addObject:user.ID];
            }
        
        if([self.masterEveryoneList objectForKey: user.ID]){
        }
        else{
            
            // Add user profile picture
            if(user.profilePictureView.image == nil){
            user.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.fb_id]]];
                if (!imageData){
                    NSLog(@"Failed to download user profile picture.");
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(imageData!=nil)
                        user.profilePictureView.image = [UIImage imageWithData: imageData];
                });
            });
            }
            NSString * name = [user.first_name stringByAppendingString:@" "];
            user.full_name = [name stringByAppendingString:user.last_name];
        [self.masterEveryoneList setObject:user forKey:user.ID];
        }}
    [updateMembersList removeAllObjects];

}

- (void)retrieveFriends{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
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
        }
        else{
            NSString * name = [user.first_name stringByAppendingString:@" "];
            user.full_name = [name stringByAppendingString:user.last_name];
            
            [self.masterFriendsList setObject:user forKey:user.fb_id];
            
        }
        //make sure all friends are in everyone list... may want to remove later, not sure now 4/11
        if([self.masterEveryoneList objectForKey: user.ID]){
            
        }
        else{
            // Add user profile picture
            if(user.profilePictureView == nil){
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
            }
            NSString * name = [user.first_name stringByAppendingString:@" "];
            user.full_name = [name stringByAppendingString:user.last_name];
    
            
        [self.masterEveryoneList setObject:user forKey:user.ID];
        }
    }
    [updateFriendsList removeAllObjects];
}

- (void)postMembership:(Poll *)poll user:(NSNumber *)userid Response:(NSString *)response
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:membershipURL];
    [request setHTTPMethod:@"POST"];
    //dummy data, need to implement correct data
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&poll_id=%@&response=%@",userid, poll.pollID, response ];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    NSDictionary *membershipFeedback = [[NSDictionary alloc] init];
    membershipFeedback  = [self makeServerRequestWithRequest:request];
    NSLog(@"Membership feedback: %@", membershipFeedback[@"id"]);
}

-(void)updateMembership:(NSNumber *) mem_id Response:(NSString *) response{
    
    NSString *s = [NSString stringWithFormat:@"http://withitapp.com:3000/memberships?id=%@&response=%@", mem_id, response];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
    [request setHTTPMethod:@"PATCH"];
    NSString *postString = [NSString stringWithFormat:@"id=%@&response=%@", mem_id, response];
    NSData *requestBodyData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];
    // Dispatch the request and save the returned data
    NSDictionary *membership = [self makeServerRequestWithRequest:request];
}

-(void)deleteMembership:(NSNumber *) mem_id{
    
    NSString *s = [NSString stringWithFormat:@"http://withitapp.com:3000/memberships?id=%@", mem_id];
    
    // Create the request with an appropriate URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
    [request setHTTPMethod:@"DELETE"];
    // Dispatch the request and save the returned data
    NSDictionary *membership = [self makeServerRequestWithRequest:request];
    if(membership!=nil){
    }
    
}

-(void)retrieveMemberships:(Poll *) poll{
   
    NSString *s = [NSString stringWithFormat:@"http://withitapp.com:3000/memberships?poll_id=%@",poll.pollID];
 
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    
    if(!poll.memberships){
        poll.memberships = [[NSMutableDictionary alloc] init]; //becomes immutable here
    }
    NSDictionary *memberships = [self makeServerRequestWithRequest:request];
    Membership *membership;
    Membership *m;
    NSMutableArray *updateMembershipsList = [[NSMutableArray  alloc] init];
   
    for(NSDictionary *mship in memberships){
        membership = [[Membership alloc] init];
        membership.ID = mship[@"id"];
        membership.created_at = mship[@"created_at"];
        membership.updated_at = mship[@"updated_at"];
        membership.user_id = mship[@"user_id"];
        membership.poll_id = mship[@"poll_id"];
        membership.response = mship[@"response"];
        
        [updateMembershipsList addObject:membership];
        
    }
    for(int i=0; i<[updateMembershipsList count]; i++){
        m = [updateMembershipsList objectAtIndex: i];
        
    }
    for(m in updateMembershipsList){
        [poll.memberships setObject:m forKey:m.ID];
    }
    
    
}

-(User *)getUser:(NSNumber *) userID{
    User * user;
    user = [self.masterEveryoneList objectForKey:userID];
    if(user == nil){
        NSLog(@"In getUser, could not find user in local dictionary *HELP*");
        
    }
    if(user.profilePictureView.image == nil){
        user.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.fb_id]]];
            if (!imageData){
                NSLog(@"Failed to download user profile picture.");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(imageData!=nil)
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
