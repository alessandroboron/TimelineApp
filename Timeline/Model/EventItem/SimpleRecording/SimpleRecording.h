//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  SimpleRecording.h
//  Timeline
//
//  Created by Alessandro Boron on 06/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventItem.h"

@interface SimpleRecording : EventItem

@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSString *urlPath;

//The designated initializer
- (id)initSimpleRecordingWithEventId:(NSString *)eventId URLPath:(NSString *)urlPath eventCreator:(NSString *)eventCreator;

- (id)initSimpleRecordingWithEventItem:(EventItem *)eventItem url:(NSString *)urlPath;

@end
