//
//  Utility.h
//  Timeline
//
//  Created by Alessandro Boron on 15/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

//This method is used to get a MD5 representation of a string
+ (NSString *)MD5ForString:(NSString *)string;

+ (NSString *)dateTimeDescriptionWithLocaleIdentifier:(NSDate *)date;

@end
