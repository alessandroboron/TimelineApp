//
//  GroupsViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GroupsViewController.h"
#import "NewGroupViewController/NewGroupViewController.h"
#import "GroupMembers/GroupMembersViewController.h"
#import "XMPPRequestController.h"
#import "Space.h"

@interface GroupsViewController ()

@property (strong, nonatomic) NSMutableArray *groupsArray;
@property (strong, nonatomic) NSMutableArray *groupsAppArray;

@end

@implementation GroupsViewController

@synthesize groupsArray = _groupsArray;

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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Set the background image for the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Register itself as observer for the XMPPRequestController in order to update the spacelist and attributes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpaceList:) name:@"SpaceListDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpaces:) name:@"SpacesDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAI:) name:@"SpacesFetchingErrorNotification" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //If Online and Authenticathed retrieve groups
    if ([Utility isHostReachable] && [Utility isUserAuthenticatedOnXMPPServer]) {
        
        XMPPRequestController *rc = [Utility xmppRequestController];
        
        [rc spacesListRequest];
        [Utility showActivityIndicatorWithView:self.tableView label:@"Loading Groups..."];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Lazy Instantiation

- (NSMutableArray *)groupsArray{
    
    if (!_groupsArray) {
        _groupsArray = [[NSMutableArray alloc] init];
    }
    
    return _groupsArray;
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //If the new group button is tapped
    if ([segue.identifier isEqualToString:@"newGroupSegue"]) {
        
        //Get the container view controller
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        //Get the view controller
        NewGroupViewController *ngvc = [navController.viewControllers objectAtIndex:0];
        //Set the delegate
        ngvc.delegate = self;
    }
    
    //If the group details is tapped
    else if ([segue.identifier isEqualToString:@"groupMemberSegue"]){
        
        //Get the destination view controller
        GroupMembersViewController *tvc = (GroupMembersViewController *)segue.destinationViewController;

        //Get the index of the cell tapped
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //Set the title with the name of the group
        tvc.navigationItem.title = [[NSString alloc] initWithFormat:@"%@ Members",[[self.groupsArray objectAtIndex:indexPath.row] spaceName]];
        
        //Set the members array
        tvc.members = [[self.groupsArray objectAtIndex:indexPath.row] spaceUsers];
    }
}

#pragma mark -
#pragma mark Notification Methods (XMPPRequestController)

- (void)updateSpaceList:(NSNotification *)notification{
    
    //If the view is loaded and shown
    if (self.isViewLoaded && self.view.window) {
        
        //Set the groups array to nil.It prevents to duplicate groups when the view appears
        self.groupsArray = nil;
        
        //Get the spaces list
        self.groupsAppArray = [notification.userInfo objectForKey:@"userInfo"];
        
        //Order the array in alphabetically order
        [Utility sortArray:self.groupsAppArray withKey:@"spaceName" ascending:YES];

        //Get the XMPPRequestController
        XMPPRequestController *rc = [Utility xmppRequestController];
        
        //Walk-through the spaces
        for (Space *sp in self.groupsAppArray) {
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
        
        //Map the space object in a timeline object
        [self.groupsArray addObject:sp];
        
        //Update the tableview
        [self.tableView reloadData];
        
        //If the request number is equal 1 it means that is the last request thereby the activity indicator can be dismissed
        if (requestNumber==1) {
            [Utility dismissActivityIndicator:self.tableView];
            nodeIdRequestNumber=0;
            //Set the groupsAppArray to nil
            self.groupsAppArray = nil;
        }
    }
}

//This method is used to dismiss the activity indicator when an error occurr
- (void)dismissAI:(NSNotification *)notification{
    [Utility dismissActivityIndicator:self.tableView];
}

#pragma mark -
#pragma mark ModalViewControllerDelegate

- (void)dismissModalViewController{
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addGroup:(id)sender{
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //Get the Group Name
    NSString *group = (NSString *)sender;
    
    //Store the group
    [self.groupsArray addObject:group];
    
    //Reload the tableview
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.groupsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupsIdentifier"];
    
    // Configure the cell...
    
    Space *sp = [self.groupsArray objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"groups.png"];
    cell.textLabel.text = sp.spaceName;
    cell.detailTextLabel.text = [Utility timelineTypeString:sp.spaceType];
    
    return cell;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
      
}

@end
