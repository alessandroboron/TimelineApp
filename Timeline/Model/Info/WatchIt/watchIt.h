//  watchIt.h
//  Timeline
//
//  Created by Alessandro Boron on 22/08/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Info.h"

@interface WatchIt : Info

@property (nonatomic,strong) NSString *watchItUser;
@property (nonatomic,strong) NSArray *watchItValues;

//The designated initializer
- (id)initWatchItDataWithUser:(NSString *)user values:(NSArray *)values timestamp:(NSDate *)timestamp infoTitle:(NSString *)title infoLocation:(CLLocation *)location infoTags:(NSArray *)tags infoMediaType:(InfoMediaType)mediatype infoRating:(NSInteger)rating;

//This methos is used to get a string representation of its Values
- (NSString *)stringValues;

@end
