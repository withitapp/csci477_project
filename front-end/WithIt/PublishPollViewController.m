//
// PublishPollViewController.m
// WithIt
//
// Created by Peggy Tang on 22/1/14.
// Copyright (c) 2014 WithIt. All rights reserved.
//

#import "PublishPollViewController.h"
#import "AppDelegate.h"


@interface PublishPollViewController ()

@property (strong, nonatomic) IBOutlet UITextView *selectedFriendsView;
//@property (strong, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

- (void)fillTextBoxAndDismiss:(NSString *)text;

@end

@implementation PublishPollViewController

@synthesize selectedFriendsView = _friendResultText;
@synthesize friendPickerController = _friendPickerController;
@synthesize InviteFriendsButton, PublishPollButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    NSLog(@"Loading PublishPoll view.");
    [super viewDidLoad];
    
    //Back Button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //Publish Page Button in navigation bar
    UIBarButtonItem *navPublishPollButton = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleBordered target:self action:@selector(PublishPoll)];
    self.navigationItem.rightBarButtonItem = navPublishPollButton;
    
    //Add detailsView to the main view
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.screenWidth, self.screenHeight)];
    [self.view addSubview:self.detailsView];
    
    
    //Add Invite Friends Button
    self.InviteFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.InviteFriendsButton.frame = CGRectMake(30, 60, (self.screenWidth - 60), 30);
    [self.InviteFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    //add action to capture when the button is released
    [self.InviteFriendsButton addTarget:self
     action:@selector(inviteFriendsButtonClick:)
     forControlEvents:UIControlEventTouchUpInside];
     
    [self.detailsView addSubview:self.InviteFriendsButton];
    
    
    NSLog(@"Before create Friends Invited Text Field.");
    self.FriendsInvitedTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 120, (self.screenWidth-40), 200)];
    self.FriendsInvitedTextField.textAlignment = NSTextAlignmentLeft;
    self.FriendsInvitedTextField.backgroundColor=[UIColor whiteColor];
    self.FriendsInvitedTextField.textColor = [UIColor grayColor];
    self.FriendsInvitedTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.FriendsInvitedTextField.returnKeyType = UIReturnKeyDone;
    self.FriendsInvitedTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.FriendsInvitedTextField.text = @"No Friends Currently Invited";
    
    
    //self.PollTitleTextField.textAlignment = UITextAlignmentLeft;
    // self.FriendsInvitedTextField.delegate = self;
    [self.detailsView addSubview:self.FriendsInvitedTextField];
    
    
    //[self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
    NSLog(@"Done create Friends Invited Text Field.");
    
    /*
    //Add Publish Poll Button
    self.PublishPollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.PublishPollButton.frame = CGRectMake(30, (self.screenHeight - 200), (self.screenWidth - 60), 30);
    [self.PublishPollButton setTitle:@"Publish Poll" forState:UIControlStateNormal];
    
    //add action to capture when the button is released
    [self.PublishPollButton addTarget:self
     action:@selector(buttonIsReleased:)
     forControlEvents:UIControlEventTouchUpInside];
     
    [self.detailsView addSubview:self.PublishPollButton];
     */
}


- (void)inviteFriendsButtonClick:(id)sender {
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self inviteFriendsButtonClick:sender];
                                          }
                                      }];
        return;
    }
        if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
    NSLog(@"Returning from Pick Friends Button Click");

}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
    NSLog(@"OUT of facebookview done");
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<No Poll Invitations Selected>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    self.FriendsInvitedTextField.textColor = [UIColor blackColor];
    self.FriendsInvitedTextField.text = text;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"should be filling text box");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark -
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidUnload {
    self.selectedFriendsView = nil;
    self.friendPickerController = nil;
    
    [super viewDidUnload];
}


//Back button
- (IBAction)Back
{
    NSLog(@"Back button pressed.");
    [self.navigationController popViewControllerAnimated:YES];
}

//Publish Poll
- (IBAction)PublishPoll
{
    
    NSLog(@"Publish button pressed.");
    
  //  [masterPollsCreatedList addPollCreatedWithPoll:currentPoll];
    
    //pop view controllers twice
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    
    /*[self.navigationController popViewControllerAnimated:YES];
     [self.navigationController popViewControllerAnimated:YES];*/
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
