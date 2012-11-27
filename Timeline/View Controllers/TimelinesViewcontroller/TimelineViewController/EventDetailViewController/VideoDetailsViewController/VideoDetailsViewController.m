//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  VideoDetailsViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 07/11/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "VideoDetailsViewController.h"

@interface VideoDetailsViewController ()

@property (strong, nonatomic) MPMoviePlayerController *mpc;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation VideoDetailsViewController

@synthesize delegate = _delegate;
@synthesize urlPath = _urlPath;

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

    MPMoviePlayerController *mpmpc = [[MPMoviePlayerController alloc] initWithContentURL:self.urlPath];
    self.mpc = mpmpc;
    //Set the position and size of the player
    self.mpc.view.frame = CGRectMake(0, 44, 320, 420);
    //Content mode aspect to fit
    self.mpc.view.contentMode = UIViewContentModeScaleAspectFit;
    //Prepare the player to play
    [self.mpc prepareToPlay];
    //Add the moview player view to the alert view
    [self.view addSubview:self.mpc.view];
    
    //Add the observer that notifies when the player is ready
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToPlay:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.mpc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Used to play the video when it is buffered
- (void)readyToPlay:(NSNotification *)notification{
    //Start the video
    [self.mpc play];
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)doneButtonPressed:(id)sender{
    [self.mpc stop];
    //Tells the delegate to dismiss the view controller
    [self.delegate dismissModalViewController];
}

@end
