//
//  XMPPRequestController.m
//  Timeline
//
//  Created by Alessandro Boron on 20/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "XMPPRequestController.h"
#import "Space.h"
//#import "XMPPPubSub.h"
#import "User.h"
#import "SampleNote.h"
#import "SimplePicture.h"
#import "SimpleRecording.h"
#import "Event.h"
#import "DBController.h"

#define kXMPPResourceIdentifier @"TimelineAPP"
#define kXMPPPortIdentifier     5222



#define kMirorDomain     @"mirror-demo.eu"
#define kMirrorHost      @"mirror-demo.eu"
#define kLocalDomain     @"sandbox"
#define kLocalHost       @"sandbox.idi.ntnu.no"

#define kMirrorUser      @"CroMARNTNU"
#define kLocalUser       @"cromar"
#define kPassword        @"giraffa"

#define kSpaceListId                @"spaceList1"
#define kSpaceListRequest           @"http://jabber.org/protocol/disco#items"

#define kSpaceInfoWithId            @"spaceId1"
#define kSpaceInfoWithIdRequest     @"http://jabber.org/protocol/disco#info"

#define kPubsubPublishIdentifier    @"publish1"
#define kPubsubSubscriberIdentifier @"subscribe1"
#define kPubsubSubscriptionIdentifier @"subscription1"
#define kPubsubAllItemsIdentifier   @"allitems1"
#define kPubsubRequest              @"http://jabber.org/protocol/pubsub"

#define kPubsubNodeIdentifier @"spaces#"


#define kXMLNSRegister          @"jabber:iq:register"

#define kIdServiceAvailability  @"info1"
#define kIdRegister             @"reg1"
#define kIdUnregister           @"unreg1"

#define kRequiredParameters     @"requiredInfo1"

#define kChannelsId             @"channels1"
#define kChannelsRequest        @"urn:xmpp:spaces"
#define kChannelsListId         @"channelsList1"

#define kPubsubHost             @"pubsub.sandbox"



#define kSpacesMirrorHost       @"spaces.mirror-demo.eu"
#define kSpacesLocalHost        @"spaces.sandbox"


@interface XMPPRequestController ()

@property (nonatomic,retain) NSString *xmppHost;
@property (nonatomic,retain) NSString *xmppDomain;
@property (nonatomic,retain) NSString *xmppUser;
@property (nonatomic,retain) NSString *xmppPassword;
@property (nonatomic,retain) NSString *xmppSpacesHost;
@property (nonatomic,retain) NSString *xmppPubsubHost;
@property (nonatomic,retain) NSMutableArray *spacesArray;

- (void)goOnline;
- (void)goOffline;

- (void)requiredParametersForInbandRegistration;
- (void)makeSpacesList:(XMPPIQ *)iq;
- (void)setNodeInfo:(XMPPIQ *)iq;
- (void)subscribtionForNode:(NSString *)nodeId;
- (void)retrieveAllItemsInSpaceWithIQ:(XMPPIQ *)iq;
- (void)retrieveAllItemsInSpace:(NSString *)nodeId subId:(NSString *)subid;
- (NSString *)subscriptionIdForIQ:(XMPPIQ *)iq;
- (void)initSpaceDataWithIQ:(XMPPIQ *)iq;


- (void)parseSensorDataFromWatchIt:(NSXMLElement *)item node:(NSString *)node update:(BOOL)update;
- (void)parseRecommendationFromCroMAR:(NSXMLElement *)item node:(NSString *)node update:(BOOL)update;
- (void)parseEventItemFromTimelineApp:(NSXMLElement *)item node:(NSString *)node update:(BOOL)update;

@end

@implementation XMPPRequestController

@synthesize xmppStream = _xmppStream;
@synthesize xmppHost = _xmppHost;
@synthesize xmppDomain = _xmppDomain;
@synthesize xmppUser = _xmppUser;
@synthesize xmppPassword = _xmppPassword;
@synthesize xmppSpacesHost = _xmppSpacesHost;
@synthesize xmppPubsubHost = _xmppPubsubHost;
@synthesize spacesArray = _spacesArray;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Public Methods

- (id)init{
    
    self = [super init];
    
    if (self) {
        
        //Set up the xmpp stream
        self.xmppStream = [[XMPPStream alloc] init];
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //Set the xmpp connection parameters
        _xmppHost = [Utility settingField:kXMPPServerIdentifier];
        _xmppDomain = [Utility settingField:kXMPPDomainIdentifier];
        _xmppUser = [Utility settingField:kXMPPUserIdentifier];
        _xmppPassword = [Utility settingField:kXMPPPassIdentifier];
        _xmppSpacesHost = [NSString stringWithFormat:@"spaces.%@",self.xmppDomain];
        _xmppPubsubHost = [NSString stringWithFormat:@"pubsub.%@",self.xmppDomain];
        
        //Register itself as observer in order to set connection parameters when the change
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:@"XMPPSettingsDidChangeNotification" object:nil];
        
    }
    
    return self;
}

- (NSMutableArray *)spacesArray{
    if (!_spacesArray) {
        _spacesArray = [[NSMutableArray alloc] init];
    }
    return _spacesArray;
}

//This method is used to connect to the XMPP server
- (BOOL)connect{
    
    //Check if a connection is already established
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    
    //Set myJID property for the stream
    XMPPJID *jID = [XMPPJID jidWithUser:self.xmppUser domain:self.xmppDomain resource:kXMPPResourceIdentifier];
    self.xmppStream.myJID = jID;
    self.xmppStream.hostName = self.xmppHost;
    self.xmppStream.hostPort = kXMPPPortIdentifier;

    //Establish the connection
    NSError *error = nil;
    
    if (![self.xmppStream connect:&error]) {
        NSLog(@"Error during the connection to the XMPP Server: %@",error);
        return NO;
    }
    
    return YES;
}

//This method is used to disconnect from the XMPP server
- (void)disconnect{
    [self goOffline];
    [self.xmppStream disconnect];
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}
- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

/*
//This method is used to check the availability of the service by using the service discovery
- (void)serviceAvailability{
 
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:@"mirror-demo.eu"] elementID:kIdServiceAvailability child:[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"]];
    
    [self.xmppStream sendElement:iq];
    
}

//This method is used to perform the in-band registration on the server
- (void)inbandRegistration{

    NSError *err = nil;
    [self.xmppStream registerWithPassword:kPassword error:&err];
}
*/

//This method is used to subscribe to a node
- (void)subscribeToNode:(NSString *)nodeId{
    
    //[self subscribtionForNode:nodeId];
    
    NSXMLElement *subscribe = [NSXMLElement elementWithName:@"subscribe"];
    [subscribe addAttributeWithName:@"node" stringValue:[NSString stringWithFormat:@"%@%@",kPubsubNodeIdentifier,nodeId]];
    [subscribe addAttributeWithName:@"jid" stringValue:[self.xmppStream.myJID full]];
    
    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub" xmlns:kPubsubRequest];
    [pubsub addChild:subscribe];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:self.xmppPubsubHost] elementID:kPubsubSubscriberIdentifier child:pubsub];
    
    
    NSLog(@"SUB IQ: %@",[iq description]);
    
    [self.xmppStream sendElement:iq];
     
}

#pragma mark Space Manager Methods


//This method is used to retrieve all the spaces for the user 
- (void)spacesListRequest{
    
    //Set the XML IQ Request
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:self.xmppSpacesHost] elementID:kSpaceListId child:[NSXMLElement elementWithName:@"query" xmlns:kSpaceListRequest]];
    
    NSLog(@"Space List Request: %@",[iq description]);
    //Send the Request
    [self.xmppStream sendElement:iq];
}

//This method is user to retrieve a space according to its identifier
- (void)spaceWithIdRequest:(NSString *)spaceId{
    
    nodeIdRequestNumber++;
    
    //Set the child for the IQ element
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:kSpaceInfoWithIdRequest];
    [query addAttributeWithName:@"node" stringValue:spaceId];

    
    //Set the XML IQ Request
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:self.xmppSpacesHost] elementID:kSpaceInfoWithId child:query];
    
    NSLog(@"SPACE INFO REQUEST: %@",[iq description]);
    
    //Send the Request
    [self.xmppStream sendElement:iq];

}

//This method is used to retrieve all the channels for a certain space
- (void)channelsForSpaceRequest:(NSString *)spaceId{
    
    NSXMLElement *spaces = [NSXMLElement elementWithName:@"spaces" xmlns:kChannelsRequest];
    
    NSXMLElement *channels = [NSXMLElement elementWithName:@"channels"];
    [channels addAttributeWithName:@"space" stringValue:kPubsubNodeIdentifier];
    
    [spaces addChild:channels];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:kSpacesLocalHost] elementID:kChannelsId child:spaces];
    
    [self.xmppStream sendElement:iq];
}

//This method is used to retrieve all the items belonging to a space
- (void)retrieveAllItemsForSpace:(NSString *)spaceId{
    //Get the subscription for the node in order to get the subid
    [self subscribtionForNode:spaceId];
}


//This method is used to send an event(eventItem) to the XMPP stream
- (void)sendEventItem:(id)eventItem toSpaceWithId:(NSString *)spaceId{
    
    Event *event = (Event *)eventItem;
    
    //Set the XML stanza
    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub" xmlns:kPubsubRequest];
    
    NSXMLElement *publish = [NSXMLElement elementWithName:@"publish"];
    [publish addAttributeWithName:@"node" stringValue:[NSString stringWithFormat:@"%@%@",kPubsubNodeIdentifier,spaceId]];
    
    [pubsub addChild:publish];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    
    NSXMLElement *eventXML = [NSXMLElement elementWithName:@"eventItem"];
    [eventXML addAttributeWithName:@"xmlns" stringValue:@"mirror:application:timeline:item"];
    [eventXML addAttributeWithName:@"xmlns:cdt" stringValue:@"mirror:common:datatypes"];
    [eventXML addAttributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"];
    [eventXML addAttributeWithName:@"xsi:schemaLocation" stringValue:@"mirror:application:timeline:item http://data.mirror-demo.eu/application/timeline/item-0.1.xsd"];
    [eventXML addAttributeWithName:@"modelVersion" stringValue:@"0.1"];
    [eventXML addAttributeWithName:@"cdmVersion" stringValue:@"1.0"];
    [eventXML addAttributeWithName:@"publisher" stringValue:[self.xmppStream.myJID full]];
    
    [item addChild:eventXML];
    
    [publish addChild:item];
    
    NSXMLElement *creationInfo = [NSXMLElement elementWithName:@"creationInfo"];
    NSXMLElement *cdtId = [NSXMLElement elementWithName:@"cdt:id" stringValue:event.baseEventId];
    
    NSXMLElement *cdtDate = [NSXMLElement elementWithName:@"cdt:date" stringValue:[Utility dateDescriptionForXMPPServerWithDate:event.date]];
   // NSXMLElement *cdtPerson = [NSXMLElement elementWithName:@"cdt:person" stringValue:[NSString stringWithFormat:@"%@@%@",self.xmppUser,self.xmppDomain]];
    NSXMLElement *cdtPerson = [NSXMLElement elementWithName:@"cdt:person" stringValue:[NSString stringWithFormat:@"%@",self.xmppUser]];
    
    [creationInfo addChild:cdtId];
    [creationInfo addChild:cdtDate];
    [creationInfo addChild:cdtPerson];
    
    [eventXML addChild:creationInfo];
    
    NSXMLElement *subject = nil;
    NSXMLElement *body = nil;
    NSXMLElement *location = nil;
    NSXMLElement *attachment = nil;
   
    //If the event is a note
    if ([[event.eventItems objectAtIndex:0] isMemberOfClass:[SampleNote class]]){
        //Set subject and body
        subject = [NSXMLElement elementWithName:@"subject" stringValue:((SampleNote *)[event.eventItems objectAtIndex:0]).noteTitle];
        body = [NSXMLElement elementWithName:@"body" stringValue:((SampleNote *)[event.eventItems objectAtIndex:0]).noteText];
    }
    else{
        subject = [NSXMLElement elementWithName:@"subject"];
        body = [NSXMLElement elementWithName:@"body"];
    }
    
    location = [NSXMLElement elementWithName:@"location"];
    [location addAttributeWithName:@"latitude" stringValue:[NSString stringWithFormat:@"%f",event.location.coordinate.latitude]];
    [location addAttributeWithName:@"longitude" stringValue:[NSString stringWithFormat:@"%f",event.location.coordinate.longitude]];
    attachment = [NSXMLElement elementWithName:@"attachment"];
     NSXMLElement *content = [NSXMLElement elementWithName:@"content"];
    
    //If it is a picture
    if ([[event.eventItems objectAtIndex:0] isMemberOfClass:[SimplePicture class]]){
        [attachment addAttributeWithName:@"type" stringValue:@"photo"];
        [content addAttributeWithName:@"mimeType" stringValue:@"image/png"];
        [content setStringValue:[Utility base64StringFromImage:((SimplePicture *)[event.eventItems objectAtIndex:0]).image]];
    }
   
    //If it is an audio
    if ([[event.eventItems objectAtIndex:0] isMemberOfClass:[SimpleRecording class]]){
        [attachment addAttributeWithName:@"type" stringValue:@"audio"];
        [content addAttributeWithName:@"mimeType" stringValue:@"audio/x-caf"];
        [content setStringValue:[Utility base64StringForAttachment:((SimpleRecording *)[event.eventItems objectAtIndex:0]).urlPath]];
    }
   
    [attachment addChild:content];

    [eventXML addChild:subject];
    [eventXML addChild:body];
    [eventXML addChild:location];
    [eventXML addChild:attachment];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:kPubsubHost] elementID:kPubsubPublishIdentifier child:pubsub];
    
    NSLog(@"IQ PUBSUB: %@",[iq description]);
    
    //Send the IQ Stanza to the stream
    [self.xmppStream sendElement:iq];
}

#pragma mark -
#pragma mark Private Methods

//This method is used in case the in-band registration requires more parameter
- (void)requiredParametersForInbandRegistration{
    
     //
     //   <iq type='get' id='reg1' to='shakespeare.lit'>
     //       <query xmlns='jabber:iq:register'/>
     //   </iq>
     //
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:kLocalHost] elementID:kRequiredParameters child:[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"]];
    
    [self.xmppStream sendElement:iq];
}

//This method is used to return the list of all the spaces for the user
- (void)makeSpacesList:(XMPPIQ *)iq{

    //Get the 'query' element 
    NSXMLElement *spacesListQuery = [iq elementForName:@"query"];
    
    //Get the 'item' elements child of 'query'
    NSArray *spaceListItems = [spacesListQuery elementsForName:@"item"];
    
    //Walk through the items
    for (NSXMLElement *element in spaceListItems) {
        //Get the id of the node
        NSString *nodeId = [element attributeStringValueForName:@"node"];
        //Get the name of the node
        NSString *nodeName = [element attributeStringValueForName:@"name"];
        
        //Create the space
        Space *sp = [[Space alloc] initSpaceWithId:nodeId name:nodeName type:@"" persistence:nil];
        //Store the space in the array
        [self.spacesArray  addObject:sp];
        
    }
    
    if ([self.spacesArray count]>0) {
        //Set the user info dictionary to send with the notification
        NSDictionary *userInfoDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.spacesArray,@"userInfo", nil];
        
        //Send the space array to the spacepopovercontroller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpaceListDidUpdateNotification" object:nil userInfo:userInfoDictionary];
       
        /*
        //Walk-through the spaces
        for (Space *sp in self.spacesArray) {
            //Get the additional info for the space
            [self spaceWithIdRequest:sp.spaceId];
        }
         */
        
    }
    self.spacesArray = nil;
}

//This method is used to retrieve the info for all the nodes
- (void)setNodeInfo:(XMPPIQ *)iq{
    
    //Get the 'query' element 
    NSXMLElement *spacesListQuery = [iq elementForName:@"query"];
    NSString *nodeId = [spacesListQuery attributeStringValueForName:@"node"];
    
    NSXMLElement *spacesIdentity = [spacesListQuery elementForName:@"identity"];
    NSString *nodeName = [spacesIdentity attributeStringValueForName:@"name"];
    
    NSString *nodeType = nil;
    NSString *nodePersistence = nil;
    
    //Get the 'x' element
    NSXMLElement *spacesXElement = [spacesListQuery elementForName:@"x"];
    
    //Get the 'item' elements child of 'query'
    NSArray *field = [spacesXElement elementsForName:@"field"];
    
    //The array where storing the members of the group
    NSArray *values = nil;
    
    //Walk through the fields
    for (NSXMLElement *element in field) {
        //Get the attribute value
        NSString *attributeValue = [element attributeStringValueForName:@"var"];
        //Get the value for the child
        NSString *childValue = [[element elementForName:@"value"] stringValue]; 
        //If the attribute is the node type
        if ([attributeValue isEqualToString:@"spaces#type"]) {
            nodeType = childValue;
        }
        //If the attribute is the node persistence
        else if ([attributeValue isEqualToString:@"spaces#persistent"]) {
            nodePersistence = childValue;
        }
        //If the attribute is the list of users for that space
        else if ([attributeValue isEqualToString:@"spaces#members"]) {
            //Get the 'value' elements child of 'field'
            values = [element elementsForName:@"value"];
        }
    }
   
    //Set the space
    Space *sp = [[Space alloc] initSpaceWithId:nodeId name:nodeName type:nodeType persistence:nodePersistence];
    
    //Set the users for the space
    for (NSXMLElement *member in values) {
        [sp.spaceUsers addObject:[[User alloc]initUserWithUsername:[member stringValue]]];
    }
   
    //Decrease the request number
    NSNumber *reqNumber = [NSNumber numberWithInt:nodeIdRequestNumber--];
    
    //Set the dictionary with the space
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:sp,@"userInfo",reqNumber,@"requestNumber", nil];
    
    //Send the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpacesDidUpdateNotification" object:nil userInfo:userInfo];
}

//This method is used to request the subscription for a node to the xmpp server
- (void)subscribtionForNode:(NSString *)nodeId{
    
    
     //   <iq type="get" to="pubsub.sandbox" id="subscription1">
     //       <pubsub xmlns="http://jabber.org/protocol/pubsub">
     //           <subscriptions node="spaces#team#3"></subscriptions>
     //       </pubsub>
     //   </iq>
     
    
	XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:self.xmppPubsubHost]  elementID:kPubsubSubscriptionIdentifier];
	
    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub" xmlns:kPubsubRequest];
	NSXMLElement *subscriptions = [NSXMLElement elementWithName:@"subscriptions"];
    [subscriptions addAttributeWithName:@"node" stringValue:[NSString stringWithFormat:@"%@%@",kPubsubNodeIdentifier,nodeId]];
    
    // join them all together
	[pubsub addChild:subscriptions];
	[iq addChild:pubsub];
    
    NSLog(@"IQ: %@",[iq description]);
    
	[self.xmppStream sendElement:iq];

}

//This method is used to parse the subscription request and check for it
- (NSString *)subscriptionIdForIQ:(XMPPIQ *)iq{
    
    NSXMLElement *pubsub = [iq elementForName:@"pubsub"];
    
    NSXMLElement *subscriptions = [pubsub elementForName:@"subscriptions"];
    
    NSArray *subscriptionArray = [subscriptions elementsForName:@"subscription"];
    
    NSXMLElement *subscription = [subscriptionArray objectAtIndex:0];
    
    NSString *subid = [subscription attributeStringValueForName:@"subid"];
    
    return subid;
}

- (void)retrieveAllItemsInSpaceWithIQ:(XMPPIQ *)iq{
    
    NSXMLElement *pubsub = [iq elementForName:@"pubsub"];
    
    NSXMLElement *subscriptions = [pubsub elementForName:@"subscriptions"];
    
    NSString *node = [subscriptions attributeStringValueForName:@"node"];
    
    NSXMLElement *subscription = [subscriptions elementForName:@"subscription"];
    
    NSString *subid = [subscription attributeStringValueForName:@"subid"];
    
    [self retrieveAllItemsInSpace:node subId:(NSString *)subid];
}

- (void)retrieveAllItemsInSpace:(NSString *)nodeId subId:(NSString *)subid{
    
    //<iq from="alice@wonderland.lit/rabbithole" to="notify.wonderland.lit"id="vru42mn" type="get"> 
    //  <pubsub xmlns="http://jabber.org/protocol/pubsub">
    //      <items node="queenly_proclamations" /> 
    //  </pubsub>
    //</iq>
    
    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub" xmlns:kPubsubRequest];
    NSXMLElement *items = [NSXMLElement elementWithName:@"items"];
    [items addAttributeWithName:@"node" stringValue:nodeId];
    [items addAttributeWithName:@"subid" stringValue:subid];
    [pubsub addChild:items];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:self.xmppPubsubHost] elementID:kPubsubAllItemsIdentifier child:pubsub];
    
    NSLog(@"IQ: %@",[iq description]);
    
    [self.xmppStream sendElement:iq];
}

//This method is used to build the Data to send to the PARController
- (void)initSpaceDataWithIQ:(XMPPIQ *)iq{
    
    //Get the pubsub element
    NSXMLElement *pubsub = [iq elementForName:@"pubsub"];
    
    //Get the items element
    NSXMLElement *items = [pubsub elementForName:@"items"];
    
    //Get all the item element of items
    NSArray *itemArray = [items elementsForName:@"item"];
    
    BOOL infoPresent = NO;
    
    if ([itemArray count]>0) {
        
  //      NSString *eventDate;
  //      NSString *eventCreator;
  //      NSString *eventLatitude;
  //      NSString *eventLongitude;
  //      SampleNote *sn = nil;
        
        //Walk-through the items
        for (NSXMLElement *item in itemArray) {
            
            //Get the name of the element
            NSString *itemName = [[[item children] objectAtIndex:0] name];
            
            //If it is 'genericSensorData' == WatchIt
            if ([itemName isEqualToString:@"genericSensorData"]) {
                
                infoPresent = YES;
                
                //Parse generic sensor data
                [self parseSensorDataFromWatchIt:item node:nil update:NO];
            }
           
            //If the information is a recommendation from CroMAR
            else if ([itemName isEqualToString:@"recommendation"]){
                infoPresent = YES;
                
                //Parse recommendation data
                [self parseRecommendationFromCroMAR:item node:nil update:NO];
            }
            
            //If the information comes from the timelineApp
            else if ([itemName isEqualToString:@"eventItem"]){
                infoPresent = YES;
            
                //Parse eventItem data
                [self parseEventItemFromTimelineApp:item node:nil update:NO];
            }
        }
        if (!infoPresent) {
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Datatype not recognized by TimelineApp." cancelButtonTitle:@"Dismiss"];
        }
    }
    else{
        [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"No information present in the selected space." cancelButtonTitle:@"Dismiss"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissActivityIndicatorNotification" object:nil];
}

//This method is used to set a value object
- (NSString *)valueFromXMLElement:(DDXMLElement *)value{
    
    //Get the type
  //  NSString *valueType = [value attributeStringValueForName:@"type"];
    //Get the unit
 //   NSString *valueUnit = [value attributeStringValueForName:@"unit"];
    //Get the value
    NSString *valueString = [value stringValue];
#warning put unit in case WatchIt defines it
    return [NSString stringWithFormat:@"%@",valueString];
}

//This method is used to parse a WatchIt Data
- (void)parseSensorDataFromWatchIt:(NSXMLElement *)item node:(NSString *)node update:(BOOL)update{
    
    //Get the genericSensorData element
    NSXMLElement *data = [item elementForName:@"genericSensorData"];
    
    //Get the timestamp
    // NSString *timestamp = [data attributeStringValueForName:@"timestamp"];
    NSString *eventDate = [data attributeStringValueForName:@"timestamp"];
    
    //Get the publisher of the data
    NSString *eventCreator = [[[data attributeStringValueForName:@"publisher"] componentsSeparatedByString:@"/"] objectAtIndex:0];
    
    //Get the location element
    NSXMLElement *location = [data elementForName:@"location"];
    
    //Get the latitude string
    NSString *eventLatitude = [location attributeStringValueForName:@"latitude"];
    //Get the longitude string
    NSString *eventLongitude = [location attributeStringValueForName:@"longitude"];
    
    //Get the name of its child
    NSString *valueName = [[[data children] objectAtIndex:1] name];
    
    NSString *valuesString;
    
    //If it is value (1 element)
    if ([valueName isEqualToString:@"value"]) {
        //Get the 'value' element
        NSXMLElement *value = [data elementForName:@"value"];
        
        //Get the value
        valuesString = [self valueFromXMLElement:value];
    }
    
    //If it is values (>1 elements)
    else if ([valueName isEqualToString:@"values"]){
        //Get the 'value' children
        NSArray *valuesElement = [data elementsForName:@"value"];
        
        //Walk through the elements
        for (NSXMLElement *value in valuesElement) {
            
            //Get the value
            valuesString = [self valueFromXMLElement:value];
            valuesString = [NSString stringWithFormat:@"%@-",valuesString];
        }
    }
    
    //Init the location
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[eventLatitude doubleValue] longitude:[eventLongitude doubleValue]];
    
    //New BaseEvent
    Event *event = [[Event alloc] initEventWithLocation:loc date:[Utility dateFromTimestamp:eventDate watchIT:YES] shared:NO creator:eventCreator];
    
    //Init the note
   // SampleNote *sn = [[SampleNote alloc] initSampleNoteWithTitle:@"WatchIt" text:valuesString eventItemCreator:eventCreator];
    
    SampleNote *sn = [[SampleNote alloc] initSampleNoteWithEventId:event.baseEventId title:@"WATCHiT" text:valuesString eventItemCreator:eventCreator];
    
    //Add the object to the base event
    [event.eventItems addObject:sn];
    
    //Send the data
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:event,@"userInfo",node,@"nodeId", nil];
    
    //If retrieving all the data from a space
    if (!update) {
        //Send the data
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventDidLoadNotification" object:nil userInfo:userInfo];
    }
    //If the app received a real-time notification from another app
    else{
        //Send the data and update the timeline
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTimelineNotification" object:nil userInfo:userInfo];
    }
    
    
}

//This method is used to parse a Recommendation from CroMAR
- (void)parseRecommendationFromCroMAR:(NSXMLElement *)item node:(NSString *)node update:(BOOL)update{
    
    //Get the recommendation element
    NSXMLElement *recommendation = [item elementForName:@"recommendation"];
    
    NSXMLElement *creationInfo = [recommendation elementForName:@"creationInfo"];
    
    NSString *eventDate = [[creationInfo elementForName:@"cdt:date"] stringValue];
    
    NSString *eventCreator = [[creationInfo elementForName:@"cdt:person"] stringValue];
    
    NSXMLElement *location = [recommendation elementForName:@"location"];
    NSString *eventLatitude = [location attributeStringValueForName:@"latitude"];
    NSString *eventLongitude = [location attributeStringValueForName:@"longitude"];
    
    NSString *notebody = [[recommendation elementForName:@"noteBody"] stringValue];
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[eventLatitude doubleValue] longitude:[eventLongitude doubleValue]];
    
    //New BaseEvent
    Event *event = [[Event alloc] initEventWithLocation:loc date:[Utility dateFromCroMARTimestampString:eventDate] shared:NO creator:eventCreator];
    
   // SampleNote *sn = [[SampleNote alloc] initSampleNoteWithTitle:@"CroMAR" text:notebody eventItemCreator:eventCreator];
    
    SampleNote *sn = [[SampleNote alloc] initSampleNoteWithEventId:event.baseEventId title:@"CroMAR" text:notebody eventItemCreator:eventCreator];
    
    //Add the object to the base event
    [event.eventItems addObject:sn];
    
    //Send the data
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:event,@"userInfo",node,@"nodeId", nil];
    
    //If retrieving all the data from a space
    if (!update) {
        //Send the data
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventDidLoadNotification" object:nil userInfo:userInfo];
    }
    //If the app received a real-time notification from another app
    else{
        //Send the data and update the timeline
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTimelineNotification" object:nil userInfo:userInfo];
    }
}


//This method is used to parse an eventItem from the timelineAPP
- (void)parseEventItemFromTimelineApp:(NSXMLElement *)item node:(NSString *)node update:(BOOL)update{
    
    //Get the event element
    NSXMLElement *eventXML = [item elementForName:@"eventItem"];
    
    //Get the creation info element
    NSXMLElement *creationInfo = [eventXML elementForName:@"creationInfo"];
    NSString *eventId = [[creationInfo elementForName:@"cdt:id"] stringValue];

    if ([[Utility databaseController] isEventToPost:eventId]) {
        
        NSString *eventDate = [[creationInfo elementForName:@"cdt:date"] stringValue];
        
        NSString *eventCreator = [[creationInfo elementForName:@"cdt:person"] stringValue];
        
        NSXMLElement *location = [eventXML elementForName:@"location"];
        NSString *eventLatitude = [location attributeStringValueForName:@"latitude"];
        NSString *eventLongitude = [location attributeStringValueForName:@"longitude"];
        
        NSString *subject = [[eventXML elementForName:@"subject"] stringValue];
        NSString *body = [[eventXML elementForName:@"body"] stringValue];
        
        NSXMLElement *attachment = [eventXML elementForName:@"attachment"];
        NSString *type = [attachment attributeStringValueForName:@"type"];
        
        UIImage *img = nil;
        NSString *contentBase64 = nil;
        if ([type isEqualToString:@"photo"]) {
            contentBase64 = [[attachment elementForName:@"content"] stringValue];
        }
        if (contentBase64) {
            img = [Utility imageFromBase64String:contentBase64];
            NSData *dataImg = UIImagePNGRepresentation(img);
            NSLog(@"d: %d",dataImg.length);
        }
        
        SampleNote *sn = nil;
        SimplePicture *sp = nil;
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[eventLatitude doubleValue] longitude:[eventLongitude doubleValue]];
        
        //New BaseEvent
        Event *event = [[Event alloc] initEventWithLocation:loc date:[Utility dateFromTimestamp:eventDate watchIT:NO] shared:NO creator:eventCreator];
        
        if (!img) {
            //sn = [[SampleNote alloc] initSampleNoteWithTitle:subject text:body eventItemCreator:eventCreator];
            sn = [[SampleNote alloc] initSampleNoteWithEventId:event.baseEventId title:subject text:body eventItemCreator:eventCreator];
        }
        else{
            //sp = [[SimplePicture alloc] initSimplePictureWithImage:img eventItemCreator:eventCreator];
            sp = [[SimplePicture alloc] initSimplePictureWithEventId:event.baseEventId image:img eventItemCreator:eventCreator];
            
        }
        
        if (img) {
            //Add the simple picture to the base event
            [event.eventItems addObject:sp];
        }
        else{
            //Add the simple note to the base event
            [event.eventItems addObject:sn];
            
        }
#warning review this method when defined xML schemata for each eventItem are defined
        
        //Send the data
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:event,@"userInfo",node,@"nodeId", nil];
        
        //If retrieving all the data from a space
        if (!update) {
            //Send the data
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventDidLoadNotification" object:nil userInfo:userInfo];
        }
        //If the app received a real-time notification from another app
        else{
            //Send the data and update the timeline
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTimelineNotification" object:nil userInfo:userInfo];
        }
    }
    else{
        
        //Set the Post to 1 after received the message
        [[Utility databaseController] updateEvent:eventId withPost:YES];
    }
}

#pragma mark -
#pragma mark XMPPControllerDelegate

//If the connection with the server is established
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSError *error = nil;
   
    if ([sender isConnected]) {
        NSLog(@"Connection Established");
        
         //If there is something immediately wrong, such as the stream is not connected,the method will return NO and set the error.
        if (![self.xmppStream authenticateWithPassword:self.xmppPassword error:&error]) {
            NSLog(@"Error During Authentication: %d, %@",[error code],[error description]);
        }
    }
}

//If the connection with the server is not established
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    //Did Authenticate thereby set the status 'YES'
    NSNumber *boolForConnectivityInfo = [NSNumber numberWithBool:NO];
    
    NSDictionary *connectivityStatus = [NSDictionary dictionaryWithObject:boolForConnectivityInfo forKey:@"connectivityStatus"];
    
    //Send the notification with the status
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPConnectivityDidUpdateNotification" object:nil userInfo:connectivityStatus];
    
}

//If the user is authenticated on the server
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    //Notify the presence to the server
    [self goOnline];
    
    //Did Authenticate thereby set the status 'YES'
    NSNumber *boolForConnectivityInfo = [NSNumber numberWithBool:YES];
    
    NSDictionary *connectivityStatus = [NSDictionary dictionaryWithObject:boolForConnectivityInfo forKey:@"connectivityStatus"];
    
    //Send the notification with the status
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPConnectivityDidUpdateNotification" object:nil userInfo:connectivityStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpacesServiceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPServerDidAuthenticate" object:nil];
}

//If the user is not authenticated on the server
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
    //Did Authenticate thereby set the status 'YES'
    NSNumber *boolForConnectivityInfo = [NSNumber numberWithBool:NO];
    
    NSDictionary *connectivityStatus = [NSDictionary dictionaryWithObject:boolForConnectivityInfo forKey:@"connectivityStatus"];
    
    //Send the notification with the status
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPConnectivityDidUpdateNotification" object:nil userInfo:connectivityStatus];
    
    [Utility showAlertViewWithTitle:@"XMPP Authentication Error" message:@"Not authenticated." cancelButtonTitle:@"Dismiss"];
}

//When received an IQ stanza
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    BOOL ret = NO;
    
    NSLog(@"IQ TYPE: %@",iq.type);
    NSString *iqId = [iq elementID];

    
    if ([iq isGetIQ]) {
        
    }
    
    if ([iq isSetIQ]) {
        
    }
    
    if ([iq isResultIQ]) {
        
        if ([iqId isEqualToString:kIdRegister]) {
            NSLog(@"Registration Result: %@", [iq description]);
        }
        
        else if ([iqId isEqualToString:kIdUnregister]){
            NSLog(@"User Unregistered");
        }
        
        else if ([iqId isEqualToString:kRequiredParameters]){
            NSLog(@"Required Parameters stanza: %@",[iq description]);
        }
        
        //If the service is available
        else if ([iqId isEqualToString:kIdServiceAvailability]){
            NSLog(@"Service Availability: %@",[iq description]);
        }
        
        //The list of all the spaces for the user
        else if ([iqId isEqualToString:kSpaceListId]){
            [self makeSpacesList:(XMPPIQ *)iq];
            NSLog(@"SPACES: %d",[self.spacesArray count]);
        }
        
        else if ([iqId isEqualToString:kSpaceInfoWithId]){
            NSLog(@"Space Info: %@",[iq description]);
            [self setNodeInfo:iq];
        }
        
        else if ([iqId isEqualToString:kPubsubSubscriptionIdentifier]){
            NSLog(@"Subscription Info: %@",[iq description]);
            [self retrieveAllItemsInSpaceWithIQ:iq];
        }
        
        else if([iqId isEqualToString:kPubsubPublishIdentifier]){
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Event shared with success." cancelButtonTitle:@"Dismiss"];
        }
        
        else if ([iqId isEqualToString:kPubsubSubscriberIdentifier]){
            NSLog(@"Subscription: %@",[iq description]);
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Succesfully registered to the node." cancelButtonTitle:@"Dismiss"];
            [self retrieveAllItemsInSpaceWithIQ:iq];
        }
        
        else if ([iqId isEqualToString:kPubsubAllItemsIdentifier]){
            NSLog(@"All items: %@",[iq description]);
            [self initSpaceDataWithIQ:iq];
            
        }
        
        else if([iqId isEqualToString:kChannelsId]){
            NSLog(@"Channels: %@",[iq description]);
        }
    }
    
    
    else if ([iq isErrorIQ]){
        
        if ([iqId isEqualToString:kIdUnregister]) {
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Error Code: %@",[error attributeStringValueForName:@"code"]);
        }
        
        else if ([iqId isEqualToString:kIdServiceAvailability]){
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Error Code: %@, %@",[error attributeStringValueForName:@"code"],[error description]);
        }
        
        else if ([iqId isEqualToString:kSpaceListId]){
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Space Info Error: %@, %@",[error attributeStringValueForName:@"code"],[error description]);
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Error getting the spaces list." cancelButtonTitle:@"Dismiss"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SpacesFetchingErrorNotification" object:nil];
        }
        
        else if ([iqId isEqualToString:kSpaceInfoWithId]){
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Space Info Error: %@, %@",[error attributeStringValueForName:@"code"],[error description]);
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Error getting attributes for the space." cancelButtonTitle:@"Dismiss"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SpacesFetchingErrorNotification" object:nil];
        }
        
        else if ([iqId isEqualToString:kPubsubSubscriptionIdentifier]){
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Subscription Error: %@, %@",[error attributeStringValueForName:@"code"],[error description]);
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Error getting the subscription for the node." cancelButtonTitle:@"Dismiss"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissActivityIndicatorNotification" object:nil];
        }
        
        else if([iqId isEqualToString:kPubsubPublishIdentifier]){
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Subscription Error: %@, %@",[error attributeStringValueForName:@"code"],[error description]);
             [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Note sharing went wrong. Please try again." cancelButtonTitle:@"Dismiss"];
            
        }
        
        else if ([iqId isEqualToString:kPubsubSubscriberIdentifier]){
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Registration to node went wrong. Please try again." cancelButtonTitle:@"Dismiss"];
        }
        
        else if ([iqId isEqualToString:kPubsubAllItemsIdentifier]){
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Subscription Error: %@, %@",[error attributeStringValueForName:@"code"],[error description]);
            [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Error getting all the items for the node." cancelButtonTitle:@"Dismiss"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissActivityIndicatorNotification" object:nil];
        }
            
        else{
            NSXMLElement *error = [iq childErrorElement];
            NSLog(@"Error: %@",[error description]);
        }
    }
    
    return ret;
}

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"Registration Successfull");
}

/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    NSLog(@"Error During In-band Registration: %@",[error description]);
}

//When received a 
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    //Get the event element
    NSXMLElement *event = [message elementForName:@"event"];
   
    //Get the items element
    NSXMLElement *items = [event elementForName:@"items"];
    
    //Get all the item from items
    NSString *node = [items attributeStringValueForName:@"node"];
    
    //Get all the item element of items
    NSArray *itemArray = [items elementsForName:@"item"];
    
    if ([itemArray count]>0) {
        
       //Walk-through the items
        for (NSXMLElement *item in itemArray) {
            
            //Get the name of the element
            NSString *itemName = [[[item children] objectAtIndex:0] name];
            
            //If it is 'genericSensorData' == WatchIt
            if ([itemName isEqualToString:@"genericSensorData"]) {
                //Parse the data
                [self parseSensorDataFromWatchIt:item node:node update:YES];

            }
            //If the information is a recommendation from CroMAR
            else if ([itemName isEqualToString:@"recommendation"]){
                //Parse the data
                [self parseRecommendationFromCroMAR:item node:node update:YES];
            }
            //If the information comes from the timelineApp
            else if ([itemName isEqualToString:@"eventItem"]){
                //Parse the data
                [self parseEventItemFromTimelineApp:item node:node update:YES];
            }
        }
    }
}
 

#pragma mark -
#pragma mark Server Status

//This method is used to check the connectivity status
- (BOOL)isXMPPServerConnected{
    
    if ([self.xmppStream isConnected]) {
        return YES;
    }
    else
        return NO;
}

//This method is used to check the authentication on the xmpp server
- (BOOL)isUserAuthenticatedOnXMPPServer{
    
    if ([self isXMPPServerConnected] && [self.xmppStream isAuthenticated]) {
        return YES;
    }
    else
        return NO;
    
}


#pragma mark -
#pragma mark Notification Methods

- (void)settingsDidChange:(NSNotification *)notification{
    
    if (![self.xmppHost isEqualToString:[Utility settingField:kXMPPServerIdentifier]]) {
        self.xmppHost = [Utility settingField:kXMPPServerIdentifier];
    }
    
    if (![self.xmppDomain isEqualToString:[Utility settingField:kXMPPDomainIdentifier]]) {
        self.xmppDomain = [Utility settingField:kXMPPDomainIdentifier];
        self.xmppSpacesHost = [NSString stringWithFormat:@"spaces.%@",self.xmppDomain];
        self.xmppPubsubHost = [NSString stringWithFormat:@"pubsub.%@",self.xmppDomain];
    }
    
    if (![self.xmppUser isEqualToString:[Utility settingField:kXMPPUserIdentifier]]) {
        self.xmppUser = [Utility settingField:kXMPPUserIdentifier];
    }
    
    if (![self.xmppPassword isEqualToString:[Utility settingField:kXMPPPassIdentifier]]) {
        self.xmppPassword = [Utility settingField:kXMPPPassIdentifier];
    }
    
    if ([self isXMPPServerConnected]) {
        [self disconnect];
    }
    [self connect];
}

@end
