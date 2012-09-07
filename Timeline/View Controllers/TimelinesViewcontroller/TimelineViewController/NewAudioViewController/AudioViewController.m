//
//  NewAudioViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 06/09/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "NewAudioViewController.h"
#import "SimpleRecording.h"

@interface NewAudioViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (assign) BOOL isRecorded;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)startButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;

@end

@implementation NewAudioViewController

@synthesize delegate = _delegate;

@synthesize infoLabel = _infoLabel;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize recordButton = _recordButton;
@synthesize stopButton = _stopButton;

@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;

@synthesize isRecorded = _isRecorded;

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
    
   
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]];
    NSLog(@"Path: %@",soundFilePath);
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0], 
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    
    //Initialize the AVAudioRecorder
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    self.audioRecorder.delegate = self;
    
    if (!error) {
        [self.audioRecorder prepareToRecord];
    }
    else{
        [Utility showAlertViewWithTitle:@"TimelineApp Error" message:@"Error Recording Audio. Please try again" cancelButtonTitle:@"Dismiss"];
    }
    
    [self.stopButton setEnabled:NO];
    [self.pauseButton setEnabled:NO];
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

- (IBAction)cancelButtonPressed:(id)sender{
    
    //Tells the delegate to dismiss the presented modal view controller
    [self.delegate dismissModalViewController];
}

- (IBAction)doneButtonPressed:(id)sender{
    
    if (self.isRecorded) {
        
        //Initialize the SimpleRecording data
        SimpleRecording *sr = [[SimpleRecording alloc] initSimpleRecordingWithURLPath:[self.audioRecorder.url absoluteString] eventCreator:nil];
        
        //Tells the delegate to perform a task with the object received
        [self.delegate addEventItem:sr toBaseEvent:nil];
    }
    
    
}

- (IBAction)startButtonPressed:(id)sender{
    //Start recording if it is not
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];
        self.infoLabel.hidden = NO;
        if (self.playButton.hidden==NO) {
            [self.playButton setEnabled:NO];
        }
        [self.stopButton setEnabled:YES];
    }
   }

- (IBAction)stopButtonPressed:(id)sender{
    
    //Set the stop button enabled
    [self.stopButton setEnabled:NO];
    //Set the play button enabled
    [self.playButton setEnabled:YES];
    //Set the record button enabled
    [self.recordButton setEnabled:YES];
    //Set the pause button
    [self.pauseButton setEnabled:NO];
    
    //Stop recording if it is doing so
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
    }
    //If the player is playing stop
    else if ([self.audioPlayer isPlaying]){
        [self.audioPlayer stop];
    }
    
}

- (IBAction)playButtonPressed:(id)sender{
    self.infoLabel.text = @"Playing...";
    self.infoLabel.hidden = NO;
    
    //Set the record button disabled
    [self.recordButton setEnabled:NO];
    //Set the stop button enabled
    [self.stopButton setEnabled:YES];
    //Set the pause button enabled
    [self.pauseButton setEnabled:YES];
       
    NSError *error;
    
    self.audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:self.audioRecorder.url
                   error:&error];
    
    self.audioPlayer.delegate = self;
    
    if (error)
        NSLog(@"Error: %@",
              [error localizedDescription]);
    else
        [self.audioPlayer play];
}

- (IBAction)pauseButtonPressed:(id)sender{
 
    //Set the info label to 'Pause'
    self.infoLabel.text = @"Pause";
    
    //Pause
    [self.audioPlayer pause];
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    //Show play and pause button
    self.playButton.hidden = NO;
    self.pauseButton.hidden = NO;
    //Hide the info label
    self.infoLabel.hidden = YES;
    
    self.isRecorded = YES;
    
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"Encode Error occurred");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self.recordButton setEnabled:YES];
    [self.stopButton setEnabled:NO];
    [self.pauseButton setEnabled:NO];
    //Hide the info label
    self.infoLabel.hidden = YES;
}

-(void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Decode Error occurred");
}

@end
