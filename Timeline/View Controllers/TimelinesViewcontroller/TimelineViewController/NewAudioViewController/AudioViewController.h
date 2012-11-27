//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
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

@interface AudioViewController : UIViewController <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) id<ModalViewControllerDelegate> delegate;

@end
