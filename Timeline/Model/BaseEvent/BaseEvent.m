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
@synthesize stored = _stored;
@synthesize post = _post;


//The designated initializer
- (id)initBaseEventWithLocation:(CLLocation *)location date:(NSDate *)date shared:(BOOL)shared creator:(NSString *)creator{
    
    self = [super init];
    
    if (self) {
        NSLog(@"%@",[NSString stringWithFormat:@"%f%f%@%i%@",location.coordinate.latitude,location.coordinate.longitude,[date description],shared,creator]);
        _baseEventId = [Utility MD5ForString:[NSString stringWithFormat:@"%f%f%@%i%@",location.coordinate.latitude,location.coordinate.longitude,[date description],shared,creator]];
        _location = location;
        _date = date;
        _shared = shared;
        _creator = creator;
        _stored = 1;
        _post = 1;
    }
    
    return self;
}

- (id)initBaseEventWithId:(NSString *)theId location:(CLLocation *)location date:(NSDate *)date creator:(NSString *)creator shared:(BOOL)shared stored:(BOOL)stored post:(BOOL)post{
    
    self = [self initBaseEventWithLocation:location date:date shared:shared creator:creator];
    
    if (self) {
        _baseEventId = theId;
        _stored = stored;
        _post = post;
    }
    
    return self;
}

@end
