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

@interface MasterViewController ()

@end

@implementation MasterViewController

// Ensure that only instance of MasterViewController is ever instantiated
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

//Should be old edit mode
/*
- (void)setEditing:(BOOL)flag animated:(BOOL)animated

{
    
    [super setEditing:flag animated:animated];
    
    if (flag == YES){
        [self.pollTableView setEditing:YES animated:YES];
    }
    
    else {
        [self.pollTableView setEditing:NO animated:NO];
    }
    
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIBarButtonItem *newPollButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(CreateNewPoll)];
    self.navigationItem.rightBarButtonItem = newPollButton;
    
    //Old//
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //TODO:: Have not idea it works fine now,but new poll button should not be the left bar button
    self.navigationItem.leftBarButtonItem = newPollButton;
    
    // Set up header view
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, 100)];
    
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
    self.usernameLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(65, 10, (self.screenWidth - 75), 20) ];
    self.usernameLabel.textColor = [UIColor blackColor];
    self.usernameLabel.text = [NSString stringWithFormat: @"Hi, %@!", appDelegate.username];
    self.usernameLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.headerView addSubview:self.usernameLabel];
    
    [self.view addSubview:self.headerView];
    
    // Set up poll table view
    self.pollTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.screenWidth, (self.screenHeight-100))];
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
    return 3;
}

// HACK - instead of figuring out how to indent the headings properly, I just added a space to the front of the title
//Set the Names of Sections of the table
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
        case 2:
            sectionName = NSLocalizedString(@" Expired polls:", @" Expired polls:");
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
            numRows = [self.dataController.masterPollsCreatedList count];
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
        case 2:
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
            // expired poll
            return;
            
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


- (void) leavePollFunction:(NSUInteger)index
{
    NSLog(@"Inside leave Poll function!!");
    [self.dataController deleteObjectInListAtIndex:index];
    
}

- (void) deletePollFunction:(NSUInteger)index
{
    NSLog(@"Inside delete Poll function!!");
    [self.dataController deleteObjectInCreatedListAtIndex:index];
    
}

- (void) erasePollFunction:(NSUInteger)index
{
    NSLog(@"Inside erase Poll function!!");
    [self.dataController deleteObjectInExpiredListAtIndex:index];
    
}


//Swipe to delete button in table view
 -(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
 {
 }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //TODO::: function for delete a poll / leave a poll
     switch (indexPath.section) {
     case 0:
             NSLog(@"leavePoll pressed");
             [self leavePollFunction:indexPath.row];
             break;
     
     case 1:
             NSLog(@"DeletePoll pressed");
             [self deletePollFunction:indexPath.row];
             break;
     
     case 2:
             NSLog(@"ErasePoll pressed");
             [self erasePollFunction:indexPath.row];
             break;
     
     default:
     break;
     }
  
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
