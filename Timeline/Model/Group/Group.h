//
//  Group.h
//  Timeline
//
//  Created by Alessandro Boron on 20/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *users;

//The designated initializer
- (id)initGroupWithName:(NSString *)name users:(NSArray *)users;

@end
