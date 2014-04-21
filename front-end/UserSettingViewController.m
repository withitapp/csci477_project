//
//  UserSettingViewController.m
//  WithIt
//
//  Created by Peggy Tang on 28/2/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "UserSettingViewController.h"
#import "AppDelegate.h"

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
    self.InfoTableView = [[UITableView alloc] initWithFrame:self.detailsView.bounds style:UITableViewStyleGrouped];
    self.InfoTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.InfoTableView.delegate = self;
    self.InfoTableView.dataSource = self;
    self.InfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.InfoTableView reloadData];
    [self.detailsView addSubview:self.InfoTableView];
    
    
    
    //Add logout button
   /* NSInteger LogoutButtonHeight = self.InfoTableView.frame.origin.y + self.InfoTableView.frame.size.height + 100;
    self.LogoutButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.LogoutButton.frame = CGRectMake(40, (self.screenHeight - 200), 200, 40);
    [self.LogoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    [self.LogoutButton addTarget:self action:@selector(logoutButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailsView addSubview:self.LogoutButton];
    
    */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Logout"
    style:UIBarButtonItemStyleBordered
    target:self
    action:@selector(logoutButtonWasPressed:)];
}


-(void)logoutButtonWasPressed:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}


- (CGFloat) tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section{
    
    CGFloat result = 0.0f;
    if ([tableView isEqual:self.InfoTableView]){
        result = 35.0f;
    }
    return result;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section){
        case 0:
            sectionName = NSLocalizedString(@"User Name", @"User Name");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Software", @"Software");
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numRows = 0;
    switch (section){
        case 0:
            numRows = 1;
                       break;
        case 1:
            numRows = 1;

            break;
        default:
            numRows = 0;
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier ];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //create background image for the cell:
        //  UIImageView *bgView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[cell setBackgroundView:bgView];
        [cell setIndentationWidth:0.0];
        
        // create a custom label:                                        x    y   width  height
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 8.0, 300.0, 30.0)];
        [nameLabel setTag:1];
        [nameLabel setBackgroundColor:[UIColor clearColor]]; // transparent label background
        [nameLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        // custom views should be added as subviews of the cell's contentView:
        [cell.contentView addSubview:nameLabel];
        //[nameLabel release];
        
    }

    ///// Styling the table view into rounded - rectangle
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.InfoTableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
      
    // Only create the date formatter once
    //static NSDateFormatter *formatter = nil;
    //Poll *pollAtIndex;
    //UISwitch *toggleSwitch = [[UISwitch alloc] init];
    
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat: @"%@", appDelegate.username];
            
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat: @"Version 1.0"];

            break;
        case 2:

            break;
    }
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
