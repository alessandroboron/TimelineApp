//
//  DismissModalViewControllerProtocol.h
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEvent.h"

@protocol ModalViewControllerDelegate <NSObject>
- (void)dismissModalViewController;
@optional
- (void)newTimeline:(id)sender;
- (void)addEventItem:(id)sender toBaseEvent:(BaseEvent *)baseEvent;
- (void)addGroup:(id)sender;
- (void)dismissModalViewControllerAndUpdate;
@end
