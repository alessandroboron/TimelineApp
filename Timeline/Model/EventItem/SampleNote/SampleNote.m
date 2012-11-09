//
//  SampleNote.m
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SampleNote.h"

@implementation SampleNote

@synthesize eventId = _eventId;
@synthesize noteTitle = _noteTitle;
@synthesize noteText = _noteText;

//The designated initializer
- (id)initSampleNoteWithEventId:(NSString *)eventId title:(NSString *)title text:(NSString *)text eventItemCreator:(NSString *)eventCreator{
        
    self = [super initEventItemWithHashedId:[NSString stringWithFormat:@"%@%@%@%@",title,text,eventCreator,[NSDate date]] creator:eventCreator];
    
    if (self) {
        if (eventId) {
            _eventId = eventId;
        }
        _noteTitle = title;
        _noteText = text;
    }
    
    return self;
}

- (id)initSampleNoteWithEventItem:(EventItem *)eventItem title:(NSString *)title text:(NSString *)text{
    
    self = [super initEventItemWithId:eventItem.eventItemId eventId:eventItem.eventId creator:eventItem.creator];
    
    if (self) {
       
        _noteTitle = title;
        _noteText = text;
    }
    
    return self;
}

@end
