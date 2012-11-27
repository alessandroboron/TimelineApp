//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  Utility.m
//  Timeline
//
//  Created by Alessandro Boron on 15/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"
#import "NSString+MD5.h"
#import "AppDelegate.h"
#import "XMPPRequestController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"
#import "Space.h"

@interface Utility ()

+ (BOOL)isDateFromPreviousVersionOfCroMAR:(NSString *)timestamp;

@end

@implementation Utility

//This method is used to get a MD5 representation of a string
+ (NSString *)MD5ForString:(NSString *)string{
    
    return [string MD5];
}

//This method is used to get the string rapresentation of a date formatted in a certain way
+ (NSString *)dateTimeDescriptionWithLocaleIdentifier:(NSDate *)date{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
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

+ (NSDate *)dateFromEventTimestampString:(NSString *)eventTimestampString{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Set the date format
    
    //Date Format "2010/06/25 11:54"
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    //Set the locale 'EN' for the date formatter
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    
    //Get the date object from a string date
    NSDate *date = [dateFormatter dateFromString:eventTimestampString];
    
    return date;    
}

//This method is used to get the string rapresentation of a date formatted in a certain way
+ (NSString *)dateDescriptionForEventDetailsWithDate:(NSDate *)date{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    
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

//This method is used to get the string representation of a date formatted to be sent through XMPP
+ (NSString *)dateDescriptionForXMPPServerWithDate:(NSDate *)date{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //Format "2012-08-21T12:56:48+00:00">
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZ"];
    
    //Get the local timezone
    NSTimeZone *localTimezone = [NSTimeZone localTimeZone];
    //Set the date formatter according to the local timezone
    [dateFormatter setTimeZone:localTimezone];
    
    //Set the locale 'EN' for the date formatter
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    
    //Convert the date object to a string. Date UTC Timezone -> String Local Timezone
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    NSArray *timestampComponent = [timeStamp componentsSeparatedByString:@" "];
    
    NSString *tStamp = [NSString stringWithFormat:@"%@T%@",[timestampComponent objectAtIndex:0],[timestampComponent objectAtIndex:1]];
    //Return the date string
    return tStamp;
}

+ (NSString *)normalizeDate:(NSString *)date watchIt:(BOOL)watchIt{
    
    //Split the string using the separator "."
    NSArray *splittedTimestamp = [date componentsSeparatedByString:@"T"];
    
    NSString *dateString;
    
    if (watchIt) {
       
        if (!splittedTimestamp || [splittedTimestamp count]==0 || [splittedTimestamp count]==1) {
            return date;
        }
        
        //Remove the timezone
        NSArray *splittedSeconds= [((NSString *)[splittedTimestamp objectAtIndex:1]) componentsSeparatedByString:@"."];

        
        if ([splittedSeconds count]>1) {
            NSArray *splittedTimezone = [((NSString *)[splittedTimestamp objectAtIndex:1]) componentsSeparatedByString:@"+"];
            
            //Add the +0000 Timezone
            dateString = [NSString stringWithFormat:@"%@ %@ +%@",[splittedTimestamp objectAtIndex:0],[splittedSeconds objectAtIndex:0],[splittedTimezone objectAtIndex:1]];
        }
        else{
            dateString = [NSString stringWithFormat:@"%@ %@",[splittedTimestamp objectAtIndex:0],[splittedTimestamp objectAtIndex:1]];
        }
        
        /*
        //Remove the milliseconds
        NSArray *splittedSeconds= [((NSString *)[splittedTimestamp objectAtIndex:1]) componentsSeparatedByString:@"."];
        
        NSArray *splittedTimezone = [((NSString *)[splittedSeconds objectAtIndex:1]) componentsSeparatedByString:@"+"];
        
        //Add the +ZZZZ Timezone
        dateString = [NSString stringWithFormat:@"%@ %@ +%@",[splittedTimestamp objectAtIndex:0],[splittedSeconds objectAtIndex:0],[splittedTimezone objectAtIndex:1]];
         */
    }
    else{
        NSArray *splittedTimezone = [((NSString *)[splittedTimestamp objectAtIndex:1]) componentsSeparatedByString:@"+"];
        
        //Add the +ZZZZ Timezone
        dateString = [NSString stringWithFormat:@"%@ %@ +%@",[splittedTimestamp objectAtIndex:0],[splittedTimezone objectAtIndex:0],[splittedTimezone objectAtIndex:1]];
    }
    
    //Return the new timestamp string
    return dateString;
}

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromTimestampString:(NSString *)timestamp{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Set the date format
    
    //Date Format "2010-06-25T11:54:17zzzz"
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    
    if (![self isDateFromPreviousVersionOfCroMAR:timestamp]) {
        //timestamp = [self normalizeDate:timestamp];
    }
    
    //Set the locale 'EN' for the date formatter
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
   
    //Get the date object from a string date
    NSDate *date = [dateFormatter dateFromString:timestamp];
    
    return date;
}

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromTimestamp:(NSString *)timestamp watchIT:(BOOL)watchIt{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Set the date format
    
    //Date Format "2010-06-25 11:54:17 ZZZZ"
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    
   
    timestamp = [self normalizeDate:timestamp watchIt:watchIt];
    
        
    //Set the locale 'EN' for the date formatter
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    
    //Get the date object from a string date
    NSDate *date = [dateFormatter dateFromString:timestamp];
    
    return date;
    
}

//This method is used to get a date object from a timestamp string
+ (NSDate *)dateFromCroMARTimestampString:(NSString *)timestamp{
    
    //Initialize the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Set the date format
    
    //Date Format "2010-06-25T11:54:17zzzz"
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    
    //Get the local timezone
    NSTimeZone *localTimezone = [NSTimeZone localTimeZone];
    //Set the date formatter according to the local timezone
    [dateFormatter setTimeZone:localTimezone];
    
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

//This method is used to get the Reachability object;
+ (Reachability *)reachability{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return delegate.reachability;
}

//This method is used to get the DBController object;
+ (DBController *)databaseController{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return delegate.dbController;
}

#pragma mark -
#pragma mark MBProgressHUD Methods

//Used to show the activity indicator on the screen
+ (void)showActivityIndicatorWithView:(UIView *)theView label:(NSString *)label{
    
    //Show the activity indicator on the screen with the label "Retrieving Info"
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:theView animated:YES];
    hud.labelText = label;
}

//Used to hide the activity indicator on the screen
+ (void)dismissActivityIndicator:(UIView *)theView{
    
    // Add at start of requestFinished AND requestFailed
    [MBProgressHUD hideHUDForView:theView animated:YES];
}

#pragma mark -
#pragma mark UITableView Utility Methods

//This method is used to get the size of a string based on the font used
+ (CGSize)sizeOfText:(NSString *)text width:(float)width fontSize:(float)fontSize{
    
    //Set the constraint where the text is put
    CGSize constraint = CGSizeMake(width, 20000.0f);
    
    //Compute the size of the text
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return size;
}

#pragma mark -
#pragma mark Private Methods

+ (BOOL)isDateFromPreviousVersionOfCroMAR:(NSString *)timestamp{
    
    BOOL ret = YES;
    
    NSArray *timestampComponents = [timestamp componentsSeparatedByString:@"T"];
    
    if ([timestampComponents count]) {
        ret = NO;
    }
    
    return ret;
}

//This method is used to sort the event based on an attribute and order ascending/descending
+ (void)sortArray:(NSMutableArray *)array withKey:(NSString *)key ascending:(BOOL)ascending{
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [array sortUsingDescriptors:sortDescriptors];
}

//This method is used to get a base 64 string representation from a UIIMage
+ (NSString *)base64StringFromImage:(UIImage *)image{
    
    //Get the png representation of the image
    NSData *data = UIImagePNGRepresentation(image);
    
    //Return the image in a base 64 string representation
    return [data base64EncodedString];
}

//This method is used to get a base 64 string representation from a UIIMage
+ (NSString *)base64StringForAttachment:(id)attachment{
    
    NSData *data = nil;
    
    //If it is a picture
    if ([attachment isMemberOfClass:[UIImage class]]) {
        //Get the png representation of the image
        data = UIImagePNGRepresentation(attachment);
    }
    //If it is a url path for a video or audio
    else if ([attachment isMemberOfClass:[NSString class]]){
       
        NSRange range = [((NSString *)attachment) rangeOfString:@".caf"];
        //If it is an audio
        if ((range.location != NSNotFound )&&range.length!=0) {
            data = [NSData dataWithContentsOfFile:attachment];
        }
    }
    
    //Return the image in a base 64 string representation
    return [data base64EncodedString];
}

//This methos is used to get an Image from its base64 string representation
+ (UIImage *)imageFromBase64String:(NSString *)base64String{
        
    //Get the data from the base 64 string
    NSData *data = [NSData dataFromBase64String:base64String];
    
    //Get the img from the nsdata
    UIImage *img = [UIImage imageWithData:data];
    
    return img;

}

//This method is used to return an UIImagePickerController set up to take pictures
+ (UIImagePickerController *)imagePickerControllerForTakingPictureWithDelegate:(id)delegate{
    
    UIImagePickerController *imagePicker=nil;
    
    //Check if the device is able to take picture
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //Initialize the UIImagePickerController
        imagePicker = [[UIImagePickerController alloc] init];
        //Set the delegate
        imagePicker.delegate = delegate;
        //Set the picker to use the camera
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //Set the picker to take only still pictures
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
        //Disable editing of pictures
        imagePicker.allowsEditing = NO;
        //Enable camera controls
        imagePicker.showsCameraControls = YES;
    }
    
    return imagePicker;
}

//This method is used to return an UIImagePickerController set up to take pictures
+ (UIImagePickerController *)imagePickerControllerWithDelegate:(id)delegate media:(NSString *)media{
    
    UIImagePickerController *imagePicker=nil;
    
    //Check if the device is able to take picture
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        //Initialize the UIImagePickerController
        imagePicker = [[UIImagePickerController alloc] init];
        //Set the delegate
        imagePicker.delegate = delegate;
        //Set the picker to use the camera
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //If the user wants to take still pictures
        if ([media isEqualToString:(NSString *)kUTTypeImage]){
            //Set the picker to take only still pictures
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
        }
        //If the user wants to take a video
        else if ([media isEqualToString:(NSString *)kUTTypeMovie]){
            //Set the picker to take only still pictures
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,nil];
           }
    }
    //Disable editing of pictures
    imagePicker.allowsEditing = NO;
    //Enable camera controls
    imagePicker.showsCameraControls = YES;
    
    return imagePicker;
}

//This method is used to return an UIImagePickerController set up to choose a picture or video from library
+ (UIImagePickerController *)imagePickerControllerForLibraryWithDelegate:(id)delegate media:(NSString *)media{
    
    UIImagePickerController *imagePicker = nil;
    
    //If the saved Photo album is available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        //Initialize the UIImagePickerController
        imagePicker = [[UIImagePickerController alloc] init];
        //Set the delegate
        imagePicker.delegate = delegate;
        //Set the picker to use the photo album
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //If the user wants to choose a picture
        if ([media isEqualToString:(NSString *)kUTTypeImage]) {
            //Set the picker to choose only from still images
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        }
        //If the user wants to choose a video
        else if ([media isEqualToString:(NSString *)kUTTypeMovie]){
            //Set the picker to choose only from still images
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeMovie, nil];
        }
        //Disable photo editing
        imagePicker.allowsEditing = NO;
    }
    
    return imagePicker;
}

//This method is used to get a image with scaled and compressed size
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (UIImage *)imageFromVideoURL:(NSURL *)url{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    //Set the right orientation for image thumbnail
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 1);
    
    UIImage *thumbnail = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL]];
    
    return thumbnail;
}



//This method is used to get a string representation of the space type
+ (NSString *)timelineTypeString:(SpaceType)spaceType{
    //Check the type of the space
    if (spaceType == SpaceTypeTeam) {
        return @"Team Space";
    }
    else if (spaceType == SpaceTypeOrganizational){
        return @"Organizational Space";
    }
    else if (spaceType == SpaceTypePrivate){
        return @"Private Space";
    }
    else{
        return @"Unknown";
    }
}
 
@end
