//
//  SimpleRecording.m
//  Timeline
//
//  Created by Alessandro Boron on 06/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SimpleRecording.h"
#import "NSString+MD5.h"

@implementation SimpleRecording

@synthesize eventId = _eventId;
@synthesize urlPath = _urlPath;

//The designated initializer
- (id)initSimpleRecordingWithEventId:(NSString *)eventId URLPath:(NSString *)urlPath eventCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithHashedId:[[NSString stringWithFormat:@"%@%@",urlPath,eventCreator] MD5] creator:eventCreator];
    
    if (self) {
        if (eventId) {
            _eventId = eventId;
        }
        _urlPath = urlPath;
    }
    
    return self;
}

- (id)initSimpleRecordingWithEventItem:(EventItem *)eventItem url:(NSString *)urlPath{
    
    self = [super initEventItemWithId:eventItem.eventItemId eventId:eventItem.eventId creator:eventItem.creator];
    
    if (self) {
        
        _urlPath = urlPath;
    }
    
    return self;
}

@end
