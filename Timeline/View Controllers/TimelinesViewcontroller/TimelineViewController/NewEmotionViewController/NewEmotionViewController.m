//
//  NewEmotionViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 05/11/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "NewEmotionViewController.h"
#import "Emotion.h"

@interface NewEmotionViewController ()

- (IBAction)emotionImageViewTapped:(UITapGestureRecognizer *)sender;

@end

@implementation NewEmotionViewController

@synthesize baseEvent = _baseEvent;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 300,self.view.bounds.size.width,self.view.bounds.size.height);
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)emotionImageViewTapped:(UITapGestureRecognizer *)sender{
    
    
   CGPoint location = [sender locationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateEnded){
        
        //Recognize which image has been tapped
        for (UIView *view in self.view.subviews){
            
            if ([view isKindOfClass:[UIImageView class]] && CGRectContainsPoint(view.frame, location)){
                UIImageView *imageView = (UIImageView *) view;
                
                EmotionItem ei;
                
                //According to the image tapped
                switch (imageView.tag) {
                    case 1:
                        ei = EventEmotionBad;
                        break;
                    case 2:
                        ei = EventEmotionOk;
                        break;
                    case 3:
                        ei = EventEmotionGood;
                        break;
                    case 4:
                        ei = EventEmotionSuper;
                        break;
                        
                    default:
                        ei = EventEmotionUnknown;
                        break;
                }
                
                //Initialize the emotion object
                Emotion *e = [[Emotion alloc] initEmotionWithEventId:self.baseEvent.baseEventId emotion:ei eventItemCreator:[Utility settingField:kXMPPUserIdentifier]];
                
                //Tells the delegate to perform a task with the object received
                [self.delegate addEventItem:e toBaseEvent:self.baseEvent];
            }
        }
    }
}

@end
