//
//  PublishPollViewController.h
//  WithIt
//
//  Created by Peggy Tang on 22/1/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "WIViewController.h"
#import "Poll.h"


@interface PublishPollViewController : WIViewController <FBFriendPickerDelegate, UITableViewDelegate, UITableViewDataSource>

//- (IBAction)pickFriendsButtonClick:(id)sender;
- (void)inviteFriendsButtonClick:(id)sender;

@property (strong, nonatomic) UIView *detailsView;

//Buttons
@property (nonatomic, strong) UIButton *InviteFriendsButton, *PublishPollButton;

//For Data
@property (strong, nonatomic) UITextField *FriendsInvitedTextField;
//@property (strong, nonatomic) UITextField *PollDescriptionTextField;

@property (strong, nonatomic) UITableView *memberTableView;
@property (strong, nonatomic) Poll *poll;

//Labels
//@property (strong, nonatomic) UILabel *PollExpirationDateLabel;

-(void)setPollCreated:(Poll*)poll;

@end
