//
//  BaseEvent.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "BaseEvent.h"

@implementation BaseEvent

@synthesize baseEventId = _baseEventId;
@synthesize location = _location;
@synthesize date = _date;
@synthesize shared = _shared;
@synthesize creator = _creator;

//The designated initializer
- (id)initBaseEventWithLocation:(CLLocation *)location date:(NSDate *)date shared:(BOOL)shared creator:(NSString *)creator{
    
    self = [super init];
    
    if (self) {
        _baseEventId = [Utility MD5ForString:[NSString stringWithFormat:@"%f%f%@%i%@",location.coordinate.latitude,location.coordinate.longitude,[date description],shared,creator]];
        _location = location;
        _date = date;
        _shared = shared;
        _creator = creator;
    }
    
    return self;
}

@end
