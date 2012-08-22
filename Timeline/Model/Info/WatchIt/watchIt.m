//
//  Copyright 2011-2012 Alessandro Boron
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

//  watchIt.m
//  CroMAR
//
//  Created by Alessandro Boron on 7/25/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import "WatchIt.h"
#import "WatchItValue.h"

@implementation WatchIt
@synthesize watchItUser = _watchItUser;
@synthesize watchItValues = _watchItValues;

//The designated initializer
- (id)initWatchItDataWithUser:(NSString *)user values:(NSArray *)values timestamp:(NSDate *)timestamp infoTitle:(NSString *)title infoLocation:(CLLocation *)location infoTags:(NSArray *)tags infoMediaType:(InfoMediaType)mediatype infoRating:(NSInteger)rating{
    
   // self = [super initInfoWithTitle:title location:location timestamp:timestamp infoTemplate:nil mediaType:InfoMediaTypeWatchit roleType:nil tags:tags rating:0];
    
    if (self) {
        _watchItUser = user;
        _watchItValues = values;
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

//This methos is used to get a string representation of its Values
- (NSString *)stringValues{
    
    //Set the string that shows the info
    NSMutableString *valuesString = [[NSMutableString alloc] init];
    
    //Walk through the datastreams of the feed
    for (WatchItValue *value in self.watchItValues) {
        
        //Set the string that display the watchIt Values
        [valuesString appendFormat:@"Value Type: %@\nValue: %@ %@\n\n",value.valueType,value.value, value.unit];
    }
    
    return [valuesString copy];
}

@end
