//
//  UserDataController.m
//  WithIt
//
//  Created by Patrick Dalton on 4/11/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import "UserDataController.h"
 #import "DataController.h"
 #import "PollDataController.h"
 #include "AppDelegate.h"
 #import "Poll.h"
 #import "User.h"
 #import <FacebookSDK/FBSessionTokenCachingStrategy.h>

@interface PollDataController () <NSURLConnectionDelegate>
- (id)init;
@end
@implementation UserDataController : NSObject 

/*
#define userDataURL [NSURL URLWithString:@"http://withitapp.com:3000/users"]
#define pollDataURL [NSURL URLWithString:@"http://withitapp.com:3000/polls"]

-(NSDictionary*) makeServerRequestWithRequest:(NSURLRequest *)request
{
    __block NSDictionary *dataDictionary;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *httpResponse = nil;
                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   httpResponse = (NSHTTPURLResponse *) response;
                               }
                               
                               // NSURLConnection's completionHandler is called on the background thread.
                               // Prepare a block to show an alert on the main thread:
                               __block NSString *message = @"";
                               void (^showAlert)(void) = ^{
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                       [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   }];
                               };
                               
                               // Check for error or non-OK statusCode:
                               if (error || httpResponse.statusCode != 200) {
                                   message = @"Error fetching data.";
                                   NSLog(@"URL error: %@", error);
                                   showAlert();
                                   // we should handle the error here
                                   dispatch_semaphore_signal(semaphore);
                                   return;
                               }
                               
                               // Get user data including polls
                               NSError *dataError;
                               //NSDictionary *dataDictionary;
                               @try{
                                   dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&dataError];
                               } @catch (NSException *NSInvalidArgumentException){
                                   NSLog(@"Got invalid data: %@", NSInvalidArgumentException);
                               }
                               if(dataError){
                                   NSLog(@"Error loading data JSON: %@", [dataError localizedDescription]);
                               }
                               
                               dispatch_semaphore_signal(semaphore);
                           }];
    
    NSLog(@"Sempaphore dispatched");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return dataDictionary;
}

*/
@end
