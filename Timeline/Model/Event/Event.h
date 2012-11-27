//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  Event.h
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEvent.h"

@interface Event : BaseEvent

@property (strong, nonatomic) NSMutableArray *eventItems;
@property (strong, nonatomic) NSMutableArray *emotions;

//The designated Initializer
- (id)initEventWithLocation:(CLLocation *)location date:(NSDate *)date shared:(BOOL)shared creator:(NSString *)creator;

- (id)initEventWithId:(NSString *)theId location:(CLLocation *)location date:(NSDate *)date creator:(NSString *)creator shared:(BOOL)shared stored:(BOOL)stored post:(BOOL)post;

@end
