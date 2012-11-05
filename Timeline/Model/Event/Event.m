//
//  Event.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize eventItems = _eventItems;
@synthesize emotions = _emotions;

//The designated Initializer
- (id)initEventWithLocation:(CLLocation *)location date:(NSDate *)date shared:(BOOL)shared creator:(NSString *)creator{
    
    self = [super initBaseEventWithLocation:location date:date shared:shared creator:creator];
    
    if (self) {
        _eventItems = [[NSMutableArray alloc] init];
        _emotions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initEventWithId:(NSString *)theId location:(CLLocation *)location date:(NSDate *)date creator:(NSString *)creator shared:(BOOL)shared stored:(BOOL)stored post:(BOOL)post{
    
    self = [super initBaseEventWithId:theId location:location date:date creator:creator shared:shared stored:stored post:post];
    
    if (self) {
        _eventItems = [[NSMutableArray alloc] init];
        _emotions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)eventItems{
    if (!_eventItems) {
        _eventItems = [[NSMutableArray alloc] init];
    }
    return _eventItems;
}

@end
