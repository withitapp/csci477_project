//
//  PollDetailViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "PollDetailViewController.h"
#import "WIViewController.h"
#import "CreatePollViewController.h"
#import "AppDelegate.h"


//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

const NSInteger ALIGN = 10;

@interface PollDetailViewController ()

@end

@implementation PollDetailViewController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)setPollDetails:(Poll *)poll atIndex:(NSUInteger)index atSection:(NSUInteger)sectionNumber
{
    if(!poll){
        NSLog(@"Poll is null.");
        return;
    }
    self.poll = poll;
    self.pollIndex = index;
    self.pollSection = sectionNumber;
}

- (void)viewDidLoad
{
    self.pollDataController = [PollDataController sharedInstance];
    NSLog(@"Loading detail view for poll %@.", self.poll.title);
    self.userDataController = [UserDataController sharedInstance];
    //retrieves members in poll from database
    [self.userDataController retrieveMembers:self.poll];
    [self.userDataController retrieveMemberships:self.poll];
    //NSLog(@"viewDidLoad count of members in poll: %lu",(unsigned long)[self.poll.members count]);
   
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //NSLog(@"App delegate id: %@", appDelegate.ID);
    //NSLog(@"Poll Creator id: %@", self.poll.creatorID);
    //You can edit your own poll
    if([self.poll.creatorID isEqualToNumber: appDelegate.ID]) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(Edit)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
    else { //You cannot edit someone else's poll, but you can leave someone else's poll
        UIBarButtonItem *leaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Group" style:UIBarButtonItemStyleBordered target:self action:@selector(Leave)];
        self.navigationItem.rightBarButtonItem = leaveButton;
    }
    
    NSInteger currentHeight = 65;
    
    // Add poll title label
    self.titleLabel = [[UITextView alloc] initWithFrame:CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), self.screenHeight)];
    self.titleLabel.font = [UIFont systemFontOfSize:20.0];
    self.titleLabel.textColor = [UIColor blackColor];
    [self.titleLabel setEditable:FALSE];
    currentHeight += self.titleLabel.frame.size.height;
    
    // Add poll description label
    self.descriptionLabel = [[UITextView alloc] initWithFrame:CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), self.screenHeight)];
    self.descriptionLabel.font = [UIFont fontWithName:@"Ariel" size:14.0];
    self.descriptionLabel.textColor = [UIColor darkGrayColor];
    [self.descriptionLabel setEditable:FALSE];
    currentHeight += self.descriptionLabel.frame.size.height;
    
    // Add time remaining for poll label
    self.timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake((ALIGN+20), currentHeight, 300, 20)];
    self.timeRemainingLabel.font = [UIFont systemFontOfSize:10.0];
    [self.timeRemainingLabel setTextAlignment: NSTextAlignmentLeft];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.timeRemainingLabel setText:@"End Date: "]; // FIX ME... to time remaining?!
    
    if(self.poll.endDate != nil)
    {
        @try {
       // self.timeRemainingLabel.text = [self.timeRemainingLabel.text stringByAppendingString:[dateFormatter stringFromDate:self.poll.endDate]];
            NSString *dateString = [dateFormatter stringFromDate:self.poll.endDate];
            self.timeRemainingLabel.text = [self.timeRemainingLabel.text stringByAppendingString:dateString];}
        @catch (NSException *NSInvalidArgumentException){
            NSLog(@"Caught invalid argument exception on end date label");
        }
    }
    else
    {
        self.timeRemainingLabel.text = [self.timeRemainingLabel.text stringByAppendingString:@"None Given"];
        [self.detailsView addSubview:self.timeRemainingLabel];
    }
    
        //Add toggle Switch
    self.toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50, currentHeight, 50, 0)];
    [self.toggleSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    Membership *m1;
    for(Membership *m in self.poll.memberships){
        m1 = [self.poll.memberships objectForKeyedSubscript:m];
        if([m1.user_id isEqualToNumber:appDelegate.ID]){
            if([m1.response isEqual: @(YES)]){
                [self.toggleSwitch setOn:TRUE];
            }
            else{
                [self.toggleSwitch setOn:FALSE];
            }
        }
    }
    
    
    
    currentHeight += 20;
    
    // Add poll creator name label
    self.creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 10)];
    self.creatorNameLabel.font = [UIFont systemFontOfSize:10.0];
     self.creatorNameLabel.textColor = [UIColor lightGrayColor];
    [self.creatorNameLabel setTextAlignment: NSTextAlignmentCenter];
    
    User * u = [self.userDataController.masterEveryoneList objectForKeyedSubscript:self.poll.creatorID];
    [self.creatorNameLabel setText:[NSString stringWithFormat:@"Created by: %@ ", u.full_name]];
   // self.creatorNameLabel.text = [self.creatorNameLabel.text stringByAppendingString:self.poll.creatorID];
    currentHeight += 10;
    

    
    
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, currentHeight)];
    [self.detailsView addSubview:self.titleLabel];
    [self.detailsView addSubview:self.descriptionLabel];
    [self.detailsView addSubview:self.timeRemainingLabel];
    if (self.pollSection != 2){
        [self.detailsView addSubview:self.toggleSwitch];}
    [self.detailsView addSubview:self.creatorNameLabel];
    [self.view addSubview:self.detailsView];
    
    // Set up poll table view
    self.memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, currentHeight, self.screenWidth, (self.screenHeight-currentHeight))];
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    [self.memberTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.memberTableView];
    
    
    
    // Add swipeGestures
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:oneFingerSwipeRight];
    

    
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger currentHeight = 65;
    [self.titleLabel setText:self.poll.title];
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x,currentHeight, self.screenWidth, self.screenHeight)];
    [self.titleLabel sizeToFit];
    [self.titleLabel layoutIfNeeded];
    currentHeight += self.titleLabel.frame.size.height;
    
    self.descriptionLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), self.screenHeight);
    [self.descriptionLabel setText:self.poll.description];
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel layoutIfNeeded];
    currentHeight += self.descriptionLabel.frame.size.height;
    
    self.timeRemainingLabel.frame = CGRectMake((ALIGN+50), currentHeight, 200, 20);
        self.toggleSwitch.frame = CGRectMake((self.screenWidth - 75), currentHeight, 0, 0);
    currentHeight += 20;
    Membership *m1;
    for(Membership *m in self.poll.memberships){
        m1 = [self.poll.memberships objectForKeyedSubscript:m];
        if([m1.user_id isEqualToNumber:appDelegate.ID]){
            if([m1.response isEqual: @(YES)]){
                [self.toggleSwitch setOn:TRUE];
            }
            else{
                [self.toggleSwitch setOn:FALSE];
            }
        }
    }
    // [self.toggleSwitch setOn:self.poll.isAttending];
    
    self.creatorNameLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 10);
    currentHeight += 10;
    
    
    self.detailsView.frame = CGRectMake(0, 0, self.screenWidth, currentHeight);
    currentHeight += 5;
    self.memberTableView.frame = CGRectMake(0, currentHeight, self.screenWidth, (self.screenHeight-currentHeight));
    
            [self.memberTableView reloadData];
}

#pragma mark - Poll Detail Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// HACK - instead of figuring out how to indent the headings properly, I just added a space to the front of the title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    NSUInteger notAttendingRows = 0;
    NSUInteger attendingRows = 0;
   /* Membership *m1;
    for(Membership *m in self.poll.memberships){
        m1 = [self.poll.memberships objectForKeyedSubscript:m];
        
        if([m1.response isEqual:@(YES)]){
            attendingRows++;
            
        }
        else{
            notAttendingRows++;
        }
        
    }*/
    attendingRows = [self.pollDataController countAttending:self.poll];
    
    notAttendingRows = [self.pollDataController countNotAttending:self.poll];
    
    
    switch (section){
        case 0:
            if(attendingRows != 0){
                sectionName = NSLocalizedString(@"   Attending", @"   Attending");}
            break;
        case 1:
            if(notAttendingRows != 0){
                sectionName = NSLocalizedString(@"   Not Attending", @"   Not Attending");}
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSUInteger attendingRows = [self.poll.attending count];//TODO QUESTION how to determine who is attending and who isn't???
    NSUInteger notAttendingRows = 0;
    NSUInteger attendingRows = 0;
    Membership *m1;
   
    if(!self.poll.attending){
        self.poll.attending = [[NSMutableArray alloc] init];
    }
    if(!self.poll.notAttending){
        self.poll.notAttending = [[NSMutableArray alloc] init];
    }
    if([self.poll.attending count]>0){
        [self.poll.attending removeAllObjects];
    }
    if([self.poll.notAttending count]>0){
        [self.poll.notAttending removeAllObjects];
    }
    for(Membership *m in self.poll.memberships){
        m1 = [self.poll.memberships objectForKeyedSubscript:m];
        
        if([m1.response  isEqual: @(YES)]){
            [self.poll.attending addObject:m1.user_id];
            attendingRows++;
        }
        else{
            [self.poll.notAttending addObject:m1.user_id];
            notAttendingRows++;
        }
        
    }
    //attendingRows = [self.pollDataController countAttending:self.poll];
    
    //notAttendingRows = [self.pollDataController countNotAttending:self.poll];
    
    
    
    switch (section){
        case 0:
            //NSLog(@"Number of attendingRows is: %lu", (unsigned long)attendingRows);
            return attendingRows;
        case 1:
            //NSLog(@"Number of notAttendingRows is: %lu", (unsigned long)notAttendingRows);
            return notAttendingRows;// same problem
    }
    return attendingRows + notAttendingRows;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
        castView.contentView.backgroundColor = UIColorFromRGB(0xCEEEEA);
        [castView.textLabel setTextColor:[UIColor darkGrayColor]];
        [castView.textLabel setFont:[UIFont fontWithName: @"HelveticaNeue-BOLD" size: 16.0f]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Getting cell information in PollDetailViewController");
    static NSString *CellIdentifier = @"PollMemberCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //UILabel * nameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 0, 15, box.size.width, 19.0f)];
        //nameLabel.tag = NAME_LABEL_TAG;
        //[nameLabel setTextColor: [UIColor colorWithRed: 79.0f/255.0f green:79.0f/255.0f blue:79.0f/255.0f alpha:1.0f]];
        //[nameLabel setFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 18.0f]];
        //[nameLabel setBackgroundColor: [UIColor clearColor]];
        //nameLabel.textAlignment = NSTextAlignmentCenter;
        //[cell.contentView addSubview: nameLabel];
    }
    
    NSNumber *userIDAtIndex;
    User *user;
    
    switch (indexPath.section) {
        
        case 0:
        { //gets user information
            //keys = [self.poll.memberships allKeys];
            
           // userIDAtIndex = [keys objectAtIndex:(indexPath.row)];
           // m = [self.poll.memberships objectForKeyedSubscript:userIDAtIndex];
            userIDAtIndex = [self.poll.attending objectAtIndex:(indexPath.row)];
            user = [self.userDataController getUser:userIDAtIndex];
            [[cell textLabel] setText:user.full_name];
            cell.imageView.image = user.profilePictureView.image;

            
            //BezierPath
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 50, 50)];
            
            // Create an image context containing the original UIImage.
            UIGraphicsBeginImageContext(user.profilePictureView.image.size);
            
            // Clip to the bezier path and clear that portion of the image.
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextAddPath(context,bezierPath.CGPath);
            CGContextClip(context);
            
            // Draw here when the context is clipped
            [user.profilePictureView.image drawAtPoint:CGPointZero];
            
            // Build a new UIImage from the image context.
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cell.imageView.image = newImage;
            
            break;
        }
        case 1:
        { // keys = [self.poll.memberships allKeys];
            
           // userIDAtIndex = [keys objectAtIndex:(indexPath.row)];
          //  m = [self.poll.memberships objectForKeyedSubscript:userIDAtIndex];
            userIDAtIndex = [self.poll.notAttending objectAtIndex:(indexPath.row)];
            user = [self.userDataController getUser:userIDAtIndex];
            [[cell textLabel] setText:user.full_name];
            cell.imageView.image = user.profilePictureView.image;
            //BezierPath
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 50, 50)];
            
            // Create an image context containing the original UIImage.
            UIGraphicsBeginImageContext(user.profilePictureView.image.size);
            
            // Clip to the bezier path and clear that portion of the image.
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextAddPath(context,bezierPath.CGPath);
            CGContextClip(context);
            
            // Draw here when the context is clipped
            [user.profilePictureView.image drawAtPoint:CGPointZero];
            
            // Build a new UIImage from the image context.
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cell.imageView.image = newImage;
            break;
        }
    }
    // cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    switch (indexPath.section){
        case 0:
            return NO;
        case 1:
            return NO;
    }
    return YES;
}

//Back button
- (IBAction)Back
{
    //NSLog(@"Back button pressed.");
    [self.navigationController popViewControllerAnimated:YES];
}

//Edit button
- (IBAction)Edit
{
    //NSLog(@"Edit button in polldetailview pressed.");
    [self editPoll];
}

- (void)editPoll
{
     [self.titleLabel setHidden:YES];
    NSInteger currentHeight = 70;
    self.editPollTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, currentHeight, (self.screenWidth -20), 40)];
    self.editPollTitle.text = self.titleLabel.text;
    self.editPollTitle.backgroundColor=[UIColor whiteColor];
    self.editPollTitle.textColor = [UIColor blackColor];
    self.editPollTitle.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.editPollTitle.returnKeyType = UIReturnKeyDone;
    self.editPollTitle.borderStyle = UITextBorderStyleRoundedRect;
    self.editPollTitle.tag= 2;
    self.editPollTitle.delegate = self;
    [self.detailsView addSubview:self.editPollTitle];
    currentHeight += self.editPollTitle.frame.size.height+10;
    
        [self.descriptionLabel setHidden:YES];
    self.editPollDescription = [[UITextView alloc] initWithFrame:CGRectMake(ALIGN, currentHeight, (self.screenWidth -ALIGN -ALIGN), 70)];
    self.editPollDescription.textColor = [UIColor blackColor];
    [self.editPollDescription setText: self.descriptionLabel.text];
    self.editPollDescription.backgroundColor=[UIColor whiteColor];
    self.editPollDescription.returnKeyType = UIReturnKeyDone;
    self.editPollDescription.layer.cornerRadius = 5.0f;
    [[self.editPollDescription layer] setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [[self.editPollDescription layer] setBorderWidth:1.2];
    self.editPollDescription.tag= 2;
    self.editPollDescription.textAlignment = NSTextAlignmentLeft;
    self.editPollDescription.delegate = self;
    [self.detailsView addSubview:self.editPollDescription];

    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel layoutIfNeeded];
    currentHeight += self.editPollDescription.frame.size.height+20;
    
    
    self.timeRemainingLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 20);
    currentHeight += 20;
    
    self.creatorNameLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 10);
    currentHeight += 10;
    
    self.detailsView.frame = CGRectMake(0, 0, self.screenWidth, currentHeight);
    currentHeight += 5;
    self.memberTableView.frame = CGRectMake(0, currentHeight, self.screenWidth, (self.screenHeight-currentHeight));
    
    

    self.DeletePollButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.DeletePollButton.frame = CGRectMake((self.screenWidth*0.5 - 50), 30, 100, 30);
    [self.DeletePollButton setTitle:@"Delete Poll" forState:UIControlStateNormal ];
    [self.DeletePollButton addTarget:self
                               action:@selector(Delete)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.detailsView addSubview:self.DeletePollButton];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,(self.screenWidth), 100)];
    [footerView addSubview:self.DeletePollButton];

    self.memberTableView.tableFooterView = footerView;


    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector( Done)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

//when clicking the return button in the keybaord only for title
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (IBAction)Done
{
    //NSLog(@"Done button in edit polldetailview pressed.");
    [self.DeletePollButton removeFromSuperview];
    [self donePoll];
}

- (void)donePoll
{
    //set the edited text
    self.titleLabel.text = self.editPollTitle.text;
    self.descriptionLabel.text = self.editPollDescription.text;
    self.poll.title = self.titleLabel.text;
    self.poll.description = self.descriptionLabel.text;
    //self.pollAtIndex.title = self.poll.title;
    //hide the editable versions and show the uneditable versions

    [self viewDidAppear:YES];

    [self.editPollTitle setHidden:YES];
    [self.titleLabel setHidden:NO];
    [self.editPollDescription setHidden:YES];
    [self.descriptionLabel setHidden:NO];
    //bring back the edit button so the user can make further changes
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(Edit)];
    self.navigationItem.rightBarButtonItem = editButton;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.pollDataController updatePoll:self.poll];
    [appDelegate.masterViewController.pollTableView reloadData];
}


//Leave button
- (IBAction)Leave
{
    //NSLog(@"Leave button in polldetailview pressed.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to leave this poll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    alert.tag = 0;
    [alert show];
}

-(IBAction)Delete{
    //NSLog(@"Delete button in polldetailview pressed.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to delete this poll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Request confirmed
    if (buttonIndex != 0)
    {
        if (alertView.tag == 0)
        {
            [self leavePoll];
        }
        else if (alertView.tag == 1)
        {
            [self deletePoll];
        }
    }
}

- (void)leavePoll
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(self.pollSection == 0)
    {
    [appDelegate.masterViewController.dataController deleteObjectInListAtIndex:self.pollIndex];
    }
    else if (self.pollSection == 2){
        [appDelegate.masterViewController.dataController deleteObjectInExpiredListAtIndex:self.pollIndex];
    }
    [appDelegate.masterViewController.pollTableView reloadData];
    
    [self Back];

}

- (void)deletePoll
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(self.pollSection == 1){
    [appDelegate.masterViewController.dataController  deleteObjectInCreatedListAtIndex:self.pollIndex];
    }
    else if (self.pollSection == 2){
        [appDelegate.masterViewController.dataController deleteObjectInExpiredListAtIndex:self.pollIndex];
    }
    [appDelegate.masterViewController.pollTableView reloadData];

    [self Back];
    
}


- (void)changeSwitch:(id)sender{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        Membership * membership;
    if([sender isOn]){
        self.poll.isAttending = true;
        
        for(NSNumber * mem_id in self.poll.memberships){
            
            membership = [self.poll.memberships objectForKeyedSubscript:mem_id];
            
            if([membership.user_id isEqualToNumber: appDelegate.ID]){
                [self.userDataController updateMembership:(NSNumber *) mem_id Response:@"true"];
            }}
        // [appDelegate.masterViewController.dataController toggleChanged:self.poll :true];
    } else{
        self.poll.isAttending = false;
        for(NSNumber * mem_id in self.poll.memberships){
            
            membership = [self.poll.memberships objectForKeyedSubscript:mem_id];
            
            if([membership.user_id isEqualToNumber:appDelegate.ID ]){
                [self.userDataController updateMembership:(NSNumber *) mem_id Response:@"false"];
                
            }}
        //[appDelegate.masterViewController.dataController toggleChanged:self.poll :false];
    }
    
    [self.userDataController retrieveMemberships:self.poll];
    
    [self.memberTableView reloadData];

}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    // Insert your own code to handle swipe left
}

//Go back
- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    // Insert your own code to handle swipe right
    [self Back];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
