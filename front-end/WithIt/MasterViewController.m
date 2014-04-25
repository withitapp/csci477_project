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
#import "UserSettingViewController.h"
#import "AppDelegate.h"

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MasterViewController ()

@end

@implementation MasterViewController

// Ensure that only one instance of MasterViewController is ever instantiated
+ (MasterViewController*)sharedInstance
{
    static MasterViewController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[MasterViewController alloc] init];
    });
    return _sharedInstance;
}

- (void)loadData
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(320.0, 500.0);
    }
    [super awakeFromNib];
    
    // Use sharedInstance instead of init to ensure use of singleton
    self.dataController = [PollDataController sharedInstance];
    [self.dataController loadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(CreateNewPoll)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStyleBordered target:self action:@selector(UserSetting)];
    
    // Set up poll table view
    self.pollTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, (self.screenHeight-64))];
    self.pollTableView.delegate = self;
    self.pollTableView.dataSource = self;
    self.pollTableView.bounces = NO;
    self.pollTableView.scrollEnabled = YES;
    [self.pollTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.view addSubview:self.pollTableView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadData];
    [self.dataController determineExpiredPoll];
    [self.pollTableView reloadData];
}

- (IBAction)CreateNewPoll
{
    CreatePollViewController *createPollViewController = [[CreatePollViewController alloc] init];
    [self.navigationController pushViewController:createPollViewController animated:YES];
}

- (IBAction)UserSetting
{
    UserSettingViewController *userSettingViewController = [[UserSettingViewController alloc] init];
    [self.navigationController pushViewController:userSettingViewController animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
////////

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
        castView.contentView.backgroundColor = UIColorFromRGB(0xCEEEEA);
        [castView.textLabel setTextColor:[UIColor darkGrayColor]];
        [castView.textLabel setFont:[UIFont fontWithName: @"HelveticaNeue-BOLD" size: 16.0f]];
    }
}

/////////

// HACK - instead of figuring out how to indent the headings properly, I just added a space to the front of the title
//Set the Names of Sections of the table
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section){
        case 0:
            if([self.dataController.masterPollsList count]!= 0){
            sectionName = NSLocalizedString(@"   Friends' Polls", @"   Friends' Polls");
            }
                break;
        case 1:
            if([self.dataController.masterPollsCreatedList count] != 0){
            sectionName = NSLocalizedString(@"   My Polls", @"   My Polls");
            }
                break;
        case 2:
            if([self.dataController.masterPollsExpiredList count]!= 0){
            sectionName = NSLocalizedString(@"   Expired Polls", @"   Expired Polls");
            }
            break;
    }
    return sectionName;
}

//Set the Number of rows of each section in table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numRows = 0;
    switch (section){
        case 0:
            numRows = [self.dataController.masterPollsList count];
            NSLog(@"Number of friends' polls: %lu.", (unsigned long)numRows);
            break;
        case 1:
            numRows = [self.dataController.masterPollsCreatedList count];
            NSLog(@"Number of created polls: %lu.", (unsigned long)numRows);
            break;
        case 2:
            numRows = [self.dataController.masterPollsExpiredList count];
            NSLog(@"Number of expired polls: %lu.", (unsigned long)numRows);
            break;
    }
    return numRows;
}

//Return each "poll" into corresponding section of the table
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
            /////
            [[cell textLabel] setTextColor:UIColorFromRGB(0x297A6E)];
            [[cell textLabel] setFont: [UIFont fontWithName: @"HelveticaNeue" size: 18.0f]];
            /////
            cell.accessoryView = nil;
            //[[UIView alloc] initWithFrame:toggleSwitch.frame];
            //[cell.accessoryView addSubview:toggleSwitch];
            
            break;
            
        case 1:
            if (!formatter) {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
            }
            
            pollAtIndex = [self.dataController objectInCreatedListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:pollAtIndex.title];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            /////
            [[cell textLabel] setTextColor:UIColorFromRGB(0x297A6E)];
            [[cell textLabel] setFont: [UIFont fontWithName: @"HelveticaNeue" size: 18.0f]];
            /////
            cell.accessoryView = nil; //avoid toggleswitch show after removing rows in section 0
            break;
        case 2:
            if (!formatter) {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
            }
            
            pollAtIndex = [self.dataController  objectInExpiredListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:pollAtIndex.title];
            //[[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            
            /////
            [[cell textLabel] setTextColor:UIColorFromRGB(0x297A6E)];
            [[cell textLabel] setFont: [UIFont fontWithName: @"HelveticaNeue" size: 18.0f]];
            /////
            cell.accessoryView = nil;//avoid toggleswitch show after removing rows in section 0
            break;
    }
    
    // TODO: add some code to figure out what percentage of members are attending and choose an image
    cell.imageView.image = [UIImage imageNamed:@"almost_full_circle.png"];

    return cell;
}

//This should be the one delete show when in edit mode
/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    switch (indexPath.section){
        case 0:
            return NO;
        case 1:
            return YES;
        case 2:
            return NO;
    }
    return YES;
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row %ld in section %ld.", (long)indexPath.row, (long)indexPath.section);
    Poll *pollAtIndex;
    switch (indexPath.section) {
        case 0:
            pollAtIndex = [self.dataController objectInListAtIndex:(indexPath.row)];
            break;
            
        case 1:
            pollAtIndex = [self.dataController objectInCreatedListAtIndex:(indexPath.row)];
            break;
        
        case 2:
            pollAtIndex = [self.dataController objectInExpiredListAtIndex:(indexPath.row)];
            break;
            
        default:
            NSLog(@"Something went wrong!");
            return;
    }
    
    NSLog(@"Selected poll: %@.", pollAtIndex.title);
    
    [self.pollTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PollDetailViewController *detailViewController = [[PollDetailViewController alloc] init];
    [detailViewController setPollDetails:pollAtIndex atIndex:indexPath.row atSection:indexPath.section];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ((alertView.tag % 10) == 1) {
        if (buttonIndex == 1) {
            [self leavePollFunction:(alertView.tag/10)];
        }
    }
    else if ((alertView.tag % 10) == 2) {
        if (buttonIndex == 1) {
            [self deletePollFunction:(alertView.tag/10)];
        }
    }
    else if ((alertView.tag % 10) == 3) {
        if (buttonIndex == 1) {
            [self erasePollFunction:(alertView.tag/10)];
        }
    }
}

- (void) leavePollFunction:(NSUInteger)index
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Poll * poll;
    Membership * membership;
    
    poll = [self.dataController.masterPollsList objectAtIndex: index];
    [self.dataController.userDataController retrieveMemberships:poll];
    NSLog(@"APP ID: %@", appDelegate.ID);
    for(NSNumber * mem_id in poll.memberships){
        membership = [poll.memberships objectForKeyedSubscript:mem_id];
        NSLog(@"mem_id: %@", membership.user_id);
        if([membership.user_id isEqualToNumber:appDelegate.ID]){
            [self.dataController.userDataController deleteMembership:mem_id];
            
            NSLog(@"Leaving poll with membership ID: %@", mem_id);
        }
        
            //needs to be first called
        }
    
    [self.dataController deleteObjectInListAtIndex:index];
    [self.pollTableView reloadData];
}

- (void) deletePollFunction:(NSUInteger)index
{
    NSLog(@"Inside delete Poll function!!");
    [self.dataController deletePoll:[self.dataController.masterPollsCreatedList objectAtIndex: index]]; //needs to be first called
    [self.dataController deleteObjectInCreatedListAtIndex:index];
    [self.pollTableView reloadData];
}

- (void) erasePollFunction:(NSUInteger)index
{
    NSLog(@"Inside erase Poll function!!");
    [self.dataController deleteObjectInExpiredListAtIndex:index];
    [self.pollTableView reloadData];
}


//Swipe to delete button in table view
 -(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
 {
 }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Inside leave Poll function!!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete a poll?" message:@"Do you really want to delete this poll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    
    
    //TODO::: function for delete a poll / leave a poll
     switch (indexPath.section) {
     case 0:
             NSLog(@"leavePoll pressed");
             alert.tag = (indexPath.row * 10) + 1;
             break;
     
     case 1:
             NSLog(@"DeletePoll pressed");
             alert.tag = (indexPath.row * 10) + 2;
             break;
     
     case 2:
             NSLog(@"ErasePoll pressed");
             alert.tag = (indexPath.row * 10) + 3;
             break;
     
     default:
     break;
     }
    
    [alert show];
  
   // TODO::should include below function into the leavePollFunction/ DeletePollFunction/ ErasePollFunction
  
    // If row is deleted, remove it from the list.
   
    /*
     if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete your data item here
    
        // Animate the deletion from the table.
        [self.pollTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      
    }*/
    
    // Reload the table view.
    [tableView reloadData];
}

//Change "delete" to "leave " for other people's polls, and to "erase" for expired polls
- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.section) {
        case 0:
           return @"Leave";
            break;
            
        case 1:
            return @"Delete";
            break;
            
        case 2:
            return @"Erase";
            
        default:
            NSLog(@"Something went wrong!");
            return @"Something went wrong!";

}
}





@end
