//
//  Utility.m
//  Timeline
//
//  Created by Alessandro Boron on 15/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "Utility.h"
#import "NSString+MD5.h"

@implementation Utility

//This method is used to get a MD5 representation of a string
+ (NSString *)MD5ForString:(NSString *)string{
    
    return [string MD5];
}

+ (NSString *)dateTimeDescriptionWithLocaleIdentifier:(NSDate *)date{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"d/MM/yyyy HH:mm"];
    
    //Get the local timezone
    NSTimeZone *localTimezone = [NSTimeZone localTimeZone];
    //Set the date formatter according to the local timezone
    [dateFormatter setTimeZone:localTimezone];
    
    //Set the locale 'EN' for the date formatter
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    
    //Convert the date object to a string. Date UTC Timezone -> String Local Timezone
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    //Return the date string
    return timeStamp;
}

@end
