//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  ShareEventViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 27/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerDelegate.h"
#import "SharingViewControllerDelegate.h"

@interface ShareEventViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;
@property (weak, nonatomic) id<SharingViewControllerDelegate> sharingDelegate;
@end
