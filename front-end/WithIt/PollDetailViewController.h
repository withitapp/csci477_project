//
//  PollDetailViewController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Poll.h"

@interface PollDetailViewController : UIViewController

@property (strong, nonatomic) Poll *poll;
@property (strong, nonatomic) UIView *detailsView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeRemainingLabel;
@property (strong, nonatomic) UILabel *creatorNameLabel;

@property (strong, nonatomic) UITableView *membersView;

-(void)setPollDetails:(Poll*)poll;

@end
