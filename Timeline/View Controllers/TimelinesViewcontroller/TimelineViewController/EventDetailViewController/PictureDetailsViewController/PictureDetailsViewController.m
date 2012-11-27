//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  PictureDetailsViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 05/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "PictureDetailsViewController.h"

@interface PictureDetailsViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

- (IBAction)doneButtonPressed:(id)sender;

@end

@implementation PictureDetailsViewController

@synthesize delegate = _delegate;
@synthesize navBar = _navBar;
@synthesize img = _img;

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
	// Do any additional setup after loading the view.
    
    //Set the background image for the navigation bar
    [self.navBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
    
    //Set the image
    self.imgView.image = self.img;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)doneButtonPressed:(id)sender{
    
    //Tells the delegate to dismiss the view controller
    [self.delegate dismissModalViewController];
}

@end
