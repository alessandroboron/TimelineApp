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

- (BOOL)isTimeline:(NSString *)timelineId titleEqualTo:(NSString *)timelineTitle{
    
    BOOL same = YES;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Timelines WHERE Id = ?",timelineId];
        
        //If the category is present
        if ([result next]) {
            NSString *title = [result stringForColumn:@"Title"];
            same = [timelineTitle isEqualToString:title];
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return same;
}

- (BOOL)isTimeline:(NSString *)timelineId sharedEqualTo:(BOOL)shared{
    
    BOOL same = YES;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Timelines WHERE Id = ?",timelineId];
        
        //If the category is present
        if ([result next]) {
            BOOL sh = [result boolForColumn:@"Shared"];
            if (sh != shared) {
                same = NO;
            }
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return same;
}

- (void)updateTimeline:(NSString *)timelineId withTitle:(NSString *)title{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"UPDATE Timelines SET Title = ? WHERE Id = ?",title, timelineId];
        
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

- (void)updateTimeline:(NSString *)timelineId withShared:(BOOL)shared{
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        [db open];
        
        [db executeUpdate:@"UPDATE Timelines SET Shared = ? WHERE Id = ?",[NSString stringWithFormat:@"%i",shared], timelineId];
        
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

- (BOOL)isTimelineShared:(NSString *)timelineId{
    
    BOOL shared = NO;
    
    //Get the database
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    
    @try {
        //Open the connection
        [db open];
        
        //Select the category with a given name
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Timelines WHERE Id = ?",timelineId];
        
        //If the category is present
        if ([result next]) {
           shared = [result boolForColumn:@"Shared"];
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"Error: %@",[exception description]);
    }
    
    @finally {
        //Close the connection
        [db close];
    }
    
    return shared;
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
            //NSString *type = [result stringForColumn:@"Type"];
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
    
    if (!item){
        item = [self fetchSimpleVideoForEventItem:eventItem];
    }
    
    if (!item){
        item = [self fetchSimpleRecordingForEventItem:eventItem];
    }
    
    if (!item){
        item = [self fetchSimpleEmotionForEventItem:eventItem];
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
    
    Emotion *e = nil;
    
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
            NSInteger type = [result intForColumn:@"Type"];
            
            e = [[Emotion alloc] initEmotionWithEventItem:eventItem emotion:type];
            
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
    return e;
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
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",((SimplePicture *)objectInTimeline).imagePath,@"Url", nil];
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
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:((EventItem *)objectInTimeline).eventItemId,@"Item_Id",[NSString stringWithFormat:@"%d",[((Emotion *)objectInTimeline) emotionType]],@"Type", nil];
        query = @"INSERT INTO Emotion (Item_Id,Type) VALUES (:Item_Id,:Type)";
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


@end
