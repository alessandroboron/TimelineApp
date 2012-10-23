//
//  SimpleVideo.h
//  Timeline
//
//  Created by Alessandro Boron on 13/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventItem.h"

@interface SimpleVideo : EventItem

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) UIImage *videoThumbnail;

//The designated initializer
- (id)initSimpleVideoWithURL:(NSURL *)url eventItemCreator:(NSString *)eventCreator;

@end
