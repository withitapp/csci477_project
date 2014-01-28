//
//  ViewController.h
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "WIViewController.h"

@interface LoginViewController : WIViewController <FBLoginViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;

@end

