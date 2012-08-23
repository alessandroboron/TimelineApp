//
//  XMPPRequestController.h
//  Timeline
//
//  Created by Alessandro Boron on 20/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPRequestControllerDelegate.h"

@class Space;

static int nodeIdRequestNumber=0;

@interface XMPPRequestController : NSObject <XMPPRequestControllerDelegate>

@property (nonatomic, strong) XMPPStream *xmppStream;

//Connection Methods

- (id)init;
- (BOOL)connect;
- (void)disconnect;
- (void)serviceAvailability;
- (void)inbandRegistration;


//Space Manager Methods
- (void)subscribeToNode:(NSString *)nodeId;
- (void)spacesListRequest;
- (void)spaceWithIdRequest:(NSString *)spaceId;
- (void)channelsForSpaceRequest:(NSString *)spaceId;
- (void)retrieveAllItemsForSpace:(NSString *)spaceId;

//Server status
- (BOOL)isXMPPServerConnected;
@end
