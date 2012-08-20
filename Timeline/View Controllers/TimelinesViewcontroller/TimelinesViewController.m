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

@interface TimelinesViewController ()

@end

@implementation TimelinesViewController

@synthesize timelinesArray = _timelinesArray;


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

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
  //  if ([Utility isHostReachable] && [Utility isSettingStored]) {
        
  //  }
  //  else{
        self.timelinesArray = [NSMutableArray arrayWithObjects:[[Timeline alloc] initTimelineWithTitle:@"My Experience" creator:@"Alessandro" shared:NO],[[Timeline alloc] initTimelineWithTitle:@"Our Experience" creator:@"Alessandro" shared:YES], nil];
   // }
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
#pragma mark Segue

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
       
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        TimelineViewController *tvc =  (TimelineViewController *)segue.destinationViewController;
        tvc.navigationItem.title = ((Timeline *)[self.timelinesArray objectAtIndex:indexPath.row]).title;
#warning pass the array with the information for the associated timeline 
    }
}

#pragma mark -
#pragma mark DismissModalViewControllerProtocol

- (void)dismissModalViewController{
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
