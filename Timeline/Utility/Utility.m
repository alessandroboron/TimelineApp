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

//This method is used to get the string rapresentation of a date formatted in a certain way
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

//This method is used to show an alert view with custom title, message and cancel button
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle{
    
    //Init the alert view
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    //Show the alert view
    [av show];
    
}

@end
