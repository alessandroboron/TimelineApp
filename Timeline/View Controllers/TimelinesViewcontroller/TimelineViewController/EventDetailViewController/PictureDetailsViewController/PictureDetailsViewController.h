//
//  PictureDetailsViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 05/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"

@interface PictureDetailsViewController : UIViewController

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;
@property (strong, nonatomic) UIImage *img;
@end
