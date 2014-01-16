//
//  PollDetailViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "PollDetailViewController.h"
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
    NSLog(@"Set poll %@.", self.poll.title);
}

- (void)viewDidLoad
{
    NSLog(@"Loading detail view for poll %@.", self.poll.title);
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.navigationController.navigationItem setTitle:@"WithIt"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenWidth, appDelegate.screenHeight)];
    
    // Add poll title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, (appDelegate.screenWidth - 10), 30)];
    [self.titleLabel setText:self.poll.title];
    [self.detailsView addSubview:self.titleLabel];
    
    // Add poll creator name label
    self.creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, (appDelegate.screenWidth - 10), 30)];
    [self.creatorNameLabel setText:self.poll.creatorID];
    [self.detailsView addSubview:self.creatorNameLabel];
    
    // Add time remaining for poll label
    self.timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, (appDelegate.screenWidth - 10), 30)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[self.timeRemainingLabel setText:[dateFormatter stringFromDate:self.poll.dateCreated]]; // FIX ME!
    [self.detailsView addSubview:self.timeRemainingLabel];
    
    [self.view addSubview:self.detailsView];
    
    // Set up poll table view
    self.memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 180, appDelegate.screenWidth, (appDelegate.screenHeight-180))];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
