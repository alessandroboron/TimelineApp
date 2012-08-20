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

//This method is used to get the string rapresentation of a date formatted in a certain way
+ (NSString *)dateTimeDescriptionWithLocaleIdentifier:(NSDate *)date;

//This method is used to show an alert view with custom title, message and cancel button
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;

//This Method is used to get the setting default for key
+ (NSString *)settingField:(NSString *)setting;

//This method is used to check if app settings are filled out
+ (BOOL)isSettingStored;

//This method is used to check the connectivity of the xmpp server
+ (BOOL)isXMPPServerConnected;

//This method is used to check the authentication on the xmpp server
+ (BOOL)isUserAuthenticatedOnXMPPServer;

//This method is used to check if the device 
+ (BOOL)isHostReachable;

@end
