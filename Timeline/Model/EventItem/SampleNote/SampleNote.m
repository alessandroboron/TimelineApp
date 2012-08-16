//
//  SampleNote.m
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SampleNote.h"

@implementation SampleNote

@synthesize noteTitle = _noteTitle;
@synthesize noteText = _noteText;

//The designated initializer
- (id)initSampleNoteWithTitle:(NSString *)title text:(NSString *)text eventItemCreator:(NSString *)eventCreator;{
        
    self = [super initEventItemWithId:[NSString stringWithFormat:@"%@%@%@",title,text,eventCreator] creator:eventCreator];
    
    if (self) {
        _noteTitle = title;
        _noteText = text;
    }
    
    return self;
}

@end
