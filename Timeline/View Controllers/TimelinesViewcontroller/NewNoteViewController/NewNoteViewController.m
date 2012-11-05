//
//  NewNoteViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "NewNoteViewController.h"
#import "SampleNote.h"

@interface NewNoteViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end

@implementation NewNoteViewController

@synthesize delegate = _delegate;
@synthesize baseEvent = _baseEvent;
@synthesize navigationBar = _navigationBar;
@synthesize placeHolderLabel = _placeHolderLabel;
@synthesize contentTextView = _contentTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    //Remove the observer when dealloc the view controller
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Set the background image for the navigation bar
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Register itself as observer when the content TextView changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentTextViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    //Show the keyboard
    [self.contentTextView becomeFirstResponder];
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
#pragma mark Notification Methods

- (void)contentTextViewDidChange:(NSNotification *)notification{
    
    if (self.contentTextView.text.length == 0) {
        self.placeHolderLabel.hidden = NO;
    }
    else{
        self.placeHolderLabel.hidden = YES;
    }
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)cancelButtonPressed:(id)sender{
    //Tells the delegate to dismiss the view controller presented
    [self.delegate dismissModalViewController];
}

- (IBAction)saveButtonPressed:(id)sender{
    
    //Creates the SampleNote object
   // SampleNote *sn = [[SampleNote alloc] initSampleNoteWithTitle:self.contentTextView.text text:self.contentTextView.text eventItemCreator:nil];
    
    SampleNote *sn = [[SampleNote alloc] initSampleNoteWithEventId:self.baseEvent.baseEventId title:self.contentTextView.text text:self.contentTextView.text eventItemCreator:[Utility settingField:kXMPPUserIdentifier]];
    
    //Tells the delegate to perform a task with the object received
    [self.delegate addEventItem:sn toBaseEvent:self.baseEvent];
}

@end
