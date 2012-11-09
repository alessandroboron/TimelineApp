//
//  DBController.h
//  RNHA
//
//  Created by Alessandro Boron on 4/12/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define DB_PATH @""

@class Reachability;

@class Timeline;
@class Event;
@class SampleNote;

@interface DBController : NSObject


@property (nonatomic,strong) Reachability *hostReachable; 


//This method is used to initialize the DB. In case the DB does not exist it creates it 
- (id)initDB;

//- (NSMutableDictionary *)fetchDataFromDB;

- (NSMutableArray *)fetchTimelinesFromDB;

- (NSMutableArray *)fetchEventsFromDBForTimelineId:(Timeline *)timeline;

- (BOOL)isTimelineInDB:(NSString *)timelineId;

- (void)insertTimeline:(Timeline *)timeline;

- (BOOL)isTimeline:(NSString *)timelineId titleEqualTo:(NSString *)timelineTitle;

- (BOOL)isTimeline:(NSString *)timelineId sharedEqualTo:(BOOL)shared;

- (void)updateTimeline:(NSString *)timelineId withTitle:(NSString *)title;

- (void)updateTimeline:(NSString *)timelineId withShared:(BOOL)shared;

- (void)updateEvent:(NSString *)eventId withStorage:(BOOL)storage;

- (void)insertEvent:(Event *)event inTimeline:(Timeline *)timeline;

- (BOOL)isEventInDB:(NSString *)eventId;

- (BOOL)isEventToPost:(NSString *)eventId;

- (void)updateEvent:(NSString *)eventId withPost:(BOOL)post;

- (BOOL)isTimelineShared:(NSString *)timelineId;

////////////////////////////////////////////CATEGORY METHODS/////////////////////////////////////////////////////////

//This method is used to retrieve the categories stored in the DB
//- (NSArray *)getCategories;

/////////////////////////////////////////////NOTE METHODS////////////////////////////////////////////////////////////

//- (void)insertNote:(Note *)note forCategory:(NSString *)categoryName;

//- (void)removeNote:(Note *)note inCategory:(NSString *)categoryName;

//- (BOOL)isNotePresent:(NSString *)noteId;





@end
