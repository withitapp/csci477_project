//
//  CreatePollViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "CreatePollViewController.h"
#import "PublishPollViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface CreatePollViewController ()

@end

@implementation CreatePollViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataController = [PollDataController sharedInstance];
    }
    return self;
}


//when clicking the return button in the keybaord
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"Keyboard Return Working");
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    NSLog(@"Loading CreatePoll view.");
    [super viewDidLoad];
    
    //Cancel Button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(Cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    //Next Page Button
    UIBarButtonItem *nextCreatePollButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(goPublishNewPoll)];
    self.navigationItem.rightBarButtonItem = nextCreatePollButton;
    
    //Add detailsView to the main view
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.screenWidth, self.screenHeight)];
    [self.view addSubview:self.detailsView];
    
    //Add input text field for Poll Title
    self.PollTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, (self.screenWidth - 40), 30)];
    self.PollTitleTextField.placeholder = @"Poll Title";
    self.PollTitleTextField.backgroundColor=[UIColor whiteColor];
    self.PollTitleTextField.textColor = [UIColor blackColor];
    self.PollTitleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.PollTitleTextField.returnKeyType = UIReturnKeyDone;
    self.PollTitleTextField.borderStyle = UITextBorderStyleRoundedRect;

    self.PollTitleTextField.tag= 2;
    self.PollTitleTextField.delegate = self;
    [self.detailsView addSubview:self.PollTitleTextField];
    
    //Add input text field for Poll Description
    self.PollDescriptionTextField = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, (self.screenWidth - 40), 150)];
    self.PollDescriptionTextField.textColor = [UIColor lightGrayColor];
    [self.PollDescriptionTextField setText: @"Poll Description"];
    self.PollDescriptionTextField.backgroundColor=[UIColor whiteColor];
    self.PollDescriptionTextField.returnKeyType = UIReturnKeyDone;
    self.PollDescriptionTextField.layer.cornerRadius = 5.0f;
    [[self.PollDescriptionTextField layer] setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [[self.PollDescriptionTextField layer] setBorderWidth:1.2];
    self.PollDescriptionTextField.font = [UIFont fontWithName: @"HelveticaNeue" size: 16.0f];
    self.PollDescriptionTextField.tag= 2;
    self.PollDescriptionTextField.textAlignment = NSTextAlignmentLeft;
    self.PollDescriptionTextField.delegate = self;
    [self.detailsView addSubview:self.PollDescriptionTextField];
    
    //Add date selection label for Poll Expiration
    self.PollExpirationDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 300, 30)];
    self.PollExpirationDateLabel.textColor = [UIColor lightGrayColor];
    self.PollExpirationDateLabel.backgroundColor = [UIColor whiteColor];
    self.PollExpirationDateLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    [self.detailsView addSubview:self.PollExpirationDateLabel];
    self.PollExpirationDateLabel.text = [NSString stringWithFormat: @"Poll End Date : "];
    
    //Add date selection datepicker for Poll Expiration
    self.PollExpirationDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, 280, (self.screenWidth - 20), 60)];
    self.PollExpirationDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.PollExpirationDatePicker.date = [NSDate date];
    [self.PollExpirationDatePicker setMinimumDate: [NSDate date]];
    [self.detailsView addSubview:self.PollExpirationDatePicker];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Poll Description"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Poll Description";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (IBAction)Cancel
{
    NSLog(@"Cancelling poll creation.");
    [self.navigationController popViewControllerAnimated:YES];
}

//action for PollCreateButton pressed - going to the next create poll page
- (IBAction)goPublishNewPoll
{
    
    if([_PollTitleTextField.text isEqualToString: @"Poll Title"] ||
       [_PollTitleTextField.text isEqualToString: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a poll title." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Invalid input, alerting user.");
    }
    else {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        Poll *poll = [[Poll alloc  ] initWithInfo:_PollTitleTextField.text creatorName:appDelegate.username description:_PollDescriptionTextField.text endDate:_PollExpirationDatePicker.date];
    
        PublishPollViewController *publishPollViewController = [[PublishPollViewController alloc] init];
        [publishPollViewController setPollCreated:poll];
        [self.navigationController pushViewController:publishPollViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

