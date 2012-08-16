//
//  NewGroupViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"

@interface NewGroupViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;

@end
