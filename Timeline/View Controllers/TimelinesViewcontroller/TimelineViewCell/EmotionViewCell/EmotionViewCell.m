//
//  EmotionViewCell.m
//  Timeline
//
//  Created by Alessandro Boron on 05/11/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "EmotionViewCell.h"

@implementation EmotionViewCell

@synthesize emotionImageView = _emotionImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
