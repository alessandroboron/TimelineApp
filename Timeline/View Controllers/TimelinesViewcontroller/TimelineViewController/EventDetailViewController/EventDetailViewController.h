//
//  EventDetailViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 24/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"
#import "SharingViewControllerDelegate.h"

@class Event;

@interface EventDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,ModalViewControllerDelegate,SharingViewControllerDelegate>

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;
@property (strong, nonatomic) Event *event;
@end
