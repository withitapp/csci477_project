//
//  WIViewController.m
//  WithIt
//
//  Created by Francesca Nannizzi on 1/27/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "WIViewController.h"
#import "AppDelegate.h"

/*@interface WIViewController ()

@end*/

@implementation WIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"WithIt";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
