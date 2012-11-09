//
//  Emotion.m
//  Timeline
//
//  Created by Alessandro Boron on 13/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "Emotion.h"

@implementation Emotion

@synthesize eventId = _eventId;
@synthesize emotionItem = _emotionItem;
@synthesize creator = _creator;

- (id)initEmotionWithEventId:(NSString *)eventId emotion:(EmotionItem)emotion eventItemCreator:(NSString *)eventCreator{
    
    self = [super initEventItemWithHashedId:[NSString stringWithFormat:@"%d%@%@",emotion,eventCreator,[NSDate date]] creator:eventCreator];
    
    if (self) {
        if (eventId) {
            _eventId = eventId;
        }
        _emotionItem = emotion;
        _creator = eventCreator;
    
    }
    
    return self;
    
}

- (id)initEmotionWithEventItem:(EventItem *)eventItem emotion:(EmotionItem)emotion{
    
    self = [super initEventItemWithId:eventItem.eventItemId eventId:eventItem.eventId creator:eventItem.creator];
    
    if (self) {
        
        _emotionItem = emotion;
    }
    
    return self;
    
}

- (NSUInteger)emotionType{
    
    if (self.emotionItem == EventEmotionBad) {
        return  1;
    }
    else if (self.emotionItem == EventEmotionOk) {
        return  2;
    }
    else if (self.emotionItem == EventEmotionGood) {
        return  3;
    }
    else if (self.emotionItem == EventEmotionSuper) {
        return  4;
    }
    else{
        return 0;
    }
}

- (NSString *)emotionImagePath{
    
    if (self.emotionItem == EventEmotionBad) {
        return @"mad.png";
    }
    else if (self.emotionItem == EventEmotionOk) {
        return @"soandso.png";
    }
    else if (self.emotionItem == EventEmotionGood) {
        return @"happy.png";
    }
    else if (self.emotionItem == EventEmotionSuper) {
        return @"glad.png";
    }
    else{
        return nil;
    }

}

@end
