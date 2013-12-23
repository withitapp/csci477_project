//
//  AppDelegate.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "MasterViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property BOOL isNavigatingAwayFromLogin;

// Display info
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;

// Facebook user info
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) UIImage *profilePicture;

- (void)resetMainViewController;

@end
