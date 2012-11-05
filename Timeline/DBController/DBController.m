//
//  DBController.m
//  RNHA
//
//  Created by Alessandro Boron on 4/12/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import "DBController.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "Timeline.h"
#import "BaseEvent.h"
#import "Event.h"
#import "EventItem.h"
#import "SampleNote.h"
#import "SimplePicture.h"
#import "SimpleVideo.h"
#import "SimpleRecording.h"
#import "Emotion.h"
#import "Reachability.h"
#import "XMPPRequestController.h"


#define kDBName @"TimelineApp.sqlite"

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

@interface DBController () 


- (void)checkAndCreateDB;
- (NSString *)databasePath;

- (BOOL)isTimelineInDB:(NSString *)timelineId;
- (void)insertTimeline:(Timeline *)timeline;
- (NSArray *)timelines;
- (void)insertEventInDB:(Event *)event;
- (NSArray *)eventsInTimeline:(Timeline *)timeline;
- (Event *)eventWithId:(NSString *)event_Id;
- (NSMutableArray *)eventItemsInEvent:(Event *)event;
- (id)specificEventItemWithId:(EventItem *)eventItem;
- (SampleNote *)fetchSimpleNoteForEventItem:(EventItem *)eventItem;
- (SimplePicture *)fetchSimplePictureForEventItem:(EventItem *)eventItem;
- (SimpleVideo *)fetchSimpleVideoForEventItem:(EventItem *)eventItem;
- (SimpleRecording *)fetchSimpleRecordingForEventItem:(EventItem *)eventItem;
//- (Emotion *)fetchSimpleEmotionWithId:(EventItem *)eventItem;
- (BOOL)isEvent:(Event *)event inTimeline:(Timeline *)timeline;
- (void)insertEvent:(Event *)event inTimelineEvents:(Timeline *)timeline;
- (void)insertEventItemInDB:(Event *)event;
- (void)insertItemInDB:(Event *)event;

//Dropbox method

- (void)checkOutDBFile;

@end

@implementation DBController

@synthesize hostReachable;

#pragma mark -
#pragma mark Init Methods


//This Method is used to initialize the DB. In case the DB does not exist it creates it 
- (id)initDB{
    
    self = [super init];
    
    if (self) {
        //Check if the DB already exist
        [self checkAndCreateDB];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

//This method is used to fetch the Timelines from the DB
- (NSMutableArray *)fetchTimelinesFromDB{
    
    //Get timelines
    NSMutableArray *timelines = [[self timelines] mutableCopy];
    
    return timelines;
}

- (NSMutableArray *)fetchEventsFromDBForTimelineId:(Timeline *)timeline{
   
    //Initialize an array to store the events
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    
    //Get The Events Ref for a timeline
    NSArray *eventsInTimeline = [self eventsInTimeline:timeline];
   
    //Walk-through the events Id
    for (NSString *event_Id in eventsInTimeline) {
        //Get the event in Timeline
        Event *event = [self eventWithId:event_Id];
        //Get the items for the event
        NSMutableArray *items = [self eventItemsInEvent:event];
        //Walk-through the items
        for (EventItem *ei in items) {
            //Get the specific item
            id item = [self specificEventItemWithId:ei];
            //Store the item in the event
            [event.eventItems addObject:item];
        }
        //Add the event to the array
        [eventsArray addObject:event];
    }
    
    //Return the dictionary
    return eventsArray;
    
}

- (void)updateEvent:(NSString *)eventId withStorage:(BOOL)storage{
    
    if ([self isEventInDB:eventId]) {
        
        //Get the database
        FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
        
        @try {
            [db open];
         
            [db executeUpdate:@"UPDATE Events SET Stored = ? WHERE Id = ?",[NSString stringWithFormat:@"%i", storage], eventId];
            
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"Error: %@",[exception description]);
        }
        
        @finally {
            [db close];
        }

    }
}

/*
//This method is used to fetch the Notes from the DB
- (NSMutableDictionary *)fetchDataFromDB{
    
    //Get timelines
    NSArray *timelines = [self timelines];
    
    NSLog(@"Timelines count: %d",[timelines count]);
    
    //Initialize the dictionary that contains events for timeline
    NSMutableDictionary *timelinesAndEvents = [[NSMutableDictionary alloc] init];
    
    //Walk-through the timelines
    for (Timeline *timeline in timelines) {
       //Get The Events Ref for a timeline
       NSArray *eventsInTimeline = [self eventsInTimeline:timeline];
       //Initialize an array to store the events
        NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
        //Walk-through the events Id
        for (NSString *event_Id in eventsInTimeline) {
            //Get the event in Timeline
            Event *event = [self eventWithId:event_Id];
            //Get the items for the event
            NSMutableArray *items = [self eventItemsInEvent:event];
            //Walk-through the items
            for (EventItem *ei in items) {
               //Get the specific item
                id item = [self specificEventItemWithId:ei];
                //Store the item in the event
                [event.eventItems addObject:item];
            }
            //Add the event to the array
            [eventsArray addObject:event];
        }
        //Store events and timeline in dictionary
        [timelinesAndEvents setObject:eventsArray forKey:timeline.tId];
    }
    
    //Return the dictionary
    return timelinesAndEvents;
}
*/

- (void)insertEvent:(Event *)event inTimeline:(Timeline *)timeline{
    
    //If the timeline is not present in the Timelines Table
    if (![self isTimelineInDB:timeline.tId]) {
        //Insert timeline object in Timelines Table
        [self insertTimeline:timeline];
    }
    //If the event doesn't exist in timeline add Event in Events
    if (![self isEventInDB:event.baseEventId]) {
        //Insert event object in Event table
        [self insertEventInDB:event];
        
    }
    //If the event is not in the EventsInTimeline
    if (![self isEvent:event inTimeline:timeline]) {
        //Insert the relationship Event-Timeline in EventsInTimeline table
        [self insertEvent:event inTimelineEvents:timeline];
    }
    //Insert EventItem and set its Event_Id to the Id of the Event
    [self insertEventItemInDB:event];
    [self insertItemInDB:event];
}

- (BOOL)isEventToPost:(NSString *)eventId{
    
    if ([self isEventInDB:eventId]) {
        
        BOOL post = YES;
        
        //Get the database
        FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
        
        @try {
            //Open the connection
            [db open];
            
            //Select the category with a given name
            FMResultSet *result = [db executeQuery:@"SELECT * FROM Events WHERE Id = ?",eventId];
            
            //If the category is present
            if ([result next]) {
                post = [result boolForColumn:@"Post"];
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"Error: %@",[exception description]);
        }
        
        @finally {
            //Close the connection
            [db close];
        }
        
        return post;
    }
    
}

- (void)updateEvent:(NSString *)eventId withPost:(BOOL)post{
    
    if ([self isEventInDB:eventId]) {
        
        //Get the database
        FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
        
        @try {
            [db open];
            
            [db executeUpdate:@"UPDATE Events SET Post = ? WHERE Id = ?",[NSString stringWithFormat:@"%i", post], eventId];
            
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"Error: %@",[exception description]);
        }
        
        @finally {
            [db close];
        }
        
    }
}

#pragma mark -
#pragma mark Private Methods

//This method is used to get the Path of the DB
- (NSString *)databasePath{
    
    //Get the path of the Document Folder
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    //Set the Path for the DB
    NSString *databasePath = [documentDir stringByAppendingPathComponent:kDBName];
    //Return the DB Path
    return databasePath;
}

//This method is used to check if the DB exist. If not it copy the database file in the Document directory
- (void)checkAndCreateDB{
    
    BOOL exist;
    
    //Get the path of the file
    NSString *dbPathString = [self databasePath];
    NSLog(@"DBPATH: %@",dbPathString);
    
    //Get the default file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Check if the file already exist at the path otherwise it copy it
    exist = [fileManager fileExistsAtPath:dbPathString];
    
    //If the database not exist in the Document folder copy it
    if (!exist) {
        //Get the path name
       // NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBName];
        NSString *databasePathFromApp = [[NSBundle mainBundle] pathForResource:kDBName ofType:nil];
        DLog(@"DB PATH FROM APP: %@", databasePathFromApp);
        
        NSError *error = nil;
        
        //Copy the file in the Document folder
        [fileManager copyItemAtPath:databasePathFromApp toPath:dbPathString error:&error];
        
        if (error) {
            DLog(@"Error: %@", [error description]);
            [Utility showAlertViewWithTitle:@"Database Error" message:@"Could Not Copy the Database in the Document Folder." cancelButtonTitle:@"Dismiss"];
        }
    }
}

//This method is used 
- (BOOL)isTimelineInDB:(NSString *)timelineId{
    
    BOOL present = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Timelines WHERE Id = ?",timelineId];
        
        //If the category is present
        if ([result next]) {
            present = YES;
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return present;
    
}

//This method is used to insert a timeline in the DB
- (void)insertTimeline:(Timeline *)timeline{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"INSERT INTO Timelines (Id,Title,Creator,Shared) VALUES (?,?,?,?)",timeline.tId,timeline.title,timeline.creator,[NSString stringWithFormat:@"%i", timeline.shared]];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
}

- (NSArray *)timelines{
    
    //Initialize a mutable array to store the timelines result
    NSMutableArray *timelines = [[NSMutableArray alloc] init];
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the categories
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Timelines"];
        
        //For each element
        while ([result next]) {
            //Initialize the Timeline object
            NSString *tId = [result stringForColumn:@"Id"];
            NSString *title = [result stringForColumn:@"Title"];
            NSString *creator = [result stringForColumn:@"Creator"];
            BOOL shared = [result boolForColumn:@"Shared"];
            //Insert into timelines array
            Timeline *t = [[Timeline alloc] initTimelineWithId:tId title:title creator:creator shared:shared];
            
            [timelines addObject:t];
            
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return a immutable version of the array
    return [timelines copy];
    
}

- (BOOL)isEventInDB:(NSString *)eventId{
    
    BOOL present = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Events WHERE Id = ?",eventId];
        
        //If the category is present
        if ([result next]) {
            present = YES;
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return present;
    
}

- (void)insertEventInDB:(Event *)event{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"INSERT INTO Events (Id,Latitude,Longitude,Datetime,Creator,Shared,Stored,Post) VALUES (?,?,?,?,?,?,?,?)",event.baseEventId, [NSString stringWithFormat:@"%g",event.location.coordinate.latitude], [NSString stringWithFormat:@"%g",event.location.coordinate.longitude], [Utility dateTimeDescriptionWithLocaleIdentifier:event.date], event.creator, [NSString stringWithFormat:@"%i", event.shared], [NSString stringWithFormat:@"%i", event.stored ],[NSString stringWithFormat:@"%i",event.post]];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
}

- (NSArray *)eventsInTimeline:(Timeline *)timeline{
    
    //Initialize a mutable array to store the timelines result
    NSMutableArray *eventsInTimeline = [[NSMutableArray alloc] init];
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the events in timeline
        FMResultSet *result = [db executeQuery:@"SELECT * FROM EventsInTimeline WHERE Timeline_Id = ?",timeline.tId];
        
        //For each element
        while ([result next]) {
            //Get the event id
            NSString *events_id = [result stringForColumn:@"Event_Id"];
            //Add the event to the array
            [eventsInTimeline addObject:events_id];
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return a immutable version of the array
    return [eventsInTimeline copy];
}


- (Event *)eventWithId:(NSString *)event_Id{
    
    Event *event = nil;
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the categories
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Events WHERE Id = ?",event_Id];
        
        //For each element
        while ([result next]) {
            //Initialize the Timeline object
            NSString *eId = [result stringForColumn:@"Id"];
            NSString *latitude = [result stringForColumn:@"Latitude"];
            NSString *longitude = [result stringForColumn:@"Longitude"];
            NSString *date = [result stringForColumn:@"Datetime"];
            NSString *creator = [result stringForColumn:@"Creator"];
            BOOL shared = [result boolForColumn:@"Shared"];
            BOOL stored = [result boolForColumn:@"Stored"];
            BOOL post = [result boolForColumn:@"Post"];
            
            NSLog(@"Date: %@",[Utility dateFromEventTimestampString:date]);
            
            event = [[Event alloc] initEventWithId:eId location:[[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]] date:[Utility dateFromEventTimestampString:date] creator:creator shared:shared stored:stored post:post];
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return event;
    
}

- (NSMutableArray *)eventItemsInEvent:(Event *)event{
    
    EventItem *item = nil;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the categories
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Items WHERE Event_Id = ?",event.baseEventId];
        
        //For each element
        while ([result next]) {
            //Initialize the Timeline object
            NSString *eventItemId = [result stringForColumn:@"Id"];
            NSString *eventId = [result stringForColumn:@"Event_Id"];
            NSString *type = [result stringForColumn:@"Type"];
            NSString *creator = [result stringForColumn:@"Creator"];
            
            item = [[EventItem alloc] initEventItemWithId:eventItemId eventId:eventId creator:creator];
            [items addObject:item];
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return items;
    
}

- (id)specificEventItemWithId:(EventItem *)eventItem{
    
    id item = nil;
    
    item = [self fetchSimpleNoteForEventItem:eventItem];
    
    if (!item) {
        item = [self fetchSimplePictureForEventItem:eventItem];
    }
    
    else if (!item){
        item = [self fetchSimpleVideoForEventItem:eventItem];
    }
    
    else if (!item){
        item = [self fetchSimpleRecordingForEventItem:eventItem];
    }
    
    return item;
}

- (SampleNote *)fetchSimpleNoteForEventItem:(EventItem *)eventItem{
    
    SampleNote *sn = nil;
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the SimpleNote
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SimpleNote WHERE Item_Id = ?",eventItem.eventItemId];
        
        //For each element
        while ([result next]) {
            //Initialize the SampleNote object
            NSString *title = [result stringForColumn:@"Title"];
            NSString *text = [result stringForColumn:@"Text"];
        
            sn = [[SampleNote alloc] initSampleNoteWithEventItem:eventItem title:title text:text];
            
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return sn;
    
}
- (SimplePicture *)fetchSimplePictureForEventItem:(EventItem *)eventItem{
    
    SimplePicture *sp = nil;
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the SimpleNote
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SimplePicture WHERE Item_Id = ?",eventItem.eventItemId];
        
        //For each element
        while ([result next]) {
            //Initialize the SampleNote object
            NSString *url = [result stringForColumn:@"Url"];
            
            sp = [[SimplePicture alloc] initSimplePictureWithEventItem:eventItem url:url];
            
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return sp;
    
}
- (SimpleVideo *)fetchSimpleVideoForEventItem:(EventItem *)eventItem{
    
    SimpleVideo *sv = nil;
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the SimpleNote
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SimpleVideo WHERE Item_Id = ?",eventItem.eventItemId];
        
        //For each element
        while ([result next]) {
            //Initialize the Timeline object
            NSString *urlPath = [result stringForColumn:@"Url"];
        
            sv = [[SimpleVideo alloc] initSimpleVideoWithEventItem:eventItem url:[NSURL URLWithString:urlPath]];
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return sv;
    
}
- (SimpleRecording *)fetchSimpleRecordingForEventItem:(EventItem *)eventItem{
    
    SimpleRecording *sr = nil;
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the SimpleNote
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SimpleRecording WHERE Item_Id = ?",eventItem.eventItemId];
        
        //For each element
        while ([result next]) {
            //Initialize the Timeline object
            NSString *urlPath = [result stringForColumn:@"Url"];
            
            sr = [[SimpleRecording alloc] initSimpleRecordingWithEventItem:eventItem url:urlPath];
            
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return sr;
    
}
- (Emotion *)fetchSimpleEmotionForEventItem:(EventItem *)eventItem{
    
    id item = nil;
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the SimpleNote
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Emotion WHERE Item_Id = ?",eventItem.eventItemId];
        
        //For each element
        while ([result next]) {
            //Initialize the Timeline object
            NSString *eventItemId = [result stringForColumn:@"Id"];
            NSString *eventId = [result stringForColumn:@"Event_Id"];
            NSString *type = [result stringForColumn:@"Type"];
            NSString *creator = [result stringForColumn:@"Creator"];
            
            item = [[EventItem alloc] initEventItemWithId:eventItemId eventId:eventId creator:creator];
            
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return the event
    return item;
}


- (BOOL)isEvent:(Event *)event inTimeline:(Timeline *)timeline{
    
    
    BOOL present = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM EventsInTimeline WHERE Timeline_Id = ? AND Event_Id = ?",timeline.tId,event.baseEventId];
        
        //If the category is present
        if ([result next]) {
            present = YES;
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return present;
}

- (void)insertEvent:(Event *)event inTimelineEvents:(Timeline *)timeline{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"INSERT INTO EventsInTimeline (Timeline_Id,Event_Id) VALUES (?,?)",timeline.tId,event.baseEventId];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
    
}

- (void)insertEventItemInDB:(Event *)event{
    
    id objectInTimeline = [event.eventItems objectAtIndex:0];
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"INSERT INTO Items (Id,Event_Id,Type,Creator) VALUES (?,?,?,?)",((EventItem *)objectInTimeline).eventItemId,event.baseEventId,NSStringFromClass([Event class]),event.creator];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
    
}

- (void)insertItemInDB:(Event *)event{
    
    id objectInTimeline = [event.eventItems objectAtIndex:0];
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    NSString *query = nil;
    NSDictionary *argsDict = nil;
    
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",((SampleNote *)objectInTimeline).noteTitle, @"Title", ((SampleNote *)objectInTimeline).noteText, @"Text" , nil];
        query = @"INSERT INTO SimpleNote (Item_Id,Title,Text) VALUES (:Item_Id,:Title,:Text)";
    }
    
    else if ([objectInTimeline isMemberOfClass:[SimplePicture class]]){
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",[NSNull null],@"Url", nil];
        query = @"INSERT INTO SimplePicture (Item_Id,Url) VALUES (:Item_Id,:Url)";

    }
    
    else if ([objectInTimeline isMemberOfClass:[SimpleVideo class]]){
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",((SimpleVideo *)objectInTimeline).videoURL ,@"Url", nil];
        query = @"INSERT INTO SimpleVideo (Item_Id,Url) VALUES (:Item_Id,:Url)";

    }
    
    else if ([objectInTimeline isMemberOfClass:[SimpleRecording class]]){
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",((SimpleRecording *)objectInTimeline).urlPath ,@"Url", nil];
        query = @"INSERT INTO SimpleRecording (Item_Id,Url) VALUES (:Item_Id,:Url)";
    }
    
    else if ([objectInTimeline isMemberOfClass:[Emotion class]]){
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",((SimpleVideo *)objectInTimeline).videoURL ,@"Url", nil];
        query = @"INSERT INTO SimpleNote (Item_Id,Url) VALUES (:Item_Id,:Url)";
    }
    
    @try {
        [db open];
        
        [db executeUpdate:query withParameterDictionary:argsDict];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
}

#pragma mark -
#pragma mark Categories Methods
/*
//This method is used to retrieve the categories stored in the DB
- (NSArray *)getCategories{
    
    //Initialize a mutable array to store the fetched result
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    //Get the DB
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the categories
        FMResultSet *result = [db executeQuery:@"SELECT * FROM categories"];
        
        //For each element
        while ([result next]) {
            [categories addObject:[result stringForColumn:@"name"]];
            NSLog(@"Category: %@",[result stringForColumn:@"name"]);
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return a immutable version of the array
    return [categories copy];
}

- (void)insertCategory:(NSString *)name{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"INSERT INTO categories (name) VALUES (?)",name];
        
        if ([db hadError]) {
             NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
    
}

//This method is used to check if a category is present or not in the DB
- (BOOL)isCategoryPresent:(NSString *)name{
    
    BOOL present = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
   
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM categories WHERE name = ?",name];
        
        //If the category is present
        if ([result next]) {
            present = YES;
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return present;
}

//This method is used to retrieve the name of a category according to its id
- (NSString *)categoryNameForId:(NSInteger)catId{
 
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM categories WHERE id = ?",[NSString stringWithFormat:@"%d",catId]];
        
        //If the category is present
        while ([result next]) {
            return [result stringForColumn:@"name"];
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
}

//This method is used to retrieve all the categories for a 
- (NSArray *)categoriesForNote:(NSString *)noteId{
    
    NSMutableArray *cat = [[NSMutableArray alloc] init];
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM notesxcat WHERE id_note = ?",noteId];
        
        //If the category is present
        while ([result next]) {
            //Get the name of the category
            NSString *catName = [self categoryNameForId:[result intForColumn:@"id_cat"]];
            [cat addObject:catName];
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return [cat copy];
}

#pragma mark -
#pragma mark Note Methods

//This method is used to insert a category in the DB
- (void)insertNote:(Note *)note forCategory:(NSString *)categoryName{
    
    if (![self isNotePresent:note.noteId]) {
        
        //Get the database
        FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
        
        //If the category is not present in the DB
        if (![self isCategoryPresent:categoryName]) {
            //Insert the category in the db
            [self insertCategory:categoryName];
        }
        
        //If the user is not present in the DB
        if (![self isUserPresent:note.authorString]) {
            //Insert the user in the DB
            [self insertUser:note.authorString];
        }
        
        //Get the user id
        
        NSInteger userId = [self userIdForName:note.authorString];
        
        //Insert the note in notes
        @try {
            [db open];
            
            [db executeUpdate:@"INSERT INTO notes VALUES (?,?,?,?)",note.noteId,[NSString stringWithFormat:@"%d",userId],note.timeStampDate,note.contentString];
            
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error: %@",[exception description]);
        }
        @finally {
            [db close];
        }
    }
    
    //Get the category id for name
    NSInteger categoryId = [self categoryIdForName:categoryName]; 
   
    //Insert the note in notescat table
    [self insertInRelTableNoteId:note.noteId categoryId:categoryId];
}

//This method is used to remove a note in the Database
- (void)removeNote:(Note *)note inCategory:(NSString *)categoryName{
    
    NSInteger categoryId = [self categoryIdForName:categoryName];
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    //Delete the note from notes
    @try {
        [db open];
        
        [db executeUpdate:@"DELETE FROM notesxcat WHERE id_note = ? AND id_cat = ?", note.noteId, [NSString stringWithFormat:@"%d",categoryId]];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }

    [self removeNoteFromNotes:note.noteId];
}

- (BOOL)isNotePresent:(NSString *)noteId{
    
    BOOL ret = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    //Delete the note from notes
    @try {
        [db open];
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM notes WHERE id = ?",noteId];
        
        if (![db hadError]) {
            if ([result next]) {
                ret = YES;
            }
        }
        else
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);

    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }

    return ret;
}

#pragma mark -
#pragma mark Private Methods

//This method is used to check if the DB exist. If not it copy the database file in the Document directory
- (void)checkAndCreateDB{
    
    BOOL exist;
    
    //Get the path of the file
    NSString *dbPathString = [Utility databasePath];
    NSLog(@"DBPATH: %@",dbPathString);
    
    //Get the default file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Check if the file already exist at the path otherwise it copy it
    exist = [fileManager fileExistsAtPath:dbPathString];
    
    self.hostReachable = [Reachability reachabilityWithHostName:@"www.google.com"];

    if (exist) {
        if ([self.hostReachable isReachable] && exist) {
            [[RESTClient sharedRESTClient].restClient loadFile:[NSString stringWithFormat:@"%@%@",kDropboxFolder,kDBName] intoPath:[Utility databasePath]];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetNotReachableNotification" object:nil];            
        }
    }
    
    else{
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDropboxRev];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Get the path name
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBName];
        NSLog(@"DB PATH FROM APP: %@", databasePathFromApp);
        
        NSError *error = nil;
        //Copy the file in the Document folder
        [fileManager copyItemAtPath:databasePathFromApp toPath:dbPathString error:&error];
        
        if (error) {
            NSLog(@"Error: %@", [error description]);
        }
        else{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetNotReachableNotification" object:nil];
        }
    }

    //[self checkOutDBFile];
}

//This method is used to fetch the Notes from the DB
- (NSMutableDictionary *)fetchDBNotes{
    
    //Initialize the dictionary
    NSMutableDictionary *notes = [[NSMutableDictionary alloc] init];
    //Get the categories name as keys for the dictionary
    NSArray *keys = [self getCategories];
    //Initialize the array that will store an array for each category
    NSMutableArray *objectsForKeys = [[NSMutableArray alloc] init];
    
    //Initialize an array for each category
    for (int i = 0; i < [keys count]; i++) {
        [objectsForKeys addObject:[[NSMutableArray alloc] init]];
    }
    
    //Set the dictionary with categories as keys and arrays for objects
    notes = [[NSMutableDictionary alloc] initWithObjects:[objectsForKeys copy] forKeys:keys];
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open the connection with the DB
        [db open];
        
        //Execute the query
        FMResultSet *result = [db executeQuery:@"SELECT * FROM notesxcat ORDER BY rowid DESC"];
        
        if (![db hadError]) {
            while ([result next]) {
                NSString *idNote = [result stringForColumn:@"id_note"];
                NSInteger idCat = [result intForColumn:@"id_cat"];
             
                //Get the note according to its id
                Note *note = [self noteForId:idNote];
                //Get the category name for the note
                NSString *catName = [self categoryNameForId:idCat];
                
                //Insert the note in the array
                [[notes objectForKey:catName] addObject:note];
            }
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection with the DB
        [db close];
    }
    
    return notes;
}

//This method is used to get a note from its Id
- (Note *)noteForId:(NSString *)noteId{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the categories
        FMResultSet *result = [db executeQuery:@"SELECT * FROM notes WHERE id = ?",noteId];
        
        //Get the result 
        if ([result next]) {
            NSInteger authorId = [result intForColumn:@"user_id"];
            NSString *content = [result stringForColumn:@"content"];
            NSDate *date = [result dateForColumn:@"timestamp"];
            
            //Get the author name
            NSString *userName = [self userNameForId:authorId];
            
            //Get the categories for the Note
            NSArray *tags = [self categoriesForNote:noteId];
            
            return [[Note alloc] initNoteWithId:noteId author:userName content:content timestamp:date tags:tags];
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }

}

//This method is used to delete a note from the 'Notes' table
- (void)removeNoteFromNotes:(NSString *)noteId{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    //Insert the note in notes
    @try {
        [db open];
        
        [db executeUpdate:@"DELETE FROM notes WHERE id = ?", noteId];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }

    
}

//This method is used to get the id of a category for name;
- (NSInteger)categoryIdForName:(NSString *)name{
    
    NSInteger categoryId;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open a connection
        [db open];
        
        //Fetch the categories
        FMResultSet *result = [db executeQuery:@"SELECT * FROM categories WHERE name = ?",name];
        
        //Get the result 
        if ([result next]) {
            categoryId = [result intForColumn:@"id"];
        }
    }
    
    //Exception catched
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    //Close the connection
    @finally {
        //Close the connection
        [db close];
    }
    
    //Return a immutable version of the array
    return categoryId;
    
}

//This method is used to get the Id of a user according to its name
- (NSInteger)userIdForName:(NSString *)name{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        [db open];
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM users WHERE name = ?",name];
        
        if (![db hadError]) {
            if ([result next]) {
                return [result intForColumn:@"id_user"];
            }
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }
}

//This method is used to get the name of a user from its id
- (NSString *)userNameForId:(NSInteger)userId{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        [db open];
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM users WHERE id_user = ?",[NSString stringWithFormat:@"%d",userId]];
        
        if (![db hadError]) {
            if ([result next]) {
                return [result stringForColumn:@"name"];
            }
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }

    return nil;
}

//This method is used to check if a user already exist in the DB
- (BOOL)isUserPresent:(NSString *)name{
    
    BOOL present = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM users WHERE name = ?",name];
        
        //If the category is present
        if (![db hadError]) {
            if ([result next]) {
                present = YES;
            }
        }
        else{
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return present;
}

//This method is used to insert a user in the system
- (void)insertUser:(NSString *)name{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        //Open the connection with the DB
        [db open];
        
        //Execute the query
        [db executeUpdate:@"INSERT INTO users (name) values (?)",name];
        
        //If an error happened
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }

}

//This method is used to insert in the notescat table the note_id with the category_id
- (void)insertInRelTableNoteId:(NSString *)noteId categoryId:(NSInteger)categoryId{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility databasePath]];
    
    @try {
        [db open];
        
       
        [db executeUpdate:@"INSERT INTO notesxcat (id_note,id_cat) values (?,?)" withArgumentsInArray:[NSArray arrayWithObjects:noteId,[NSString stringWithFormat:@"%d",categoryId], nil]];
        
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        [db close];
    }    
}

//This method is used to check if the db file is already present in Dropbox
- (void)checkOutDBFile{
    
    [[RESTClient sharedRESTClient].restClient loadMetadata:kDropboxFolder];
}
*/
@end
