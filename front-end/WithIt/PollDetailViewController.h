//
//  PollDetailViewController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WIViewController.h"
#import "Poll.h"
#import "UserDataController.h"
#import "PollDataController.h"


@interface PollDetailViewController : WIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property NSUInteger pollIndex, pollSection;
@property (strong, nonatomic) Poll *poll;
@property (strong, nonatomic) UIView *detailsView;
@property (strong, nonatomic) UITextView *titleLabel;
@property (strong, nonatomic) UITextView *descriptionLabel;
@property (strong, nonatomic) UILabel *timeRemainingLabel;
@property (strong, nonatomic) UISwitch *toggleSwitch;
@property (strong, nonatomic) UILabel *creatorNameLabel;
@property (strong, nonatomic) UITextField *editPollTitle;
@property (strong, nonatomic) UITextView *editPollDescription;

@property (strong, nonatomic) UserDataController *userDataController;
@property (strong, nonatomic) PollDataController *pollDataController;

@property (strong, nonatomic) UITableView *memberTableView;
@property (nonatomic, strong) UIButton *DeletePollButton;

-(void)setPollDetails:(Poll*)poll atIndex:(NSUInteger)index atSection:(NSUInteger)sectionNumber;

@end
