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
    NSLog(@"Set poll %@.", self.poll.name);
}

- (void)viewDidLoad
{
    NSLog(@"Loading detail view for poll %@.", self.poll.name);
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.navigationController.navigationItem setTitle:@"WithIt"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenWidth, appDelegate.screenHeight)];
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, (appDelegate.screenWidth - 10), 30)];
    [self.titleLabel setText:self.poll.name];
    [self.detailsView addSubview:self.titleLabel];
    
    
    [self.view addSubview:self.detailsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
