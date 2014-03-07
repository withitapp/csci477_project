//
//  UserSettingViewController.m
//  WithIt
//
//  Created by Peggy Tang on 28/2/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "UserSettingViewController.h"

@interface UserSettingViewController ()

@end

@implementation UserSettingViewController




- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Back Button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;

    //Add detailsView to the main view
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.screenWidth, self.screenHeight)];
    [self.view addSubview:self.detailsView];
    
    // Set up user information table view
    self.InfoTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
    self.InfoTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.InfoTableView.delegate = self;
    self.InfoTableView.dataSource = self;
    [self.InfoTableView reloadData];
    [self.detailsView addSubview:self.InfoTableView];


}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section){
        case 0:
            sectionName = NSLocalizedString(@"User Name:", @"User Name:");
            break;
        case 1:
            sectionName = NSLocalizedString(@"User Email:", @"User Email:");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Software:", @"Software:");
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numRows = 0;
    switch (section){
        case 0:
            numRows = 1;
            NSLog(@"Number of friends' polls: %lu.", (unsigned long)numRows);
            break;
        case 1:
            numRows = 1;
            NSLog(@"Number of created polls: %lu.", (unsigned long)numRows);
            break;
        case 2:
            numRows = 1;
            NSLog(@"Number of expired polls: %lu.", (unsigned long)numRows);
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
        UILabel * nameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 0, 15, 40, 19.0f)];
        nameLabel.tag = @"labelll";
        [nameLabel setTextColor: [UIColor colorWithRed: 79.0f/255.0f green:79.0f/255.0f blue:79.0f/255.0f alpha:1.0f]];
        [nameLabel setFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 18.0f]];
        [nameLabel setBackgroundColor: [UIColor clearColor]];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview: nameLabel];
    }
    
    // Only create the date formatter once
    //static NSDateFormatter *formatter = nil;
    //Poll *pollAtIndex;
    //UISwitch *toggleSwitch = [[UISwitch alloc] init];
    
    switch (indexPath.section) {
        case 0:

            
            break;
            
        case 1:

            break;
        case 2:

            break;
    }
    cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
    
    return cell;
}

- (IBAction)Back
{
    NSLog(@"Back from user setting page.");
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
