//
//  EventDetailViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 24/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import "TimelineViewCell.h"
#import "NoteCell.h"
#import "PictureViewCell.h"
#import "VideoViewCell.h"
#import "AudioViewCell.h"
#import "EmotionViewCell.h"
#import "Event.h"
#import "NewNoteViewController.h"
#import "SampleNote.h"
#import "SimplePicture.h"
#import "SimpleVideo.h"
#import "SimpleRecording.h"
#import "Emotion.h"
#import "PictureDetailsViewController.h"
#import "VideoDetailsViewController.h"
#import "AudioDetailsViewController.h"
#import "ShareEventViewController.h"
#import "XMPPRequestController.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 260.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_MARGIN_X 10.0f
#define CELL_CONTENT_MARGIN_Y 10.0f
#define CELL_HEIGHT 55.0f

#define PICTURECELL_SIZE 200.0f
#define AUDIOCELL_SIZE 130.0f;

@interface EventDetailViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (weak, nonatomic) IBOutlet UILabel *eventCreatorLabel;
@property (strong, nonatomic) NSIndexPath *indexPath;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;
- (IBAction)showEventItemDetails:(UITapGestureRecognizer *)recognizer;
- (void)performReverseGeocoding;

@end

@implementation EventDetailViewController

@synthesize delegate = _delegate;
@synthesize event = _event;
@synthesize navigationBar = _navigationBar;
@synthesize eventDateLabel = _eventDateLabel;
@synthesize eventLocationLabel = _eventLocationLabel;
@synthesize itemsTableView = _itemsTableView;
@synthesize indexPath = _indexPath;

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
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
    
    //Set the date label of the event
    self.eventDateLabel.text = [Utility dateDescriptionForEventDetailsWithDate:self.event.date];
    
    //Set the location label of the event
    [self performReverseGeocoding];
    
    //Set the event creator
    self.eventCreatorLabel.text = self.event.creator;
    
    //Make rounded corner to the tableview
    self.itemsTableView.clipsToBounds = YES;
    self.itemsTableView.layer.cornerRadius = 7.0;
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
#pragma mark Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //If New Note
    if ([segue.identifier isEqualToString:@"newNoteToEventSegue"]) {
        
        NewNoteViewController *nnvc = (NewNoteViewController *)segue.destinationViewController;
        nnvc.delegate = self;
        nnvc.baseEvent = self.event;
    }
    
    //If a picture detail
    else if ([segue.identifier isEqualToString:@"pictureDetailsSegue"]){
        
        //Get the controller
        PictureDetailsViewController *pdvc = (PictureDetailsViewController *)segue.destinationViewController;
        //Set the delegate
        pdvc.delegate = self;
        //Set the image
        pdvc.img = ((SimplePicture *)[self.event.eventItems objectAtIndex:self.indexPath.row]).image;
        
    }
    
    //If a picture detail
    else if ([segue.identifier isEqualToString:@"videoDetailsSegue"]){
        
        //Get the controller
        VideoDetailsViewController *vdvc = (VideoDetailsViewController *)segue.destinationViewController;
        //Set the delegate
        vdvc.delegate = self;
        //Set the image
        vdvc.urlPath = ((SimpleVideo *)[self.event.eventItems objectAtIndex:self.indexPath.row]).videoURL;
        
    }
    
    
    //If a picture detail
    else if ([segue.identifier isEqualToString:@"audioDetailsSegue"]){
        
        //Get the controller
        AudioDetailsViewController *advc = (AudioDetailsViewController *)segue.destinationViewController;
        //Set the delegate
        advc.delegate = self;
        
        //Set the audio
        advc.urlPath = ((SimpleRecording *)[self.event.eventItems objectAtIndex:self.indexPath.row]).urlPath;
        
    }
    
    //If sharing an eventItem
    else if ([segue.identifier isEqualToString:@"shareEventIdentifier"]){
        
        //Get the destination view controller
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        //Get the controller to show
        ShareEventViewController *sevc = (ShareEventViewController *) [navController.viewControllers objectAtIndex:0];
        //Set the delegate
        sevc.delegate = self;
        //Set the sharing delegate
        sevc.sharingDelegate = self;
    }
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)doneButtonPressed:(id)sender{
    
    [self.delegate dismissModalViewControllerAndUpdate];
}

- (IBAction)shareButtonPressed:(id)sender{
    
    if ([Utility isHostReachable] && [Utility isUserAuthenticatedOnXMPPServer]) {
        [self performSegueWithIdentifier:@"shareEventIdentifier" sender:self];
    }
    else{
        [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"Not connected to the Mirror Space Service" cancelButtonTitle:@"Dismiss"];
    }
}

//This method is used to show the eventItem detail when the tap  is recognized
- (IBAction)showEventItemDetails:(UITapGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        //Get the point tapped if in table view
        CGPoint p = [recognizer locationInView:self.itemsTableView];
        
        //Get the index
        NSIndexPath *indexPath = [self.itemsTableView indexPathForRowAtPoint:p];
        self.indexPath = indexPath;
        
        //Get the cell
        UITableViewCell *cell = [self.itemsTableView cellForRowAtIndexPath:indexPath];
        
        //If the cell contains a picture
        if ([cell isMemberOfClass:[PictureViewCell class]]){
            [self performSegueWithIdentifier:@"pictureDetailsSegue" sender:self];
        }
        
        //If the cell contains a picture
        if ([cell isMemberOfClass:[VideoViewCell class]]){
            [self performSegueWithIdentifier:@"videoDetailsSegue" sender:self];
        }
        
        //If the cell contains a picture
        else if ([cell isMemberOfClass:[AudioViewCell class]]){
            [self performSegueWithIdentifier:@"audioDetailsSegue" sender:self];
        }

    }
}

#pragma mark -
#pragma mark Private Methods

- (void)performReverseGeocoding{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //Perform the reverse geocoding based on the annotation coordinate
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.event.location.coordinate.latitude longitude:self.event.location.coordinate.longitude] completionHandler:
     
     ^(NSArray* placemarks, NSError* error){
         //If the reverse geocoding went ok
         if ([placemarks count]>0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             //Get the name of the address
             NSString *address = [placemark.addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
             //Get the name of the city
             NSString *city = placemark.locality;
             
             //Set the label with address and city
             self.eventLocationLabel.text = [NSString stringWithFormat:@"%@,%@",address,city];
         }
         //If the reverse geocoding went wrong
         if (error) {
             //Set the error message
             self.eventLocationLabel.text = @"Unable to retrieve the location";
         }
     }];
}

#pragma mark -
#pragma mark ModalViewControllerDelegate

- (void)dismissModalViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addEventItem:(id)sender toBaseEvent:(BaseEvent *)baseEvent{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.event.eventItems addObject:sender];
        [self.itemsTableView reloadData];
    }];
}

#pragma mark -
#pragma mark SharingViewControllerDelegate

- (void)shareEventToSpaceWithId:(NSString *)spaceId{
    [self dismissViewControllerAnimated:YES completion:^{
        XMPPRequestController *rc = [Utility xmppRequestController];
        [rc sendEventItem:self.event toSpaceWithId:spaceId];
    }];
}


#pragma mark -
#pragma mark UITablewViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.event.eventItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Get the object at the specified index path
    id objectInTimeline = [self.event.eventItems objectAtIndex:indexPath.row];
        
    TimelineViewCell *cell = nil;
    
    UIEdgeInsets insets;
    insets.top = 37;
    insets.left = 0;
    insets.bottom = 37;
    insets.right = 0;
    
    UIImage *backgroundImg = [[UIImage imageNamed:@"eventItemContainer.png"] resizableImageWithCapInsets:insets];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:backgroundImg];
    
    //If the cell will contain a note
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"noteCellIdentifier"];
        
        //Get the size of the text in order to set the label frame
        CGSize size = [Utility sizeOfText:((SampleNote *)objectInTimeline).noteText width:CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) fontSize:FONT_SIZE];

#warning handle multivalue values label
        //Set the text
        ((NoteCell *)cell).contentLabel.text  = ((SampleNote *)objectInTimeline).noteText;
        
        //Set the new frame for the cell label
        [((NoteCell *)cell).contentLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN_X, CELL_CONTENT_MARGIN_Y, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, CELL_HEIGHT))];
        
        cell.backgroundView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, CELL_CONTENT_WIDTH, MAX(size.height, CELL_HEIGHT));
        
        cell.backgroundView = iv;
    }
    //If the cell contains a picture
    else if([objectInTimeline isMemberOfClass:[SimplePicture class]]){
        
        //Get a reusable cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"pictureCellIdentifier"];
        //Se the image for the cell
        ((PictureViewCell *)cell).pictureImageView.image = ((SimplePicture *)objectInTimeline).image;
    }
    
    //If the cell contains a video
    else if([objectInTimeline isMemberOfClass:[SimpleVideo class]]){
        
        //Get a reusable cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"videoCellIdentifier"];
        //Se the image for the cell
        ((VideoViewCell *)cell).videoImageView.image = ((SimpleVideo *)objectInTimeline).videoThumbnail;
    }

    
    //If the cell contains a picture
    else if([objectInTimeline isMemberOfClass:[SimpleRecording class]]){
        
        //Get a reusable cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"audioCellIdentifier"];
    }
    
    //If the cell contains an emoticon
    else if([objectInTimeline isMemberOfClass:[Emotion class]]){
        
        //Get a reusable cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"emotionCellIdentifier"];
       
        ((EmotionViewCell *)cell).emotionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[((Emotion *)objectInTimeline) emotionImagePath]]];
    }

    
    //No of the above specified objects
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCellIndentifier"];
    }
    
    //Disable selection style for the cell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Get the object at the specified index path
    id objectInTimeline = [self.event.eventItems objectAtIndex:indexPath.row];
    
    CGFloat height;
    
    //If the object is a Note
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        //Get the size of the text
        CGSize size = [Utility sizeOfText:((SampleNote *)objectInTimeline).noteText width:CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) fontSize:FONT_SIZE];
        
        //Get the height for the row
        height = MAX(size.height, CELL_HEIGHT) + (CELL_CONTENT_MARGIN * 2) + CELL_CONTENT_MARGIN_Y;
    }
    else if ([objectInTimeline isMemberOfClass:[SimplePicture class]]){
        height = PICTURECELL_SIZE;
    }
    
    else if ([objectInTimeline isMemberOfClass:[SimpleVideo class]]){
        height = PICTURECELL_SIZE;
    }
    
    else if ([objectInTimeline isMemberOfClass:[SimpleRecording class]]){
        height = AUDIOCELL_SIZE;
    }
    
    else if ([objectInTimeline isMemberOfClass:[Emotion class]]){
        height = AUDIOCELL_SIZE;
    }
     
    return height;
     
}

@end
