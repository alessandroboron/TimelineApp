//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
//
//  ShareEventViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 27/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "ShareEventViewController.h"
#import "XMPPRequestController.h"
#import "Timeline.h"
#import "Space.h"


@interface ShareEventViewController ()

@property (weak, nonatomic) IBOutlet UITableView *timelinesTableView;
@property (strong, nonatomic) NSMutableArray *timelinesAppArray;
@property (strong, nonatomic) NSMutableArray *timelinesArray;

- (IBAction)cancelButtonPressed:(id)sender;

@end

@implementation ShareEventViewController

@synthesize delegate = _delegate;
@synthesize sharingDelegate = _sharingDelegate;
@synthesize timelinesTableView = _timelinesTableView;
@synthesize timelinesAppArray = _timelinesAppArray;
@synthesize timelinesArray = _timelinesArray;

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
    
    //Set the background of the navigation bar
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpaceList:) name:@"SpaceListDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpaces:) name:@"SpacesDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAI:) name:@"SpacesFetchingErrorNotification" object:nil];
    
    
    //Get the XMPPRequestController
    XMPPRequestController *rc = [Utility xmppRequestController];
    
    [rc spacesListRequest];
    [Utility showActivityIndicatorWithView:self.timelinesTableView label:@"Loading Timelines.."];
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

- (NSMutableArray *)timelinesArray{
    if (!_timelinesArray) {
        _timelinesArray = [[NSMutableArray alloc] init];
    }
    return _timelinesArray;
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)cancelButtonPressed:(id)sender{
    //Tells the delegate to dismiss the view controller
    [self.delegate dismissModalViewController];
}

#pragma mark -
#pragma mark Notification Methods (XMPPRequestController)

- (void)updateSpaceList:(NSNotification *)notification{
    
    //If the view is loaded and shown
    if (self.isViewLoaded && self.view.window) {
        
        //Get the spaces list
        self.timelinesAppArray = [notification.userInfo objectForKey:@"userInfo"];
        
        //Get the XMPPRequestController
        XMPPRequestController *rc = [Utility xmppRequestController];
        
        //Walk-through the spaces
        for (Space *sp in self.timelinesAppArray) {
            //Get the info for that space
            [rc spaceWithIdRequest:sp.spaceId];
        }
    }
}

- (void)updateSpaces:(NSNotification *)notification{
    
    //If the view is loaded and shown
    if (self.isViewLoaded && self.view.window) {
        
        //Get the space from the notification
        Space *sp = [notification.userInfo objectForKey:@"userInfo"];
        //Get the request number
        int requestNumber = [[notification.userInfo objectForKey:@"requestNumber"] integerValue];
        
        //If the space has more than one member it has to be considered shared
        if ([sp.spaceUsers count]>1) {
            //Map the space object in a timeline object
            [self.timelinesArray addObject:[[Timeline alloc] initTimelineWithId:sp.spaceId title:sp.spaceName creator:nil shared:YES]];
            
            //Update the tableview
            [self.timelinesTableView reloadData];

        }
                
        //If the request number is equal 1 it means that is the last request thereby the activity indicator can be dismissed
        if (requestNumber==1) {
            nodeIdRequestNumber=0;
            [Utility dismissActivityIndicator:self.timelinesTableView];
             if (![self.timelinesArray count]) {
             [Utility showAlertViewWithTitle:@"Mirror Space Service" message:@"No Public Timelines present." cancelButtonTitle:@"Dismiss"];
             }
        }
    }
}

//This method is used to dismiss the activity indicator when an error occurr
- (void)dismissAI:(NSNotification *)notification{
    [Utility dismissActivityIndicator:self.timelinesTableView];
}

#pragma -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Public Timelines";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.timelinesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCellIdentifier"];
    
    // Configure the cell...
    
    Timeline *tl = [self.timelinesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = tl.title;
    cell.imageView.image = [UIImage imageNamed:@"timelines.png"];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Get the timeline (space) id
    NSString *timelineId =  ((Timeline *)[self.timelinesArray objectAtIndex:indexPath.row]).tId;
    
    //Tells the delegate to share the event to the timeline (space) selected
    [self.sharingDelegate shareEventToSpaceWithId:timelineId];
    
    
}

@end
