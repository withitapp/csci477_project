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

-(void)setPollDetails:(Poll *)pollAtIndex:(NSUInteger)index
{
    if(!pollAtIndex){
        NSLog(@"Poll is null.");
        return;
    }
    self.poll = pollAtIndex;
    self.pollIndex = index;
    //[self.titleLabel setText:self.poll.name];
}

- (void)viewDidLoad
{
    NSLog(@"Loading detail view for poll %@.", self.poll.title);
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    //You can edit your own poll
    if(self.poll.creatorID == appDelegate.username) {
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
    self.timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 20)];
    self.timeRemainingLabel.font = [UIFont systemFontOfSize:10.0];
    [self.timeRemainingLabel setTextAlignment: NSTextAlignmentCenter];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.timeRemainingLabel setText:@"End Date: "]; // FIX ME... to time remaining?!
    if(self.poll.endDate != nil){
        self.timeRemainingLabel.text = [self.timeRemainingLabel.text stringByAppendingString:[dateFormatter stringFromDate:self.poll.endDate]]; }
    else
        self.timeRemainingLabel.text = [self.timeRemainingLabel.text stringByAppendingString:@"None Given"];
    currentHeight += 20;
    
    // Add poll creator name label
    self.creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 10)];
    self.creatorNameLabel.font = [UIFont systemFontOfSize:10.0];
     self.creatorNameLabel.textColor = [UIColor lightGrayColor];
    [self.creatorNameLabel setTextAlignment: NSTextAlignmentCenter];
    [self.creatorNameLabel setText:@"Created by: "];
    self.creatorNameLabel.text = [self.creatorNameLabel.text stringByAppendingString:self.poll.creatorID];
    currentHeight += 10;
    
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, currentHeight)];
    [self.detailsView addSubview:self.titleLabel];
    [self.detailsView addSubview:self.descriptionLabel];
    [self.detailsView addSubview:self.timeRemainingLabel];
    [self.detailsView addSubview:self.creatorNameLabel];
    [self.view addSubview:self.detailsView];
    
    // Set up poll table view
    self.memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, currentHeight, self.screenWidth, (self.screenHeight-currentHeight))];
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    [self.memberTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.memberTableView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSInteger currentHeight = 65;
    [self.titleLabel setText:self.poll.title];
    [self.titleLabel sizeToFit];
    [self.titleLabel layoutIfNeeded];
    currentHeight += self.titleLabel.frame.size.height;
    
    self.descriptionLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), self.screenWidth);
    [self.descriptionLabel setText:self.poll.description];
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel layoutIfNeeded];
    currentHeight += self.descriptionLabel.frame.size.height;
    
    self.timeRemainingLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 20);
    currentHeight += 20;
    
    self.creatorNameLabel.frame = CGRectMake(ALIGN, currentHeight, (self.screenWidth - ALIGN), 10);
    currentHeight += 10;
    
    self.detailsView.frame = CGRectMake(0, 0, self.screenWidth, currentHeight);
    currentHeight += 5;
    self.memberTableView.frame = CGRectMake(0, currentHeight, self.screenWidth, (self.screenHeight-currentHeight));
    
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
    switch (section){
        case 0:
            sectionName = NSLocalizedString(@" Attending:", @" Attending:");
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
            numRows = 3; // need to add member lists to poll data
            break;
        case 1:
            numRows = 8; // same problem
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
        //UILabel * nameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 0, 15, box.size.width, 19.0f)];
        //nameLabel.tag = NAME_LABEL_TAG;
        //[nameLabel setTextColor: [UIColor colorWithRed: 79.0f/255.0f green:79.0f/255.0f blue:79.0f/255.0f alpha:1.0f]];
        //[nameLabel setFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 18.0f]];
        //[nameLabel setBackgroundColor: [UIColor clearColor]];
        //nameLabel.textAlignment = NSTextAlignmentCenter;
        //[cell.contentView addSubview: nameLabel];
    }
    
    // *pollAtIndex;
    
    switch (indexPath.section) {
        case 0:
            //pollAtIndex = [self.dataController objectInListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:@"MemberName"];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            //cell.backgroundColor = [UIColor greenColor];
            break;
            
        case 1:
            //pollAtIndex = [self.dataController objectInCreatedListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:@"MemberName"];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            //cell.backgroundColor = [UIColor redColor];
            break;
    }
    cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*NSLog(@"Selected row %d in section %d.", indexPath.row, indexPath.section);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Poll *pollAtIndex;
    switch (indexPath.section) {
        case 0:
            pollAtIndex = [self.dataController objectInListAtIndex:(indexPath.row)];
            break;
            
        case 1:
            pollAtIndex = [self.dataController objectInCreatedListAtIndex:(indexPath.row)];
            break;
            
        default:
            NSLog(@"Something went wrong!");
            return;
    }
    
    NSLog(@"Selected poll: %@.", pollAtIndex.name);
    
    [self.pollTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PollDetailViewController *detailViewController = [[PollDetailViewController alloc] init];
    [detailViewController setPollDetails:pollAtIndex];
    [appDelegate.navigationController pushViewController:detailViewController animated:YES];*/
}

//Back button
- (IBAction)Back
{
    NSLog(@"Back button pressed.");
    [self.navigationController popViewControllerAnimated:YES];
}

//Edit button
- (IBAction)Edit
{
    NSLog(@"Edit button in polldetailview pressed.");
    [self editPoll];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)editPoll
{
    //Hide the Poll Label and show an editable version of it
    [self.titleLabel setHidden:YES];
    self.editPollTitle = [[UITextField alloc] initWithFrame:CGRectMake(10, 65, (self.screenWidth - 10), 40)];
    self.editPollTitle.text = self.titleLabel.text;
    self.editPollTitle.backgroundColor=[UIColor whiteColor];
    self.editPollTitle.textColor = [UIColor blackColor];
    self.editPollTitle.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.editPollTitle.returnKeyType = UIReturnKeyDone;
    self.editPollTitle.borderStyle = UITextBorderStyleRoundedRect;
    self.editPollTitle.tag= 2;
    //self.PollTitleTextField.textAlignment = UITextAlignmentLeft;
    self.editPollTitle.delegate = self;
    [self.detailsView addSubview:self.editPollTitle];
    
    //Hide the poll description and show an editable version of it
    [self.descriptionLabel setHidden:YES];
    self.editPollDescription = [[UITextView alloc] initWithFrame:CGRectMake(10, 110, (self.screenWidth - 10), 80)];
    self.editPollDescription.textColor = [UIColor blackColor];
    [self.editPollDescription setText: self.descriptionLabel.text];
    self.editPollDescription.backgroundColor=[UIColor whiteColor];
    // self.PollDescriptionTextField.textColor = [UIColor blackColor];
    self.editPollDescription.returnKeyType = UIReturnKeyDone;
    self.editPollDescription.layer.cornerRadius = 5.0f;
    [[self.editPollDescription layer] setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [[self.editPollDescription layer] setBorderWidth:1.2];
    // self.PollDescriptionTextField.layer.borderStyle = UITextBorderStyleRoundedRect;
    self.editPollDescription.tag= 2;
    self.editPollDescription.textAlignment = NSTextAlignmentLeft;
    self.editPollDescription.delegate = self;
    [self.detailsView addSubview:self.editPollDescription];
    

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


    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(Done)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)Done
{
    NSLog(@"Done button in edit polldetailview pressed.");
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
    [self.editPollTitle setHidden:YES];
    [self.titleLabel setHidden:NO];
    [self.editPollDescription setHidden:YES];
    [self.descriptionLabel setHidden:NO];
    //bring back the edit button so the user can make further changes
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(Edit)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.masterViewController.pollTableView reloadData];
}

//Leave button
- (IBAction)Leave
{
    NSLog(@"Leave button in polldetailview pressed.");
    [self leavePoll];
    //[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)Delete{
        NSLog(@"Delete button in polldetailview pressed.");
        [self deletePoll];
}

- (void)leavePoll
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [appDelegate.masterViewController.dataController deleteObjectInListAtIndex:self.pollIndex];

    [appDelegate.masterViewController.pollTableView reloadData];
    
    [self Back];

}

- (void)deletePoll
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.masterViewController.dataController  deleteObjectInCreatedListAtIndex:self.pollIndex];
    
    [appDelegate.masterViewController.pollTableView reloadData];
    
    [self Back];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
