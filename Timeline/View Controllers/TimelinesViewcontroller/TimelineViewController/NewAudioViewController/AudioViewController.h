//
//  NewAudioViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 06/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ModalViewControllerDelegate.h"

@interface NewAudioViewController : UIViewController <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;

@end
