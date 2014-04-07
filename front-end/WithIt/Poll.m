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
-(id)initWithInfo:(NSString *)name creatorName:(NSNumber *)creatorName description:(NSString *)description endDate:(NSDate *)endDate{
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
-(id)initWithName:(NSString *)name creatorName:(NSNumber *)creatorName description:(NSString *)description{
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
- (id)init:(NSNumber *)creatorName {
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

// Create an NSDictionary from the poll object
-(NSDictionary *)makeDictionary {
    NSLog(@"ID: %@", self.pollID);
    NSLog(@"Updated at: %@", self.updatedAt);
    NSLog(@"CreateDate: %@", self.createDate);
    NSLog(@"Title: %@", self.title);
    NSLog(@"Description: %@", self.description);
    NSLog(@"CreatorID: %@", self.creatorID);
    NSLog(@"End date %@", self.endDate);
    return [NSDictionary dictionaryWithObjectsAndKeys:self.pollID, @"id",
                                                      self.updatedAt, @"updated_at",
                                                      self.createDate, @"created_at",
                                                      self.title, @"title",
                                                      self.description, @"description",
                                                      self.creatorID, @"user_id",
                                                      self.endDate, @"ends_at",
                                                      nil];
}

// Serialize the poll object to JSON
-(NSData*)convertToJSON {
    NSDictionary *dictionary = [self makeDictionary];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    if(error){
        return NULL;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
