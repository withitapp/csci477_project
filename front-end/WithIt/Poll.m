//
//  Poll.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "Poll.h"

@implementation Poll

-(id)initWithName:(NSString *)name creatorName:(NSString *)creatorName dateCreated:(NSDate *)dateCreated{
    self = [super init];
    if (self) {
        _name = name;
        _creatorName = creatorName;
        _dateCreated = dateCreated;
        return self;
    }
    return nil;
}

@end
