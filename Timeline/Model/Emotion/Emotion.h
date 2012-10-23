//
//  Emotion.h
//  Timeline
//
//  Created by Alessandro Boron on 13/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
   
    EventEmotionBad = 0,
    EventEmotionOk,
    EventEmotionGood,
    EventEmotionSuper

}EmotionItem;

@interface Emotion : NSObject

@property (assign) EmotionItem *emotionItem;


@end
