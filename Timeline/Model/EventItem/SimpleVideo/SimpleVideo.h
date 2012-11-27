//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
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

@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) UIImage *videoThumbnail;

//The designated initializer
- (id)initSimpleVideoWithEventId:(NSString *)eventId URL:(NSURL *)url eventItemCreator:(NSString *)eventCreator;

- (id)initSimpleVideoWithEventItem:(EventItem *)eventItem url:(NSURL *)url;

@end
