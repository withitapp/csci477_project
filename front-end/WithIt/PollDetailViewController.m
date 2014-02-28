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

-(void)setPollDetails:(Poll *)pollAtIndex
{
    if(!pollAtIndex){
        NSLog(@"Poll is null.");
        return;
    }
    self.poll = pollAtIndex;
    //[self.titleLabel setText:self.poll.name];
}

- (void)viewDidLoad
{
    NSLog(@"Loading detail view for poll %@.", self.poll.title);
    [super viewDidLoad];
    
    //[self.navigationController.navigationItem setTitle:@"WithIt"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if(self.poll.creatorID == appDelegate.username) {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(Edit)];
    self.navigationItem.rightBarButtonItem = editButton;
    }
    else {
        UIBarButtonItem *leaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Leave Group" style:UIBarButtonItemStyleBordered target:self action:@selector(Leave)];
        self.navigationItem.rightBarButtonItem = leaveButton;
    }
    
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
    
  //  UIFont *font = [UIFont fontWithName:@"Ariel-Bold" size:40];
    // Add poll title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, (self.screenWidth - 10), 40)];
    //self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.titleLabel setText:self.poll.title];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.detailsView addSubview:self.titleLabel];
    
    
    // Add poll description label
    self.descriptionLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, (self.screenWidth - 10), 90)];
    self.descriptionLabel.font = [UIFont fontWithName:@"Ariel" size:14];
    self.descriptionLabel.textColor = [UIColor darkGrayColor];
    [self.descriptionLabel setText:self.poll.description];
    [self.descriptionLabel setEditable:FALSE];
    [self.detailsView addSubview:self.descriptionLabel];
    
    // Add time remaining for poll label
    self.timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 190, (self.screenWidth - 10), 20)];
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
    [self.detailsView addSubview:self.timeRemainingLabel];
    
    // Add poll creator name label
    self.creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 210, (self.screenWidth - 10), 10)];
    self.creatorNameLabel.font = [UIFont systemFontOfSize:10.0];
     self.creatorNameLabel.textColor = [UIColor lightGrayColor];
    [self.creatorNameLabel setTextAlignment: NSTextAlignmentCenter];
    [self.creatorNameLabel setText:@"Created by: "];
    self.creatorNameLabel.text = [self.creatorNameLabel.text stringByAppendingString:self.poll.creatorID];
    [self.detailsView addSubview:self.creatorNameLabel];
    
    
    [self.view addSubview:self.detailsView];
    
    // Set up poll table view
    self.memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 225, self.screenWidth, (self.screenHeight-280))];
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    [self.memberTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.memberTableView];
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
    
}

//Leave button
- (IBAction)Leave
{
    NSLog(@"Leave button in polldetailview pressed.");
    [self leavePoll];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)leavePoll
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
