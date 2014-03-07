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

NSArray *tableData;

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
    self.InfoTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    self.InfoTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.InfoTableView.delegate = self;
    self.InfoTableView.dataSource = self;
    [self.InfoTableView reloadData];
    [self.view addSubview:self.InfoTableView];


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
