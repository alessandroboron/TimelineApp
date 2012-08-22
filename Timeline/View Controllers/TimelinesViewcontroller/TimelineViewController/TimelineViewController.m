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
#import "watchIt.h"
#import "TimelineViewCell.h"
#import "NoteCell.h"
#import "AppDelegate.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 235.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_MARGIN_X 35.0f
#define CELL_CONTENT_MARGIN_Y 35.0f
#define CELL_HEIGHT 75.0f

@interface TimelineViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

- (CGSize)sizeOfText:(NSString *)text;

@end

@implementation TimelineViewController

@synthesize contentTableView = _contentTableView;
@synthesize eventsArray = _eventsArray;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
    
    //Set a clear view to remove the line separator when the cells are empty
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    v.backgroundColor = [UIColor clearColor];
    [self.contentTableView setTableFooterView:v];
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
    
    if ([segue.identifier isEqualToString:@"newNoteIdentifier"]) {
        
        NewNoteViewController *nnvc = (NewNoteViewController *) segue.destinationViewController;
        nnvc.delegate = self;
        nnvc.baseEvent = nil;
    }
}

#pragma mark -
#pragma mark ModalViewControllerDelegate

- (void)dismissModalViewController{
    //Dismiss the presented view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addEventItem:(id)sender toBaseEvent:(BaseEvent *)baseEvent{
    //Dismiss the presented view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //If baseEvent not exist make it
    if (baseEvent==nil) {
        Event *event = nil;
        if (![sender isMemberOfClass:[WatchIt class]]) {
            //New BaseEvent
            event = [[Event alloc] initEventWithLocation:((AppDelegate *)[[UIApplication sharedApplication] delegate]).userLocation date:[NSDate date] shared:NO creator:nil];
        }
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
    
    if ([event.eventItems count]>1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"folderCellIndentifier"];
    }
    else{
        
        //If the cell will contain a note
        if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"noteCellIndentifier"];
            
            //Get the size of the text in order to set the label frame
            CGSize size = [self sizeOfText:((SampleNote *)objectInTimeline).noteText];
            
            //Set the text
            ((NoteCell *)cell).contentLabel.text  = ((SampleNote *)objectInTimeline).noteText;
            
            //Set the new frame for the cell label
            [((NoteCell *)cell).contentLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN_X, CELL_CONTENT_MARGIN_Y, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, CELL_HEIGHT))];
           
            UIEdgeInsets insets;
            insets.top = 37;
            insets.left = 0;
            insets.bottom = 37;
            insets.right = 0;
            
            UIImage *backgroundImg = [[UIImage imageNamed:@"cellContainer.png"] resizableImageWithCapInsets:insets];
           
            UIImageView *iv = [[UIImageView alloc] initWithImage:backgroundImg];
           
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
