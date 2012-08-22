//  Info.h
//  WatchIt
//
//  Created by Alessandro Boron on 22/08/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EventItem.h"

typedef enum {
    InfoMediaTypeUnknown = 0,
    InfoMediaTypeTweet,            // Information is a textual message
    InfoMediaTypePhoto,            // Information is a picture
    InfoMediaTypeVideo,            // Information is a video
    InfoMediaTypeAudio,            // Information is an audio
    InfoMediaTypeWatchit,          // Information from WatchIt
    InfoMediaTypeRecommendation
} InfoMediaType;

@interface Info : EventItem

@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSDate *infoTimestamp;
@property (strong, nonatomic) CLLocation *infoLocation;
@property (assign, nonatomic) InfoMediaType infoMediaType;

//The designated initializer
- (id)initInfoWithTitle:(NSString *)title location:(CLLocation *)location timestamp:(NSDate *)timestamp mediaType:(InfoMediaType)mediatype;

- (NSString *)infoMediaTypeDescription;

@end
