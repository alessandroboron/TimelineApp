//
//  EventItem.h
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventItem : NSObject

@property (strong, nonatomic) NSString *eventItemId;
@property (strong, nonatomic) NSString *creator;

//The designated initializer
- (id)initEventItemWithId:(NSString *)eventId creator:(NSString *)creator;

@end
