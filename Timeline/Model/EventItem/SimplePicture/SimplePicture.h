//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  SimplePicture.h
//  Timeline
//
//  Created by Alessandro Boron on 04/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventItem.h"

@interface SimplePicture : EventItem

@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imagePath;

//The designated initializer
- (id)initSimplePictureWithEventId:(NSString *)eventId imagePath:(NSString *)imagePath image:(UIImage *)image eventItemCreator:(NSString *)eventCreator;

- (id)initSimplePictureWithEventItem:(EventItem *)eventItem url:(NSString *)urlImgPath;

- (UIImage *)imageFromAssetURL;

@end
