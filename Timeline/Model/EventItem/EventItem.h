//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
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
@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSString *creator;

- (id)initEventItemWithId:(NSString *)eventItemId eventId:(NSString *)eventId creator:(NSString *)creator;

//The designated initializer
- (id)initEventItemWithHashedId:(NSString *)eventId creator:(NSString *)creator;

@end
