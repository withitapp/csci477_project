//
//  UserDataController.h
//  WithIt
//
//  Created by Patrick Dalton on 4/11/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataController.h"
#import "Poll.h"
#import "User.h"
#import "Membership.h"
//#import <FacebookSDK/FacebookSDK.h>

@interface UserDataController : DataController


@property (strong, nonatomic) NSMutableArray *userFriendsList;
@property (strong, nonatomic) NSMutableArray *myMemberships; //think about changing this...

//dictionary containting all user objects that are friends in the app (and facebook)
@property (nonatomic, retain) NSMutableDictionary *masterFriendsList;
//dictionary containing all user objects this instance has ever interacted with
@property (nonatomic, retain) NSMutableDictionary *masterEveryoneList;
@property (nonatomic, retain) NSMutableDictionary *masterMembershipsList;

- (void)loadData;
+ (UserDataController*)sharedInstance;

-(NSDictionary*) makeServerRequestWithRequest:(NSURLRequest *)request;


- (void)retrieveFriends;
- (void)retrieveMembers:(Poll *) poll;

//all 4 memberships done
- (void)retrieveMemberships:(Poll *) poll;
-(void)updateMembership:(NSNumber *) mem_id Response:(NSString *) response;
-(void)deleteMembership:(NSNumber *) mem_id;

-(User *)getUser:(NSNumber *) userID;
@end
