//
//  Group.m
//  Timeline
//
//  Created by Alessandro Boron on 20/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize groupId = _groupId;
@synthesize name = _name;
@synthesize users = _users;

//The designated initializer
- (id)initGroupWithName:(NSString *)name users:(NSArray *)users{
    
    self = [super init];
    
    if (self) {
        _name = name;
        _users = users;
    }

    return self;
}

@end
