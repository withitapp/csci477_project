//
//  CreatePollViewController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WIViewController.h"
#import "PollDataController.h"
#import "PublishPollViewController.h"

@interface CreatePollViewController : WIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIView *detailsView;
//publish page controller
@property (strong, nonatomic) PublishPollViewController *publishViewController;
//For input data
@property (strong, nonatomic) UITextField *PollTitleTextField;
@property (strong, nonatomic) UITextView *PollDescriptionTextField;
@property (strong, nonatomic) UIDatePicker *PollExpirationDatePicker;

//Labels
@property (strong, nonatomic) UILabel *PollExpirationDateLabel;

// Data controller
@property (strong, nonatomic) PollDataController *dataController;


@end
