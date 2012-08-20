//
//  XMPPRequestControllerDelegate.h
//  Timeline
//
//  Created by Alessandro Boron on 20/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Space;

@protocol XMPPRequestControllerDelegate <NSObject>

- (void)sendNote:(id)note toSpace:(Space *)space;

@end
