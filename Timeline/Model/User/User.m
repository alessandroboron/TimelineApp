//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  User.m
//  Timeline
//
//  Created by Alessandro Boron on 20/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username = _username;

//The designated Initializer
- (id)initUserWithUsername:(NSString *)username{
    
    self = [super init];
    
    if (self) {
        
        _username = username;
    }
    
    return self;
}

@end
