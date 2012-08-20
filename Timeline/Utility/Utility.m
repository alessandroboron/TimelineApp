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


@end
