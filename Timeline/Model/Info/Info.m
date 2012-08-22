//  Info.m
//  WatchIt
//
//  Created by Alessandro Boron on 22/08/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import "Info.h"

static int uniqueID = 1;    //Class variables used to have a unique identifier for the information

//Private Methods
@interface Info ()   

//Used to check the type of the information
- (UIImage *)imageForType:(InfoMediaType)mediaType;

@end

@implementation Info

@synthesize identifier = _identifier;
@synthesize infoTimestamp = _infoTimestamp;
@synthesize infoLocation = _infoLocation;
@synthesize infoMediaType = _infoMediaType;

//The designated initializer
- (id)initInfoWithTitle:(NSString *)title location:(CLLocation *)location timestamp:(NSDate *)timestamp mediaType:(InfoMediaType)mediatype{
    
    self = [super init];
    
    if (self) {
        _infoLocation = location;
        _infoTimestamp = timestamp;
        _infoMediaType = mediatype;
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

//Method used to get the string representation of the information type.
- (NSString *)infoMediaTypeDescription{
    
    switch (_infoMediaType) {
        case InfoMediaTypeTweet:
            return @"Tweet";
            break;
            
        case InfoMediaTypeWatchit:
            return @"WatchIt";
            break;
        
        case InfoMediaTypePhoto:
            return @"Photo";
            break;
        
        case InfoMediaTypeVideo:
            return @"Video";
            break;
            
        default:
            return @"Unknown";
            break;
    }
    
}

#pragma mark -
#pragma mark Private Methods

//This method is used to retrieve the image to show in the landmark based on the type of info
- (UIImage *)imageForType:(InfoMediaType)mediaType{
    
    switch (mediaType) {
        case InfoMediaTypeTweet:
           return [UIImage imageNamed:@"tweetARSmall.png"];
            break;
            
        case InfoMediaTypeWatchit:
            return [UIImage imageNamed:@"wAR.png"];
            break;
            
        case InfoMediaTypePhoto:
            return [UIImage imageNamed:@"picture_map.png"];
            break;
            
        case InfoMediaTypeVideo:
            return [UIImage imageNamed:@"video_map.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

@end