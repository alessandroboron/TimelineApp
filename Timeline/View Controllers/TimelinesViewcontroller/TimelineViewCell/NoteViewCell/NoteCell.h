//
//  NoteCell.h
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineViewCell.h"

@interface NoteCell : TimelineViewCell

@property (weak, nonatomic) IBOutlet UIImageView *tImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
