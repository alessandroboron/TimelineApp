//
//  TimelineViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"

@interface TimelineViewController : UIViewController <ModalViewControllerDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *eventsArray;
@property (strong, nonatomic) NSString *spaceId;
@end
