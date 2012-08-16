//
//  EventItem.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "EventItem.h"

@implementation EventItem

@synthesize eventItemId = _eventItemId;
@synthesize creator = _creator;

//The designated initializer
- (id)initEventItemWithId:(NSString *)eventId creator:(NSString *)creator{
    
    self = [super init];
    
    if (self) {
        
        _eventItemId = [Utility MD5ForString:eventId];
        _creator = creator;
    }
    
    return self;
}

@end
