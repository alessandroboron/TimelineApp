//
//  TimelineViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 14/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "TimelineViewController.h"
#import "NewNoteViewController.h"
#import "Event.h"
#import "SampleNote.h"
#import "TimelineViewCell.h"
#import "NoteCell.h"
#import "AppDelegate.h"
#import "XMPPRequestController.h"
#import "EventDetailViewController.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 235.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_MARGIN_X 35.0f
#define CELL_CONTENT_MARGIN_Y 35.0f
#define CELL_HEIGHT 75.0f

@interface TimelineViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedRow;

- (CGSize)sizeOfText:(NSString *)text;
- (IBAction)showInfoDetails:(UILongPressGestureRecognizer *)recognizer;


@end

@implementation TimelineViewController

@synthesize contentTableView = _contentTableView;
@synthesize eventsArray = _eventsArray;
@synthesize indexPathForSelectedRow = _indexPathForSelectedRow;

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
    
    //Get the xmpp controller
    XMPPRequestController *rc = [Utility xmppRequestController];
    //Retrieve all the items for the timeline (space)
    [rc retrieveAllItemsForSpace:self.spaceId];
    [Utility showActivityIndicatorWithView:self.view label:@"Loading Info..."];
    
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
    if ([self.spaceId isEqualToString:nId]) {
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //If baseEvent not exist make it
    if (baseEvent==nil) {
        Event *event = nil;
        
        //New BaseEvent
        event = [[Event alloc] initEventWithLocation:((AppDelegate *)[[UIApplication sharedApplication] delegate]).userLocation date:[NSDate date] shared:NO creator:nil];
        
        //Add the object to the base event
        [event.eventItems addObject:sender];
        
        //Insert the object at the beginning of the array
        [self.eventsArray insertObject:event atIndex:0];
        
        //Update the TableView
        [self.contentTableView reloadData];
    }
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
    
    //Get the object in timeline
    //id objectInTimeline = [self.contentArray objectAtIndex:indexPath.row];
    
    //If the object is a Note
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        //Get the size of the text
        CGSize size = [self sizeOfText:((SampleNote *)objectInTimeline).noteText];
        
        //Get the height for the row
        height = MAX(size.height, CELL_HEIGHT) + (CELL_CONTENT_MARGIN * 2) + CELL_CONTENT_MARGIN_Y;
        
        //return height + (CELL_CONTENT_MARGIN * 2) + CELL_CONTENT_MARGIN_Y;
    }
    return height;
    /*
    else if ([objectInTimeline isMemberOfClass:[SamplePicture class]]){
        
    }
    */
}

@end
