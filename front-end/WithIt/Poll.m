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
        _description = description;
        _createDate = [[NSDate alloc] init];
        _endDate = endDate;
        // setting these for convenience, we need to actually set them later
        _pollID = [[NSNumber alloc] initWithInt:45];
        _updatedAt = endDate;
        _creatorID = [[NSNumber alloc] initWithInt:45];
        
        
        
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
    NSLog(@"POLL STUFF: %@", self.title);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'SS'Z'"];
    NSString *endDate = [dateFormatter stringFromDate:_endDate];
    NSString *createDate = [dateFormatter stringFromDate:_endDate];
    NSString *updateDate = [dateFormatter stringFromDate:_endDate];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.pollID, @"id",
                                                      updateDate, @"updated_at",
                                                      createDate, @"created_at",
                                                      endDate, @"ends_at",
                                                      _title, @"title",
                                                      _description, @"description",
                                                      _creatorID, @"user_id",
                                                      nil];
    return dictionary;
}

// Serialize the poll object to JSON
-(NSData*)convertToJSON {
    NSDictionary *dictionary = [self makeDictionary];
    NSLog(@"Dictionary: %@", dictionary);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    if(error){
        NSLog(@"Error converting poll to JSON: %@", [error localizedDescription]);
        return NULL;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON: %@", jsonString);
    return jsonString;
}

@end
