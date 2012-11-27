//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  Timeline.h
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseEvent;

@interface Timeline : NSObject

@property (strong, nonatomic) NSString *tId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *creator;
@property (strong, nonatomic) NSMutableArray *baseEvents;
@property (assign, nonatomic) BOOL shared;

//The designated initializer
- (id)initTimelineWithTitle:(NSString *)title creator:(NSString *)creator shared:(BOOL)shared;

- (id)initTimelineWithId:(NSString *)timelineId title:(NSString *)title creator:(NSString *)creator shared:(BOOL)shared;

//This method is used to return the string representation of the sharing attribute
- (NSString *)sharedDescription;

@end
