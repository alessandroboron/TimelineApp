//
//  Utility.h
//  Timeline
//
//  Created by Alessandro Boron on 15/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Space.h"

@class XMPPRequestController;


@interface Utility : NSObject

//This method is used to get a MD5 representation of a string
+ (NSString *)MD5ForString:(NSString *)string;

//This method is used to get the string representation of a date formatted in a certain way
+ (NSString *)dateTimeDescriptionWithLocaleIdentifier:(NSDate *)date;

//This method is used to get the string representation of a date formatted in a certain way
+ (NSString *)dateDescriptionForEventDetailsWithDate:(NSDate *)date;

//This method is used to get the string representation of a date formatted to be sent through XMPP
+ (NSString *)dateDescriptionForXMPPServerWithDate:(NSDate *)date;

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromTimestampString:(NSString *)timestamp;

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromTimestamp:(NSString *)timestamp watchIT:(BOOL)watchIt;

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromCroMARTimestampString:(NSString *)timestamp;

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

//This method is used to get the XMPPRequestController;
+ (XMPPRequestController *)xmppRequestController;

//Used to show the activity indicator on the screen
+ (void)showActivityIndicatorWithView:(UIView *)theView label:(NSString *)label;

//Used to hide the activity indicator on the screen
+ (void)dismissActivityIndicator:(UIView *)theView;

//This method is used to get the size of a string based on the font used
+ (CGSize)sizeOfText:(NSString *)text width:(float)width fontSize:(float)fontSize;

//This method is used to sort the event based on an attribute and order ascending/descending
+ (void)sortArray:(NSArray *)array withKey:(NSString *)key ascending:(BOOL)ascending;

//This method is used to get a base 64 string representation from a UIIMage
+ (NSString *)base64StringFromImage:(UIImage *)image;

//This methos is used to get an Image from its base64 string representation
+ (UIImage *)imageFromBase64String:(NSString *)base64String;

//This method is used to return an UIImagePickerController set up to choose a picture or video from library
+ (UIImagePickerController *)imagePickerControllerForLibraryWithDelegate:(id)delegate media:(NSString *)media;

//This method is used to return an UIImagePickerController set up to take pictures or video
+ (UIImagePickerController *)imagePickerControllerWithDelegate:(id)delegate media:(NSString *)media;

//This method is used to get a image with scaled and compressed size
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (NSString *)base64StringForAttachment:(id)attachment;


+ (UIImage *)imageFromVideoURL:(NSURL *)url;

//This method is used to get a string representation of the space type
+ (NSString *)timelineTypeString:(SpaceType)spaceType;

@end
