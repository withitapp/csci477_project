//
//  DataController.h
//  WithIt
//
//  Created by Patrick Dalton on 2/28/14.
//  Copyright (c) 2014 WithIt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject
{
    dispatch_semaphore_t semaphore;
    dispatch_semaphore_t semaphore_users;
}

@end

