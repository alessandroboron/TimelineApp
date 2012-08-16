//
//  BaseEvent.h
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BaseEvent : NSObject

@property (strong, nonatomic) NSString *baseEventId;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL shared;
@property (strong, nonatomic) NSString *creator;

//The designated initializer
- (id)initBaseEventWithLocation:(CLLocation *)location date:(NSDate *)date shared:(BOOL)shared creator:(NSString *)creator;

@end
