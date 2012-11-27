//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  NewEmotionViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 05/11/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"

@interface NewEmotionViewController : UIViewController

@property (strong, nonatomic) BaseEvent *baseEvent;
@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;

@end
