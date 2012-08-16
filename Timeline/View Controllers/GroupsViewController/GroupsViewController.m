//
//  GroupsViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "GroupsViewController.h"
#import "NewGroupViewController/NewGroupViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GroupsViewController ()

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        
        UITableViewController *tvc = (UITableViewController *)segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        tvc.navigationItem.title = [[NSString alloc] initWithFormat:@"%@ Members",[self.groupsArray objectAtIndex:indexPath.row]];
    }
}

#pragma mark -
#pragma mark ModalViewControllerDelegate

- (void)dismissModalViewController{
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)performTask:(id)sender{
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
    
    cell.imageView.image = [UIImage imageNamed:@"groups.png"];
    cell.textLabel.text = [self.groupsArray objectAtIndex:indexPath.row];
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
