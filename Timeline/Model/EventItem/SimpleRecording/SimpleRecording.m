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

@synthesize urlPath = _urlPath;

//The designated initializer
- (id)initSimpleRecordingWithURLPath:(NSString *)urlPath eventCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithId:[[NSString stringWithFormat:@"%@%@",urlPath,eventCreator] MD5] creator:eventCreator];
    
    if (self) {
        _urlPath = urlPath;
    }
    
    return self;
}

@end
