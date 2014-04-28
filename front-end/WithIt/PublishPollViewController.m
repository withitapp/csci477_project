//
// PublishPollViewController.m
// WithIt
//
// Created by Peggy Tang on 22/1/14.
// Copyright (c) 2014 WithIt. All rights reserved.
//

#import "PublishPollViewController.h"
#import "AppDelegate.h"

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PublishPollViewController ()

@property (strong, nonatomic) IBOutlet UITextView *selectedFriendsView;
//@property (strong, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NSMutableArray *selectedFriends;

- (void)fillTextBoxAndDismiss:(NSString *)text;

@end

@implementation PublishPollViewController

@synthesize selectedFriendsView = _friendResultText;
@synthesize friendPickerController = _friendPickerController;
@synthesize InviteFriendsButton, PublishPollButton;


-(void)setPollCreated:(Poll *)poll
{
    if(!poll){
        NSLog(@"Poll is null.");
        return;
    }
    self.poll = poll;
    NSLog(@"Set poll %@.", self.poll.title);
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    NSLog(@"Loading PublishPoll view.");
    [super viewDidLoad];
    self.userDataController = [UserDataController sharedInstance];
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
    
    self.selectedFriends = [[NSMutableArray alloc] init];
    
    self.FriendsInvitedTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 130, (self.screenWidth-40), 200)];
    self.FriendsInvitedTextField.textAlignment = NSTextAlignmentLeft;
    self.FriendsInvitedTextField.backgroundColor=[UIColor whiteColor];
    self.FriendsInvitedTextField.textColor = [UIColor lightGrayColor];
    self.FriendsInvitedTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.FriendsInvitedTextField.returnKeyType = UIReturnKeyDone;
    self.FriendsInvitedTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.FriendsInvitedTextField.text = @"No Friends Currently Invited";
    
    
    //Add Publish Poll Button
    self.PublishPollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.PublishPollButton.frame = CGRectMake(30, (self.screenHeight - 200), (self.screenWidth - 60), 30);
    [self.PublishPollButton setTitle:@"Publish Poll" forState:UIControlStateNormal];
    
    //add action to capture when the button is released...this can probably be taken out later as we already have a selector for publish button
    [self.PublishPollButton addTarget:self
     action:@selector(buttonIsReleased)
     forControlEvents:UIControlEventTouchUpInside];
     
    [self.detailsView addSubview:self.PublishPollButton];
    
    // Set up poll table view
    self.memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, self.screenWidth, (self.screenHeight-180))];
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    [self.memberTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.memberTableView];
}

///////
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
        castView.contentView.backgroundColor = UIColorFromRGB(0x40BFAC);
        [castView.textLabel setTextColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];
        [castView.textLabel setFont:[UIFont fontWithName: @"HelveticaNeue" size: 20.0f]];
    }
}
////////


#pragma mark - Poll Detail Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// HACK - instead of figuring out how to indent the headings properly, I just added a space to the front of the title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section){
        case 0:
            sectionName = NSLocalizedString(@" Friends Invited:", @" Friends Invited:");
            break;
        case 1:
            sectionName = NSLocalizedString(@" Not attending:", @" Not attending:");
            break;
    }
    return sectionName;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numRows = 0;
    switch (section){
        case 0:
            numRows = [_selectedFriends count]; // need to add member lists to poll data
            break;
        case 1:
            numRows = 2; // same problem
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PollMemberCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //[[cell textLabel] setTextColor:UIColorFromRGB(0x297A6E)];
        [[cell textLabel] setFont: [UIFont fontWithName: @"HelveticaNeue" size: 18.0f]];
        //UILabel * nameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 0, 15, box.size.width, 19.0f)];
        //nameLabel.tag = NAME_LABEL_TAG;
        //[nameLabel setTextColor: [UIColor colorWithRed: 79.0f/255.0f green:79.0f/255.0f blue:79.0f/255.0f alpha:1.0f]];
        //[nameLabel setFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 18.0f]];
        //[nameLabel setBackgroundColor: [UIColor clearColor]];
        //nameLabel.textAlignment = NSTextAlignmentCenter;
        //[cell.contentView addSubview: nameLabel];
    }
    
    
     id<FBGraphUser> user = [_selectedFriends objectAtIndex:(indexPath.row)];
            [[cell textLabel] setText: user.name];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            //cell.backgroundColor = [UIColor greenColor];
          //  dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", user.id]]];
                if (!imageData){
                    NSLog(@"Failed to download user profile picture.");
                   // return cell;
                }
               // dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData: imageData];
                    NSLog(@"Loaded selected invite user data");
              // });
         //   });
        
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    switch (indexPath.section){
        case 0:
            return YES;
        case 1:
            return NO;
    }
    return YES;
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    
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
    
    self.friendPickerController.selection = [_selectedFriends copy];
    [self.friendPickerController loadData];
    //[self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
    NSLog(@"Returning from Pick Friends Button Click");
    
    

}
//TODO: cache this data better
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    //go through our users and determine if they should be included in friendPicker
        if ([self.userDataController.masterFriendsList objectForKey:user.id]) {
            // Friend is an WithIt user, include them in the display
            NSLog(@"Deciding if I should include user: %@ and result is YES!", user.id);
            return YES;
        }
    
    // Friend is not an WithIt user, do not include them
    return NO;
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    
    /*FBFriendPickerViewController *fpc = (FBFriendPickerViewController *)sender;
    for (id<FBGraphUser> user in fpc.selection) {
        NSLog(@"Friend selected: %@", user.name);
    }
    [self dismissModalViewControllerAnimated:YES];*/
    User * u;
    
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        
        u = [self.userDataController.masterFriendsList objectForKey:user.id];//get members WithIt id
        if(![self.poll.members containsObject:[f numberFromString:u.ID]]){
        if(u != nil){
                
            [self.poll.members addObject:[f numberFromString:u.ID]];    }}}
    
   
        _selectedFriends = [self.friendPickerController.selection copy];
    
    
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
    
    [_memberTableView reloadData];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    self.FriendsInvitedTextField.textColor = [UIColor lightGrayColor];
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

- (IBAction)buttonIsReleased
{
    [self PublishPoll];
}

//Publish Poll
- (IBAction)PublishPoll
{
    
    NSLog(@"Publish button pressed.");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    PollDataController *dataController = [PollDataController sharedInstance];
    self.poll.creatorID = appDelegate.ID;
    [self.poll.members addObject:appDelegate.ID];//add creator to poll members
    [dataController addPollCreatedWithPoll:self.poll];
    
    
    [appDelegate.masterViewController.pollTableView reloadData];
    
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
