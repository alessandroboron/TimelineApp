//
//  TimelinesViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "TimelinesViewController.h"
#import "NewTimelineViewController/NewTimelineViewController.h"
#import "Timeline.h"
#import "TimelineViewController/TimelineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "Space.h"
#import "XMPPRequestController.h"
#import "DBController.h"
#import "Timeline.h"
#import "Event.h"

@interface TimelinesViewController ()

@property (strong, nonatomic) NSMutableArray *timelinesAppArray;
@property (strong, nonatomic) Reachability *hostReachable;

@end

@implementation TimelinesViewController

@synthesize timelinesArray = _timelinesArray;
@synthesize timelinesAppArray = _timelinesAppArray;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Set the background for the view
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Register itself as observer for the XMPPRequestController in order to update the spacelist and attributes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpaceList:) name:@"SpaceListDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpaces:) name:@"SpacesDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAI:) name:@"SpacesFetchingErrorNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTimelines:) name:@"SpacesServiceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeData:) name:@"XMPPServerDidAuthenticate" object:nil];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
  //  if ([Utility isHostReachable] && [Utility isSettingStored]) {
        
  //  }
  //  else{
    /*
    self.timelinesArray = [NSMutableArray arrayWithObjects:[[Timeline alloc] initTimelineWithTitle:@"My Experience" creator:@"Alessandro" shared:NO],[[Timeline alloc] initTimelineWithTitle:@"Our Experience" creator:@"Alessandro" shared:YES], nil];
     */
   // }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
    //Get the xmpp controller
    XMPPRequestController *rc = [Utility xmppRequestController];
    
    //Check if there is internet connection
    self.hostReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    //If Online and Authenticathed retrieve groups
    if ([self.hostReachable isReachable] && rc.isUserAuthenticatedOnXMPPServer) {
        //Get the list of the Timelines/Space
        [rc spacesListRequest];
        //Show activity indicator
        [Utility showActivityIndicatorWithView:self.tableView label:@"Loading Timelines..."];
        
        //Update the DB
    }
    //Otherwise retrieve the timelines from DB
    else{
    
       // [[Utility databaseController] fetchDataFromDB];

    }
     */
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Get the xmpp controller
    XMPPRequestController *rc = [Utility xmppRequestController];
    
    //Check if there is internet connection
    self.hostReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
 
    
    //If Online and Authenticathed retrieve groups
    if ([self.hostReachable isReachable] && rc.isUserAuthenticatedOnXMPPServer) {
        //Get the list of the Timelines/Space
        [rc spacesListRequest];
        //Show activity indicator
        [Utility showActivityIndicatorWithView:self.tableView label:@"Loading Timelines..."];
    }
    
    //Otherwise retrieve the timelines from DB
    else{
        self.timelinesArray = [[Utility databaseController] fetchTimelinesFromDB];
        NSLog(@"ARRAY COUNT %d",[self.timelinesArray count]);
        [Utility sortArray:self.timelinesArray withKey:@"title" ascending:YES];
        [self.tableView reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [Utility dismissActivityIndicator:self.tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //If new timeline button is tapped
    if ([segue.identifier isEqualToString:@"newTimelineSegue"]) {
        
        //Get the container view controller
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        //Get the view controller
        NewTimelineViewController *ntvc = [[navController viewControllers] objectAtIndex:0];
        //Set the delegate
        ntvc.delegate = self;
    }
    
    else if ([segue.identifier isEqualToString:@"timelineDetailsSegue"]){
       
        //Get the index path according to the cell tapped
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //Get the destination view controller
        TimelineViewController *tvc =  (TimelineViewController *)segue.destinationViewController;
        //Set the title of the navigation bar
        tvc.navigationItem.title = ((Timeline *)[self.timelinesArray objectAtIndex:indexPath.row]).title;
        //Set the timeline
        tvc.timeline = [self.timelinesArray objectAtIndex:indexPath.row];
    }
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
#pragma mark Notification Methods (XMPPRequestController)

- (void)updateSpaceList:(NSNotification *)notification{
    
    //If the view is loaded and shown
    if (self.isViewLoaded && self.view.window) {
        //Set the timelines array to nil. It prevents to duplicate timelines
        self.timelinesArray = nil;
        
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
       
        //Set the space shared = NO
        BOOL shared = NO;
        
        //If the space has more than one member it has to be considered shared
        if ([sp.spaceUsers count]>1) {
            shared = YES;
        }
        
        //Initialize the timeline object
        Timeline *t = [[Timeline alloc] initTimelineWithId:sp.spaceId title:sp.spaceName creator:nil shared:shared];
        
        //If the timeline is not in the DB insert the timeline
        if (![[Utility databaseController] isTimelineInDB:t.tId]) {
            //Insert the timeline in the DB
            [[Utility databaseController] insertTimeline:t];
        }
        //If it is present check that title and shared are not changed
        else{
            //If the title has changed
            if (![[Utility databaseController] isTimeline:t.tId titleEqualTo:t.title]){
                //Update the title
                [[Utility databaseController] updateTimeline:t.tId withTitle:t.title];
            }
            //If the sharing condition has changed
            if (![[Utility databaseController] isTimeline:t.tId sharedEqualTo:t.shared]) {
                //Update the sharing condition
                [[Utility databaseController] updateTimeline:t.tId withShared:t.shared];
            }
        }
        
        //If the request number is equal 1 it means that is the last request thereby the activity indicator can be dismissed
        if (requestNumber==1) {
            //Load Private Timelines From the DB
            NSMutableArray *offlineTimeline = [[Utility databaseController] fetchTimelinesFromDB];
            for (Timeline *t in offlineTimeline) {
                [self.timelinesArray addObject:t];
            }
            //Order the array in alphabetically order
            [Utility sortArray:self.timelinesArray withKey:@"title" ascending:YES];
            [self.tableView reloadData];
            
            [Utility dismissActivityIndicator:self.tableView];
            nodeIdRequestNumber=0;
            //Set the timelinesAPPArray to nil
            self.timelinesAppArray = nil;
        }
        
        
    }
}

//This method is used to dismiss the activity indicator when an error occurr
- (void)dismissAI:(NSNotification *)notification{
    [Utility dismissActivityIndicator:self.tableView];
}

- (void)fetchTimelines:(NSNotification *)notification{
    
    //If Online and Authenticathed retrieve timelines
    if ([Utility isHostReachable] && [Utility isUserAuthenticatedOnXMPPServer]) {
        
            XMPPRequestController *rc = [Utility xmppRequestController];
            
            [rc spacesListRequest];
            
        if (self.isViewLoaded && self.view.window) {
            [Utility showActivityIndicatorWithView:self.tableView label:@"Loading Timelines"];
        }
    }
}

#pragma XMPPServerDidAuthenticate

//This method is used to send to the XMPP server the data stored when the timeline was offline
- (void)storeData:(NSNotification *)notification{
    
    //Get the user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Check if there's something to share avoiding DB calls
    if ([userDefaults boolForKey:@"Share"]) {

        //Get the XMPP Controller
        XMPPRequestController *rc = [Utility xmppRequestController];
        
        DBController *db = [Utility databaseController];
        
        //Get the timelines
        NSMutableArray *timelines = [db fetchTimelinesFromDB];
        
        for (Timeline *tl in timelines) {
            //Only if the timeline is not shared
            if ([[Utility databaseController]isTimelineShared:tl.tId]){
                //Get the events for each timeline
                NSMutableArray *events = [db fetchEventsFromDBForTimelineId:tl];
                //Get the events
                for (Event *ev in events) {
                    //If the event is not stored
                    if (ev.stored == NO) {
                        //Update the Event
                        [db updateEvent:ev.baseEventId withStorage:YES];
                        //Send the event to the xmpp Server
                        [rc sendEventItem:ev toSpaceWithId:tl.tId];
                    }
                }
            }
        }
        //Set the user defaults to store to NO
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Share"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -
#pragma mark DismissModalViewControllerProtocol

- (void)dismissModalViewController{
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newTimeline:(id)sender{
    //Insert the new timeline in the db
    [[Utility databaseController] insertTimeline:(Timeline *)sender];
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark  Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.timelinesArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelinesIdentifier"];
    
    // Configure the cell...
    
    Timeline *tl = [self.timelinesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = tl.title;
    cell.detailTextLabel.text = [tl sharedDescription];
    cell.imageView.image = [UIImage imageNamed:@"timelines.png"];
    
    return cell;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
