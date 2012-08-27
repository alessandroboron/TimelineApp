//
//  SharingViewControllerDelegate.h
//  Timeline
//
//  Created by Alessandro Boron on 27/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SharingViewControllerDelegate <NSObject>

- (void)shareEventToSpaceWithId:(NSString *)spaceId;

@end
