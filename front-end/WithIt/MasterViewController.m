//
//  MasterViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "MasterViewController.h"
#import "CreatePollViewController.h"
#import "PollDetailViewController.h"
#import "AppDelegate.h"

#define userDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/users.json"]
#define pollDataURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/polls.json"]

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadData
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 500.0);
    }
    [super awakeFromNib];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.dataController = [[PollDataController alloc] init];
    
    // Get user data including polls
    NSData *userData = [[NSData alloc] initWithContentsOfURL:userDataURL];
    NSError *userDataError;
    NSDictionary *users = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:&userDataError][@"users"];
    
    if(userDataError){
        NSLog(@"Error loading user data JSON: %@", [userDataError localizedDescription]);
    }
    else {
        NSLog(@"JSON user data loaded.");
        //NSLog(@"%@", users);
    }
    
    // Parse user data
    for(NSDictionary *theUser in users){
        NSString *theID = theUser[@"id"];
            if([theID isEqualToString:appDelegate.userID]){
                self.userID = theUser[@"id"];
                self.userName = theUser[@"name"]; // We actually want to check our stored name for the user with their current Facebook name here
                self.userFriendsList = theUser[@"friends"];
                self.userPollsList = theUser[@"polls"];
                break;
            }
    }
    
    // Get poll data
    NSData *pollsData = [[NSData alloc] initWithContentsOfURL:pollDataURL];
    NSError *pollDataError;
    NSDictionary *polls = [NSJSONSerialization JSONObjectWithData:pollsData options:NSJSONReadingMutableContainers error:&pollDataError][@"polls"];
	
    if(pollDataError){
        NSLog(@"Error loading poll data JSON: %@", [pollDataError localizedDescription]);
    }
    else {
        NSLog(@"JSON poll data loaded.");
        //NSLog(@"%@", polls);
    }
    
    // Parse poll data
    Poll *poll;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hhmmss"];
    
    for(NSDictionary *thePoll in polls){
        NSString *pollID = thePoll[@"id"];
        for(NSString *theID in self.userPollsList){
            if([pollID isEqualToString:theID]){
                poll = [[Poll alloc] init];
                poll.pollID = pollID;
                poll.title = thePoll[@"title"];
                poll.description = thePoll[@"description"];
                poll.creatorID = thePoll[@"creator"];
                //poll.endDate = [dateFormatter dateFromString:thePoll[@"endDate"]];
                //poll.endTime = [timeFormatter dateFromString:thePoll[@"endTime"]];
                //poll.members = thePoll[@"members"];
                //NSLog(@"Member list %@", poll.members);
                [self.dataController addPollWithPoll:poll];
                break;
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIBarButtonItem *newPollButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(CreateNewPoll)];
    self.navigationItem.rightBarButtonItem = newPollButton;
    
    UIBarButtonItem *editPollsButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(CreateNewPoll)];
    self.navigationItem.leftBarButtonItem = editPollsButton;
    [self.navigationController.navigationItem setTitle:@"WithIt"];
    
    // Set up header view
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenWidth, 100)];
    
    // Add user profile picture
    self.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", appDelegate.userID]]];
        if (!imageData){
            NSLog(@"Failed to download user profile picture.");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePictureView.image = [UIImage imageWithData: imageData];
        });
    });
    
    [self.headerView addSubview:self.profilePictureView];
    
    // Add user welcome label
    self.usernameLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(65, 10, (appDelegate.screenWidth - 75), 20) ];
    self.usernameLabel.textColor = [UIColor blackColor];
    //self.usernameLabel.backgroundColor = [UIColor greenColor];
    self.usernameLabel.text = [NSString stringWithFormat: @"Hi, %@!", appDelegate.username];
    self.usernameLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.headerView addSubview:self.usernameLabel];
    
    [self.view addSubview:self.headerView];
    
    // Set up poll table view
    self.pollTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, appDelegate.screenWidth, (appDelegate.screenHeight-100))];
    self.pollTableView.delegate = self;
    self.pollTableView.dataSource = self;
    [self.pollTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.pollTableView];
    [self loadData];
    
}

- (IBAction)CreateNewPoll
{
    CreatePollViewController *createPollViewController = [[CreatePollViewController alloc] init];
    [self.navigationController pushViewController:createPollViewController animated:YES];
}

#pragma mark - Table View

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
            sectionName = NSLocalizedString(@" Friends' polls:", @" Friends' polls:");
            break;
        case 1:
            sectionName = NSLocalizedString(@" My polls:", @" My polls:");
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numRows = 0;
    switch (section){
        case 0:
            numRows = [self.dataController.masterPollsList count];
            NSLog(@"Number of friends' polls: %d.", numRows);
            break;
        case 1:
            numRows = [self.dataController.masterPollsCreatedList count];
            NSLog(@"Number of created polls: %d.", numRows);
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PollCell";
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
    
    // Only create the date formatter once
    static NSDateFormatter *formatter = nil;
    Poll *pollAtIndex;
    UISwitch *toggleSwitch = [[UISwitch alloc] init];
    
    switch (indexPath.section) {
        case 0:
            if (!formatter) {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
            }
            
            pollAtIndex = [self.dataController objectInListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:pollAtIndex.title];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            
            // Add toggle switch to polls the user did not create
            cell.accessoryView = [[UIView alloc] initWithFrame:toggleSwitch.frame];
            [cell.accessoryView addSubview:toggleSwitch];
            
            break;
            
        case 1:
            if (!formatter) {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
            }
            
            pollAtIndex = [self.dataController objectInCreatedListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:pollAtIndex.title];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
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
            return YES;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row %d in section %d.", indexPath.row, indexPath.section);
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
    
    NSLog(@"Selected poll: %@.", pollAtIndex.title);
    
    [self.pollTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PollDetailViewController *detailViewController = [[PollDetailViewController alloc] init];
    [detailViewController setPollDetails:pollAtIndex];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
