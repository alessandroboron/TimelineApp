//
//  NewNoteViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"
#import "BaseEvent.h"

@interface NewNoteViewController : UIViewController 

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;
@property (strong, nonatomic) BaseEvent *baseEvent;
@end
