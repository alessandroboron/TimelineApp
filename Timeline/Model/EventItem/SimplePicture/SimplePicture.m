//
//  SimplePicture.m
//  Timeline
//
//  Created by Alessandro Boron on 04/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SimplePicture.h"

@implementation SimplePicture

@synthesize eventId = _eventId;
@synthesize image = _image;
#warning add UrlPath for DB

//The designated initializer
- (id)initSimplePictureWithEventId:(NSString *)eventId image:(UIImage *)image eventItemCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithHashedId:[NSString stringWithFormat:@"%@",eventCreator] creator:eventCreator];
    
    if (self) {
        if (eventId) {
            _eventId = eventId;    
        }
        _image = image;
    }
    
    return self;
}

- (id)initSimplePictureWithEventItem:(EventItem *)eventItem url:(NSString *)urlImgPath{
    
    self = [super initEventItemWithId:eventItem.eventItemId eventId:eventItem.eventId creator:eventItem.creator];
    
    if (self) {
        
        _image = nil;
    }
    
    return self;
}

@end
