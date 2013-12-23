//
//  MasterViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "MasterViewController.h"
#import "CreatePollViewController.h"
#import "AppDelegate.h"
#import "Poll.h"

#define pollTestURL [NSURL URLWithString:@"http://www-scf.usc.edu/~nannizzi/polls.json"]

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
    self.dataController = [[PollDataController alloc] init];
    
    NSData *pollsData = [[NSData alloc] initWithContentsOfURL:pollTestURL];
    NSError *error;
    self.polls = [NSJSONSerialization JSONObjectWithData:pollsData options:NSJSONReadingMutableContainers error:&error][@"polls"];
	
    if(error){
        NSLog(@"Error loading JSON: %@", [error localizedDescription]);
    }
    else {
        NSLog(@"JSON data loaded.");
        NSLog(@"%@", self.polls);
    }
    
    Poll *poll;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    for(NSDictionary *thePoll in self.polls){
        //NSDate *date = [dateFormat dateFromString:poll[@"pollName"]];
        NSDate *date = [NSDate date];
        poll = [[Poll alloc] initWithName:thePoll[@"pollName"] creatorName:thePoll[@"creatorName"] dateCreated:date];
        NSLog(@"Poll created.");
        [self.dataController addPollWithPoll:poll];
        NSLog(@"Poll added.");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *newPollButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(CreateNewPoll)];
    self.navigationItem.rightBarButtonItem = newPollButton;
    
    UIBarButtonItem *editPollsButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(CreateNewPoll)];
    self.navigationItem.leftBarButtonItem = editPollsButton;
    [self.navigationController.navigationItem setTitle:@"WithIt"];
    
    // Set up header view
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenWidth, 100)];
    
    // Add user welcome label
    self.usernameLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(20, 50, 150, 30) ];
    self.usernameLabel.textColor = [UIColor blackColor];
    self.usernameLabel.text = [NSString stringWithFormat: @"Hi, %@!", appDelegate.username];
    self.usernameLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section){
        case 0:
            sectionName = NSLocalizedString(@"Friends' polls:", @"Friends' polls:");
            break;
        case 1:
            sectionName = NSLocalizedString(@"My polls:", @"My polls:");
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
    static NSDateFormatter *formatter = nil;
    Poll *pollAtIndex;
    
    switch (indexPath.section) {
        case 0:
            NSLog(@"Creating cell in section 0.");
            if (!formatter) {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
            }
            
            pollAtIndex = [self.dataController objectInListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:pollAtIndex.name];
            [[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            break;
            
        case 1:
            NSLog(@"Creating cell in section 1.");
            if (!formatter) {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
            }
            
            pollAtIndex = [self.dataController objectInCreatedListAtIndex:(indexPath.row)];
            [[cell textLabel] setText:pollAtIndex.name];
            [[cell detailTextLabel] setText:[formatter stringFromDate:(NSDate *)pollAtIndex.dateCreated]];
            break;
    }
    cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
    UISwitch *toggleSwitch = [[UISwitch alloc] init];
    cell.accessoryView = [[UIView alloc] initWithFrame:toggleSwitch.frame];
    [cell.accessoryView addSubview:toggleSwitch];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end