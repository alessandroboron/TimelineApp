
//  Space.h
//  Timeline
//
//  Created by Alessandro Boron on 21/08/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SpaceTypeUnknown = 0,
    SpaceTypePrivate,
    SpaceTypeTeam,
    SpaceTypeOrganizational
}SpaceType;

@interface Space : NSObject

@property (strong, nonatomic) NSString *spaceId;
@property (strong ,nonatomic) NSString *spaceName;
@property (assign, nonatomic) SpaceType spaceType;
@property (assign, nonatomic) BOOL spacePersistence;
@property (strong, nonatomic) NSMutableArray *spaceUsers;
@property (assign, nonatomic) BOOL subscribed;

//The disagnated initializer
- (id)initSpaceWithId:(NSString *)spId name:(NSString *)spName type:(NSString *)spType persistence:(NSString *)spPersistence;

//This method is used to get a string representation of the space type
- (NSString *)spaceTypeString;

//Ths method is used to set the space type from a string value
- (SpaceType)spaceTypeFromStringValue:(NSString *)value;

//This method is used to check if a space is persistent from a string value
- (BOOL)isSpacePersistent:(NSString *)value;

@end
