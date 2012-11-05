//
//  TimelineViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TimelineViewController.h"
#import "Reachability.h"
#import "DBController.h"
#import "NewNoteViewController.h"
#import "AudioViewController.h"
#import "Timeline.h"
#import "Event.h"
#import "SampleNote.h"
#import "TimelineViewCell.h"
#import "PictureViewCell.h"
#import "VideoViewCell.h"
#import "NoteCell.h"
#import "AppDelegate.h"
#import "XMPPRequestController.h"
#import "EventDetailViewController.h"
#import "SimplePicture.h"
#import "SimpleVideo.h"
#import "SimpleRecording.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 235.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_MARGIN_X 35.0f
#define CELL_CONTENT_MARGIN_Y 35.0f
#define CELL_HEIGHT 75.0f

#define PICTURECELL_SIZE 200.0f
#define AUDIOCELL_SIZE 130.0f;

@interface TimelineViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedRow;
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (assign) BOOL newMedia;
@property (assign) BOOL mediaTypePicture;

- (CGSize)sizeOfText:(NSString *)text;
- (IBAction)showInfoDetails:(UILongPressGestureRecognizer *)recognizer;
- (IBAction)pictureButtonPressed:(id)sender;
- (IBAction)videoButtonPressed:(id)sender;
- (IBAction)audioButtonPressed:(id)sender;
- (void)fetchEventsFromDB;

@end

@implementation TimelineViewController

@synthesize contentTableView = _contentTableView;
@synthesize pictureButton = _pictureButton;
@synthesize eventsArray = _eventsArray;
@synthesize indexPathForSelectedRow = _indexPathForSelectedRow;
@synthesize newMedia = _newMedia;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    
    //Register itself as observer for the XMPP RequestController
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAI:) name:@"DismissActivityIndicatorNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertEvent:) name:@"EventDidLoadNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimelineWithEvent:) name:@"UpdateTimelineNotification" object:nil];
    
    //Set the background image for the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
    
    //Set a clear view to remove the line separator when the cells are empty
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    v.backgroundColor = [UIColor clearColor];
    [self.contentTableView setTableFooterView:v];
    
    if ([Utility isHostReachable] && [Utility isUserAuthenticatedOnXMPPServer]) {
        //Get the xmpp controller
        XMPPRequestController *rc = [Utility xmppRequestController];
        //Retrieve all the items for the timeline (space)
        [rc retrieveAllItemsForSpace:self.timeline.tId];
        [Utility showActivityIndicatorWithView:self.view label:@"Loading Info..."];
    }
    else{
        [self fetchEventsFromDB];
    }
    
    
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
#pragma mark Lazy Instantiation

- (NSMutableArray *)eventsArray{
    if (!_eventsArray) {
        _eventsArray = [[NSMutableArray alloc] init];
    }
    return _eventsArray;
}


#pragma mark -
#pragma mark Segue Method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //If new note view controller is called
    if ([segue.identifier isEqualToString:@"newNoteIdentifier"]) {
        
        NewNoteViewController *nnvc = (NewNoteViewController *) segue.destinationViewController;
        nnvc.delegate = self;
        nnvc.baseEvent = nil;
    }
    //If the user wants to record a new audio
    else if ([segue.identifier isEqualToString:@"newAudioSegue"]){
        
        AudioViewController *navc = (AudioViewController *)segue.destinationViewController;
        navc.delegate = self;
    }
    
    //If info details view has to be shown
    else if ([segue.identifier isEqualToString:@"eventDetailsSegue"]){
        
        NSIndexPath *indexPath = self.indexPathForSelectedRow;
        EventDetailViewController *edvc = (EventDetailViewController *)segue.destinationViewController;
        edvc.delegate = self;
        edvc.event = [self.eventsArray objectAtIndex:indexPath.row];
    }
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)showInfoDetails:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [recognizer locationInView:self.contentTableView];
        
        NSIndexPath *indexPath = [self.contentTableView indexPathForRowAtPoint:p];
        if (indexPath){
            self.indexPathForSelectedRow = indexPath;
            [self performSegueWithIdentifier:@"eventDetailsSegue" sender:self];
        }
        
    }
}

- (IBAction)videoButtonPressed:(id)sender{
    
    self.mediaTypePicture = NO;
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Record a video",@"Choose from library...", nil];
    
    //Show the actionsheet
    [as showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)pictureButtonPressed:(id)sender{
    
    //Set the actionshett to let the user choose between taking a picture or choosing from the library
    self.mediaTypePicture = YES;
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a picture",@"Choose from library...", nil];
    
    //Show the actionsheet
    [as showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)audioButtonPressed:(id)sender{
    
    [self performSegueWithIdentifier:@"newAudioSegue" sender:self];
}

#pragma mark -
#pragma mark DismissActivityIndicatorNotification

//This method is used to dismiss the activity indicator once the information is fetched
- (void)dismissAI:(NSNotification *)notification{
    
    [Utility dismissActivityIndicator:self.view];
}

#pragma mark -
#pragma mark EventDidLoadNotification

- (void)insertEvent:(NSNotification *)notification{
    
    //Get the event from the notification
    Event *event = [notification.userInfo objectForKey:@"userInfo"];
    
    //Insert the object at the beginning of the array
    [self.eventsArray insertObject:event atIndex:0];
    
    //Order the array based on the date
    [Utility sortArray:self.eventsArray withKey:@"date" ascending:NO];
    
    
    //Update the TableView
    [self.contentTableView reloadData];
}

#pragma mark -
#pragma mark UpdateTimelineNotification

- (void)updateTimelineWithEvent:(NSNotification *)notification{
    
    //Get the nodeId
    NSString *nodeId = [notification.userInfo objectForKey:@"nodeId"];
    
    NSString *nId = [NSString stringWithFormat:@"%@#%@",[[nodeId componentsSeparatedByString:@"#"] objectAtIndex:1],[[nodeId componentsSeparatedByString:@"#"] objectAtIndex:2]];
    
    //If team#xx == team#xx (spaces#team#xx)
    if ([self.timeline.tId isEqualToString:nId]) {
        //Get the event from the notification
        Event *event = [notification.userInfo objectForKey:@"userInfo"];
        
        //Insert the object at the beginning of the array
        [self.eventsArray insertObject:event atIndex:0];
        
        //Order the array based on the date
        [Utility sortArray:self.eventsArray withKey:@"date" ascending:NO];
        
        //Get the index of the object
        NSUInteger index = [self.eventsArray indexOfObject:event];
        
        //Set the insert indexpath
        NSArray *insertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
        
        [self.contentTableView beginUpdates];
        //Insert the data in tableview animated
        [self.contentTableView insertRowsAtIndexPaths:insertIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.contentTableView endUpdates];
    }
}

#pragma mark -
#pragma mark ModalViewControllerDelegate

- (void)dismissModalViewController{
    //Dismiss the presented view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissModalViewControllerAndUpdate{
    //Dismiss the presented view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.contentTableView reloadData];
}

- (void)addEventItem:(id)sender toBaseEvent:(BaseEvent *)baseEvent{
    //Dismiss the presented view controller
    [self dismissViewControllerAnimated:YES completion:^{
        
        //If baseEvent not exist make it
        if (baseEvent==nil) {
            Event *event = nil;
            
            //New BaseEvent
            event = [[Event alloc] initEventWithLocation:((AppDelegate *)[[UIApplication sharedApplication] delegate]).userLocation date:[NSDate date] shared:NO creator:[Utility settingField:kXMPPUserIdentifier]];
            
            //Add the object to the base event
            [event.eventItems addObject:sender];
            
            //If there's connectivity
            if ([Utility isHostReachable]){
                
                //If the user is authenticated on the XMPP Server
                if ([Utility isUserAuthenticatedOnXMPPServer]){
                    
                    //Set the event stored
                    event.stored = YES;
                    event.post = YES;
                    
                    //Get the XMPPRequestController
                    XMPPRequestController *rc = [Utility xmppRequestController];
                    [rc sendEventItem:event toSpaceWithId:self.timeline.tId];
                    
                }
                //Otherwise
                else{
                   // [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Not connected to the Mirror Space Service" cancelButtonTitle:@"Dismiss"];
                }
            }
            //If there's no connection
            else{
                
                //Set the key Share to YES in the standard user defaults 
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Share"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                event.stored = NO;
                event.post = NO;
                
                //Insert the object at the beginning of the array
                [self.eventsArray insertObject:event atIndex:0];
                
                //Update the TableView (If when connection duplicate on tableview)
                [self.contentTableView reloadData];
  
                
              //  [Utility showAlertViewWithTitle:@"Connection Error" message:@"Not Connected to a Network" cancelButtonTitle:@"Dismiss"];
            }
                       
            //Update the DB
            [[Utility databaseController] insertEvent:event inTimeline:self.timeline];
            
        }
    }];
}

#pragma mark -
#pragma mark Private Methods

//This method is used to get the size of a string based on the font used
- (CGSize)sizeOfText:(NSString *)text{
    
    //Set the constraint where the text is put
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    //Compute the size of the text
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return size;
}

- (void)fetchEventsFromDB{
   
    self.eventsArray = [[Utility databaseController] fetchEventsFromDBForTimelineId:self.timeline];
    
    //Order the array based on the date
    [Utility sortArray:self.eventsArray withKey:@"date" ascending:NO];
    
    //Update the TableView
    [self.contentTableView reloadData];
    
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //If the user wants to take a picture or record a video
    if (buttonIndex==0) {
        //Save it in the phone
        self.newMedia = YES;
        
        //If the user wants to take a still picture
        if (self.mediaTypePicture) {
            [self presentModalViewController:[Utility imagePickerControllerWithDelegate:self media:(NSString *) kUTTypeImage] animated:YES];
        }
        //If the user wants to record a video
        else{
            [self presentModalViewController:[Utility imagePickerControllerWithDelegate:self media:(NSString *) kUTTypeMovie] animated:YES];
        }
        
    }
    
    //If the user want to choose a picture or video from the device album
    if (buttonIndex==1) {
        self.newMedia = NO;
        
        //If the user wants to choose a still picture
        if (self.mediaTypePicture) {
            [self presentModalViewController:[Utility imagePickerControllerForLibraryWithDelegate:self media:(NSString *) kUTTypeImage] animated:YES];
        }
        //If the user wants to choose a video
        else{
            [self presentModalViewController:[Utility imagePickerControllerForLibraryWithDelegate:self media:(NSString *) kUTTypeMovie] animated:YES];
        }
    }
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *originalImage = (UIImage *) [info objectForKey:
                                          UIImagePickerControllerOriginalImage];
    NSURL *videoURL;
    SimplePicture *sp = nil;
    SimpleVideo *sv = nil;
    
    //If a new picture has taken save in the photoalbum
    if (self.newMedia) {
        //Save the photo in the Photoalbum
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        // Request to save the image to camera roll
        [library writeImageToSavedPhotosAlbum:[originalImage CGImage] orientation:(ALAssetOrientation)[originalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                NSLog(@"error");
            } else {
                NSLog(@"url %@", assetURL);
            }  
        }];  
       
        
        //UIImageWriteToSavedPhotosAlbum (originalImage, nil, nil , nil);
    }

    
    //Get the mediaType
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    //If Media is an image
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        //Get the original image (without editing)
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        //Resize the picture to its 5%
        UIImage *small = [UIImage imageWithCGImage:originalImage.CGImage scale:8 orientation:originalImage.imageOrientation];
        
        //Get the new image compressed
        small = [Utility imageWithImage:small scaledToSize:small.size];
                
        //Initialize a SimplePicture object
        //sp = [[SimplePicture alloc] initSimplePictureWithImage:small eventItemCreator:nil];
#warning no eventID
        sp = [[SimplePicture alloc] initSimplePictureWithEventId:nil image:small eventItemCreator:nil];
        
        //Tells the delegate to perform a task with the object received
        [self addEventItem:sp toBaseEvent:nil];

    }
    
    //If Media is a video
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        //Get the url of the video
        videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        //Initialize a SimpleVideo object
      //  sv = [[SimpleVideo alloc] initSimpleVideoWithURL:videoURL eventItemCreator:nil];
        sv = [[SimpleVideo alloc] initSimpleVideoWithEventId:nil URL:videoURL eventItemCreator:nil];
        //Tells the delegate to perform a task with the object received
        [self addEventItem:sv toBaseEvent:nil];
        
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Event *event = [self.eventsArray objectAtIndex:indexPath.row];
    
    //Get the object at the specified index path
    id objectInTimeline = [event.eventItems objectAtIndex:0];
    
    TimelineViewCell *cell = nil;
    
    UIEdgeInsets insets;
    insets.top = 37;
    insets.left = 0;
    insets.bottom = 37;
    insets.right = 0;
    
    UIImage *backgroundImg = [[UIImage imageNamed:@"cellContainer.png"] resizableImageWithCapInsets:insets];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:backgroundImg];

    if ([event.eventItems count]>1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"folderCellIndentifier"];
        cell.backgroundView = iv;
    }
    else{
        
        //If the cell will contain a note
        if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"noteCellIndentifier"];
            
            //Get the size of the text in order to set the label frame
            CGSize size = [self sizeOfText:((SampleNote *)objectInTimeline).noteText];
#warning handle multivalue values label
            //Set the text
            ((NoteCell *)cell).contentLabel.text  = ((SampleNote *)objectInTimeline).noteText;
            
            //Set the new frame for the cell label
            [((NoteCell *)cell).contentLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN_X, CELL_CONTENT_MARGIN_Y, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, CELL_HEIGHT))];
           
            cell.backgroundView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, CELL_CONTENT_WIDTH, MAX(size.height, CELL_HEIGHT));
            cell.backgroundView = iv;
        }
        //If it is a picture
        else if ([objectInTimeline isMemberOfClass:[SimplePicture class]]){
            
            //Get a reusable cell
            cell = [tableView dequeueReusableCellWithIdentifier:@"pictureCellIdentifier"];
            
            //Set the image for the cell
            ((PictureViewCell *)cell).pictureImageView.image = ((SimplePicture *)objectInTimeline).image;
            
            //Set the background for the cell
            cell.backgroundView = iv;
        }
        
        else if ([objectInTimeline isMemberOfClass:[SimpleVideo class]]){
            
            //Get a reusable cell
            cell = [tableView dequeueReusableCellWithIdentifier:@"videoCellIdentifier"];
            
            ((VideoViewCell *)cell).videoImageView.image = ((SimpleVideo *)objectInTimeline).videoThumbnail;
            
            //Set the background for the cell
            cell.backgroundView = iv;
        }
        
        else if ([objectInTimeline isMemberOfClass:[SimpleRecording class]]){
            
            //Get a reusable cell
            cell = [tableView dequeueReusableCellWithIdentifier:@"audioCellIdentifier"];
            
            //Set the background for the cell
            cell.backgroundView = iv;
        }
            
        //No of the above specified objects
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCellIndentifier"];
        }
    }
    
    if (cell) {
       cell.timestampLabel.text = [Utility dateTimeDescriptionWithLocaleIdentifier:event.date];
    }
    
    //Set the cell not selectable
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - 
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Event *event = [self.eventsArray objectAtIndex:indexPath.row];
    
    //Get the object at the specified index path
    id objectInTimeline = [event.eventItems objectAtIndex:0];
    
    
    CGFloat height;
    
    //If the object is a Note
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        //Get the size of the text
        CGSize size = [self sizeOfText:((SampleNote *)objectInTimeline).noteText];
        
        //Get the height for the row
        height = MAX(size.height, CELL_HEIGHT) + (CELL_CONTENT_MARGIN * 2) + CELL_CONTENT_MARGIN_Y;
    }
    //If the cell contains a picture
    else if ([objectInTimeline isMemberOfClass:[SimplePicture class]]){
        height = PICTURECELL_SIZE;
    }
    
    else if ([objectInTimeline isMemberOfClass:[SimpleVideo class]]){
        height = PICTURECELL_SIZE;
    }
    
    else if ([objectInTimeline isMemberOfClass:[SimpleRecording class]]){
        height = AUDIOCELL_SIZE;
    }
     
    //Return the height for the cell
    return height;
    
}

@end
