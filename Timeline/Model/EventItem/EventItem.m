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
@synthesize eventId = _eventId;
@synthesize creator = _creator;

//The designated initializer

- (id)initEventItemWithHashedId:(NSString *)eventId creator:(NSString *)creator{
    
    self = [super init];
    
    if (self) {
        
        _eventItemId = [Utility MD5ForString:eventId];
        _creator = creator;
    }
    
    return self;
}

- (id)initEventItemWithId:(NSString *)eventItemId eventId:(NSString *)eventId creator:(NSString *)creator{
    
    self = [self initEventItemWithHashedId:eventId creator:creator];
    
    if (self) {
        _eventItemId = eventItemId;
        _eventId = eventId;
    }
    
    return self;
}

@end
