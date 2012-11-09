//
//  SimpleVideo.m
//  Timeline
//
//  Created by Alessandro Boron on 13/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SimpleVideo.h"
#import "NSString+MD5.h"

@implementation SimpleVideo

@synthesize eventId = _eventId;
@synthesize videoURL = _videoURL;
@synthesize videoThumbnail = _videoThumbnail;

//The designated initializer
- (id)initSimpleVideoWithEventId:(NSString *)eventId URL:(NSURL *)url eventItemCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithHashedId:[NSString stringWithFormat:@"%@%@%@",url,eventCreator,[NSDate date]] creator:eventCreator];
    
    if (self) {
        if (eventId) {
            _eventId = eventId;
        }
        _videoURL = url;
        _videoThumbnail = [Utility imageFromVideoURL:_videoURL];
    }
    
    return self;
}

- (id)initSimpleVideoWithEventItem:(EventItem *)eventItem url:(NSURL *)url{
    
    self = [super initEventItemWithId:eventItem.eventItemId eventId:eventItem.eventId creator:eventItem.creator];
    
    if (self) {
        
        _videoURL = url;
        _videoThumbnail = [Utility imageFromVideoURL:_videoURL];
    }
    
    return self;
}

@end
