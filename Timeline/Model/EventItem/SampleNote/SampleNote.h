//
//  SampleNote.h
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventItem.h"

@interface SampleNote : EventItem

@property (strong, nonatomic) NSString *noteTitle;
@property (strong, nonatomic) NSString *noteText;

//The designated initializer
- (id)initSampleNoteWithTitle:(NSString *)title text:(NSString *)text eventItemCreator:(NSString *)eventCreator;

@end
