//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
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
        _tId = [Utility MD5ForString:[NSString stringWithFormat:@"%@%@%i%@",title,creator,shared,[NSDate date]]];
        _title = title;
        _creator = creator;
        _baseEvents = [[NSMutableArray alloc] init];
        _shared = shared;
    }
    
    return self;
}

- (id)initTimelineWithId:(NSString *)timelineId title:(NSString *)title creator:(NSString *)creator shared:(BOOL)shared{
    
    self = [self initTimelineWithTitle:title creator:creator shared:shared];
    
    if (self) {
        _tId = timelineId;
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
