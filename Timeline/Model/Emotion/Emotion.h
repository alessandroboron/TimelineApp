//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  Emotion.h
//  Timeline
//
//  Created by Alessandro Boron on 13/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventItem.h"

typedef enum{
    EventEmotionUnknown = 0,
    EventEmotionBad,
    EventEmotionOk,
    EventEmotionGood,
    EventEmotionSuper

}EmotionItem;

@interface Emotion : EventItem

@property (strong, nonatomic) NSString *eventId;
@property (assign) EmotionItem emotionItem;
@property (strong, nonatomic) NSString *creator;

- (id)initEmotionWithEventId:(NSString *)eventId emotion:(EmotionItem)emotion eventItemCreator:(NSString *)eventCreator;

- (id)initEmotionWithEventItem:(EventItem *)eventItem emotion:(EmotionItem)emotion;

- (NSUInteger)emotionType;

- (NSString *)emotionImagePath;

@end
