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

@synthesize videoURL = _videoURL;
@synthesize videoThumbnail = _videoThumbnail;

//The designated initializer
- (id)initSimpleVideoWithURL:(NSURL *)url eventItemCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithId:[[NSString stringWithFormat:@"%@%@",url,eventCreator] MD5] creator:eventCreator];
    
    if (self) {
        _videoURL = url;
        _videoThumbnail = [Utility imageFromVideoURL:_videoURL];
    }
    
    return self;
}

@end
