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
//#import <FacebookSDK/FacebookSDK.h>

@interface UserDataController : DataController


@property (strong, nonatomic) NSMutableArray *userFriendsList;


//dictionary containting all user objects that are friends in the app (and facebook)
@property (nonatomic, copy) NSMutableDictionary *masterFriendsList;
//dictionary containing all user objects this instance has ever interacted with
@property (nonatomic, copy) NSMutableDictionary *masterEveryoneList;
@property (nonatomic, copy) NSMutableDictionary *masterMembershipsList;

- (void)loadData;
+ (UserDataController*)sharedInstance;

-(NSDictionary*) makeServerRequestWithRequest:(NSURLRequest *)request;
- (void)retrieveFriends;
- (void)retrieveMembers:(Poll *) poll;

-(User *)getUser:(NSNumber *) userID;
@end
