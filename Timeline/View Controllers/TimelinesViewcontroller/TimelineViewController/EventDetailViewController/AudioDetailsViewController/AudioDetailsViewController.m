//
//  AudioDetailsViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 07/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "AudioDetailsViewController.h"


@interface AudioDetailsViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)playButton:(id)sender;
- (IBAction)pauseButton:(id)sender;
- (IBAction)stopButton:(id)sender;

@end

@implementation AudioDetailsViewController

@synthesize delegate = _delegate;
@synthesize navBar = _navBar;

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"microphone.png"]];
    
    //Disable pause and stop button
    self.pauseButton.enabled = NO;
    self.stopButton.enabled = NO;
    
    //Define the error variable
    NSError *error;
    
    //Initialize the audio player with the URL
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.urlPath] error:&error];
    
    //Set the delegate
    self.audioPlayer.delegate = self;
    
    //Prepare the audio player to play
    [self.audioPlayer prepareToPlay];
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
    
    //If the player is playing while 'done' is pressed
    if ([self.audioPlayer isPlaying]){
        //Stop playing
        [self.audioPlayer stop];
        //Hide the info label
        self.infoLabel.hidden = YES;
        
    }
    
    //Tells the delegate to dismiss the view controller
    [self.delegate dismissModalViewController];
}

- (IBAction)playButton:(id)sender{
    
    //Play
    [self.audioPlayer play];
    
    //Set the info Label
    self.infoLabel.text = @"Playing...";
    
    //Enable pause and stop button
    self.pauseButton.enabled = YES;
    self.stopButton.enabled = YES;
}

- (IBAction)pauseButton:(id)sender{
        
    //pause playing
    [self.audioPlayer pause];
    
    //Set the info label
    self.infoLabel.text = @"Pause";
    
    //Enable play and stop button
    self.playButton.enabled = YES;
    self.stopButton.enabled = YES;
}

- (IBAction)stopButton:(id)sender{
    
    //Stop playing
    [self.audioPlayer stop];
    
    //Set the info Label
    self.infoLabel.hidden = YES;
    
    //Enable play button
    self.playButton.enabled = YES;
    self.pauseButton.enabled = NO;
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    self.stopButton.enabled = NO;
    self.pauseButton.enabled = NO;
    //Hide the info label
    self.infoLabel.hidden = YES;
}

-(void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Decode Error occurred");
}


@end
