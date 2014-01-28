//
//  PublishPollViewController.h
//  WithIt
//
//  Created by Peggy Tang on 22/1/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PublishPollViewController : UIViewController<FBFriendPickerDelegate>

- (IBAction)pickFriendsButtonClick:(id)sender;


@property (strong, nonatomic) UIView *detailsView;


//For input data
@property (strong, nonatomic) UITextField *FriendsInvitedTextField;
//@property (strong, nonatomic) UITextField *PollDescriptionTextField;

//Labels
@property (strong, nonatomic) UILabel *PollExpirationDateLabel;

@end
