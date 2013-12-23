//
//  CreatePollViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "CreatePollViewController.h"

@interface CreatePollViewController ()

@end

@implementation CreatePollViewController

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
    NSLog(@"Loading CreatePoll view.");
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(Cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self.navigationController.navigationItem setTitle:@"WithIt"];
}

- (IBAction)Cancel
{
    NSLog(@"Cancelling poll creation.");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
