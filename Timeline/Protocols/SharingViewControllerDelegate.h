//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
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
