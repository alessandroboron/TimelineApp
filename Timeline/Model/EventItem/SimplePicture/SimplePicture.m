//
//  SimplePicture.m
//  Timeline
//
//  Created by Alessandro Boron on 04/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SimplePicture.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SimplePicture

@synthesize eventId = _eventId;
@synthesize imagePath = _imagePath;
@synthesize image = _image;

//The designated initializer
- (id)initSimplePictureWithEventId:(NSString *)eventId imagePath:(NSString *)imagePath image:(UIImage *)image eventItemCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithHashedId:[NSString stringWithFormat:@"%@%@%@",imagePath,eventCreator,[NSDate date]] creator:eventCreator];
    
    if (self) {
        if (eventId) {
            _eventId = eventId;    
        }
        _imagePath = imagePath;
        _image = image;
    }
    
    return self;
}

- (id)initSimplePictureWithEventItem:(EventItem *)eventItem url:(NSString *)urlImgPath{
    
    self = [super initEventItemWithId:eventItem.eventItemId eventId:eventItem.eventId creator:eventItem.creator];
    
    if (self) {
        _imagePath = urlImgPath;
        //_image = [self imageFromAssetURL];
    }
    
    return self;
}

- (UIImage *)imageFromAssetURL{
    
    __block UIImage *img = nil;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
           img =  [UIImage imageWithCGImage:[rep fullResolutionImage]  scale:[rep scale] orientation:0];
            
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Cant get image - %@",[myerror localizedDescription]);
    };
    
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:[NSURL URLWithString:self.imagePath]
                   resultBlock:resultblock
                  failureBlock:failureblock];
    
    return img;
}

@end
