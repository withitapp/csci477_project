//
//  PublishPollViewController.m
//  WithIt
//
//  Created by Peggy Tang on 22/1/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "PublishPollViewController.h"
#import "AppDelegate.h"

@interface PublishPollViewController ()

@end

@implementation PublishPollViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    NSLog(@"Loading PublishPoll view.");
    [super viewDidLoad];
   // AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    //Back Button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationItem setTitle:@"WithIt"];
    
}

//Back button
- (IBAction)Back
{
    NSLog(@"Back button pressed.");
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
