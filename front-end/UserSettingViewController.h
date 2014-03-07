//
//  UserSettingViewController.h
//  WithIt
//
//  Created by Peggy Tang on 28/2/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WIViewController.h"

@interface UserSettingViewController :  WIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *detailsView;

@property (strong, nonatomic) UITableView *InfoTableView;




@end
