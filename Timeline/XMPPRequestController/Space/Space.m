//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  Space.m
//  TimelineApp
//
//  Created by Alessandro Boron on 21/08/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import "Space.h"

@implementation Space
@synthesize spaceId = _spaceId;
@synthesize spaceName = _spaceName;
@synthesize spaceType = _spaceType;
@synthesize spacePersistence = _spacePersistence;
@synthesize spaceUsers = _spaceUsers;
@synthesize subscribed = _subscribed;

//The designated initializer
- (id)initSpaceWithId:(NSString *)spId name:(NSString *)spName type:(NSString *)spType persistence:(NSString *)spPersistence{
    
    self = [super init];
    
    if (self) {
        _spaceId = spId;
        _spaceName = spName;
        _spaceType = [self spaceTypeFromStringValue:spType];
        _spacePersistence = [self isSpacePersistent:spPersistence];
        _spaceUsers = [[NSMutableArray alloc] init];
        _subscribed = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

//This method is used to get a string representation of the space type
- (NSString *)spaceTypeString{
    //Check the type of the space
    if (self.spaceType == SpaceTypeTeam) {
        return @"Team Space";
    }
    else if (self.spaceType == SpaceTypeOrganizational){
        return @"Organizational Space";
    }
    else if (self.spaceType == SpaceTypePrivate){
        return @"Private Space";
    }
    else{
        return nil;
    }
}

//Ths method is used to set the space type from a string value
- (SpaceType)spaceTypeFromStringValue:(NSString *)value{
    
    //Check the string value
    if ([value isEqualToString:@"team"]) {
        return SpaceTypeTeam;
    }
    else if ([value isEqualToString:@"orga"]) {
        return SpaceTypeOrganizational;
    }
    else if ([value isEqualToString:@"private"]){
        return SpaceTypePrivate;
    }
    else{
        return SpaceTypeUnknown;
    }
    
}

//This method is used to check if a space is persistent from a string value
- (BOOL)isSpacePersistent:(NSString *)value{
    
    //Check the string value
    if ([value isEqualToString:@"true"]) {
        return YES;
    }
    else{
        return NO;
    }
}

@end
