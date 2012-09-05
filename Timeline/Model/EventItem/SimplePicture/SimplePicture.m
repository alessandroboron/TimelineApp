//
//  SimplePicture.m
//  Timeline
//
//  Created by Alessandro Boron on 04/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SimplePicture.h"

@implementation SimplePicture

@synthesize image = _image;

//The designated initializer
- (id)initSimplePictureWithImage:(UIImage *)image eventItemCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithId:[NSString stringWithFormat:@"%@",eventCreator] creator:eventCreator];
    if (self) {
        _image = image;
    }
    
    return self;
}

@end
