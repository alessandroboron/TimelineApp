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
    
    
    //If Online and Authenticathed retrieve groups
    if ([Utility isHostReachable] && [Utility isUserAuthenticatedOnXMPPServer]) {
        
        XMPPRequestController *rc = [Utility xmppRequestController];
        
        [rc spacesListRequest];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    self.groupsArray = [notification.userInfo objectForKey:@"userInfo"];
    [self.tableView reloadData];
    
}

- (void)updateSpaces:(NSNotification *)notification{
    
    [self.tableView reloadData];
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
    cell.detailTextLabel.text = [sp spaceTypeString];
    
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
