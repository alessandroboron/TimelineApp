//
//  Timeline.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "Timeline.h"
#import "NSString+MD5.h"

@implementation Timeline

@synthesize tId = _tId;
@synthesize title = _title;
@synthesize creator = _creator;
@synthesize baseEvents = _baseEvents;
@synthesize shared = _shared;

//The designated initializer
- (id)initTimelineWithTitle:(NSString *)title creator:(NSString *)creator shared:(BOOL)shared{
    
    self = [super init];
    
    if (self) {
        _tId = [Utility MD5ForString:[NSString stringWithFormat:@"%@%@%i",title,creator,shared]];
        _title = title;
        _creator = creator;
        _shared = shared;
    }
    
    return self;
}

//This method is used to return the string representation of the sharing attribute
- (NSString *)sharedDescription{
    
    if (self.shared)
        return @"Shared";
    else
        return @"Private";
}

@end
