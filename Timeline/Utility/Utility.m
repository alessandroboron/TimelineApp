//
//  Utility.m
//  Timeline
//
//  Created by Alessandro Boron on 15/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "Utility.h"
#import "NSString+MD5.h"
#import "AppDelegate.h"
#import "XMPPRequestController.h"
#import "Reachability.h"

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

+ (NSString *)normalizeDate:(NSString *)date{
    
    //Split the string using the separator "."
    NSArray *splittedTimestamp = [date componentsSeparatedByString:@"T"];
    
    //Remove the timezone
    NSArray *splittedSeconds= [((NSString *)[splittedTimestamp objectAtIndex:1]) componentsSeparatedByString:@"."];
    
    NSArray *splittedTimezone = [((NSString *)[splittedTimestamp objectAtIndex:1]) componentsSeparatedByString:@"+"];
    
    //Add the +0000 Timezone
    NSString *dateString = [NSString stringWithFormat:@"%@ %@ +%@",[splittedTimestamp objectAtIndex:0],[splittedSeconds objectAtIndex:0],[splittedTimezone objectAtIndex:1]];
    
    //Return the new timestamp string
    return dateString;
}

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromTimestampString:(NSString *)timestamp{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Set the date format
    
    //Pachube Date Format "2010-06-25T11:54:17.463771Z"
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    timestamp = [self normalizeDate:timestamp];
    
    //Set the locale 'EN' for the date formatter
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    //Get the date object from a string date
    NSDate *date = [dateFormatter dateFromString:timestamp];
    
    return date;
}

//This method is used to show an alert view with custom title, message and cancel button
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle{
    
    //Init the alert view
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    //Show the alert view
    [av show];
    
}

//This Method is used to get the setting default for key
+ (NSString *)settingField:(NSString *)setting{
    
    //Get the shared default object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:setting];
}

//This method is used to check if app settings are filled out
+ (BOOL)isSettingStored{
    
    BOOL filled = YES;
    
    if ([self settingField:kXMPPServerIdentifier] == nil) {
        return NO;
    }
    else if ([self settingField:kXMPPDomainIdentifier] == nil) {
        return NO;
    }
    else if ([self settingField:kXMPPUserIdentifier] == nil) {
        return NO;
    }
    else if ([self settingField:kXMPPPassIdentifier] == nil) {
        return NO;
    }
    
    return filled;
}

//This method is used to check the connectivity of the xmpp server
+ (BOOL)isXMPPServerConnected{
    
    BOOL connected = false;
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.xmppRequestController.xmppStream isConnected]) {
        connected = true;
    }
    
    return connected;
}

//This method is used to check the authentication on the xmpp server
+ (BOOL)isUserAuthenticatedOnXMPPServer{
    
    BOOL auth = false;
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.xmppRequestController.xmppStream isAuthenticated]) {
        auth = true;
    }
    
    return auth;
}

//This method is used to check if the device
+ (BOOL)isHostReachable{
    
    BOOL reachable = NO;
    
    Reachability *r = [Reachability reachabilityWithHostname:@"www.google.com"];
    NetworkStatus ns = [r currentReachabilityStatus];
    
    if (!(ns == NotReachable)) {
        reachable = YES;
    }
    
    return reachable;
}

//This method is used to get the XMPPRequestController;
+ (XMPPRequestController *)xmppRequestController{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return delegate.xmppRequestController;
}

@end
