//
//  Poll.m
//  WithIt
//
//  Created by Francesca Nannizzi on 12/19/13.
//  Copyright (c) 2013 WithIt. All rights reserved.
//

#import "Poll.h"

@implementation Poll

// Use this init when testing
-(id)initWithInfo:(NSString *)name creatorName:(NSString *)creatorName description:(NSString *)description endDate:(NSDate *)endDate{
    self = [super init];
    if (self) {
        _title = name;
        _creatorID = creatorName;
        _description = description;
        _createDate = [[NSDate alloc] init];
        _endDate = endDate;
        return self;
    }
    return nil;
}

// Use this init when testing
-(id)initWithName:(NSString *)name creatorName:(NSString *)creatorName description:(NSString *)description{
    self = [super init];
    if (self) {
        _title = name;
        _creatorID = creatorName;
        _description = description;
        _createDate = [[NSDate alloc] init];
        return self;
    }
    return nil;
}

// Use this init when the user decides to create a new poll
- (id)init:(NSString *)creatorName {
    // Forward to the "designated" initialization method
    return [self initWithName:@"Untitled Poll" creatorName:creatorName description:@"No description given"];
}


-(void)populateMembers:(NSArray *) users{
    _members = [[NSMutableArray alloc] init];
    _members = [users mutableCopy];
}

-(void)addMember:(NSObject *) user{
    [_members addObject:user];
}

-(void)removeMember:(NSObject *) user{
    [_members removeObject:user];
}
/*
-(void)setDescription:(NSString *) description{
    _description = description;
}*/

@end
