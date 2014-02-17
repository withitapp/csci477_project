//
//  MasterViewController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WIViewController.h"
#import "PollDataController.h"

@interface MasterViewController : WIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) PollDataController *dataController;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UITableView *pollTableView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIImageView *profilePictureView;

+ (MasterViewController*)sharedInstance;

@end
