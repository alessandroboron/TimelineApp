//
//  AudioDetailsViewController.h
//  Timeline
//
//  Created by Alessandro Boron on 07/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ModalViewControllerDelegate.h"

@interface AudioDetailsViewController : UIViewController <AVAudioPlayerDelegate>

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *urlPath;

@end
