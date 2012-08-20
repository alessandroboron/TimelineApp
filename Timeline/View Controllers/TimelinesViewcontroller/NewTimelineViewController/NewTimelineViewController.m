//
//  NewTimelineViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "NewTimelineViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface NewTimelineViewController ()

@property (weak, nonatomic) IBOutlet UITextField *timelineTitleTextField;
@property (weak, nonatomic) IBOutlet UITableView *groupsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sharedSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *groupsLabel;
@property (strong, nonatomic) NSMutableArray *groupsArray;
@property (assign, nonatomic) BOOL sharedGroups;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)segmentedControlValueChanged:(id)sender;

@end

@implementation NewTimelineViewController

@synthesize delegate = _delegate;
@synthesize timelineTitleTextField = _timelineTitleTextField;
@synthesize groupsTableView = _groupsTableView;
@synthesize sharedSegmentedControl = _sharedSegmentedControl;
@synthesize groupsLabel = _groupsLabel;
@synthesize groupsArray = _groupsArray;
@synthesize sharedGroups = _sharedGroups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    _delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Set the background image for the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
    
    //Set itself as the datasource and delegate for the tableview
    self.groupsTableView.dataSource = self;
    self.groupsTableView.delegate = self;
    
    self.groupsTableView.clipsToBounds = YES;
    self.groupsTableView.layer.cornerRadius = 10.0;
    
    [self.groupsArray addObject:@"Friends"];
    [self.groupsArray addObject:@"NTNU"];
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

- (NSMutableArray *)groupsArray{
    if (!_groupsArray) {
        _groupsArray = [[NSMutableArray alloc] init];
    }
    return _groupsArray;
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)cancelButtonPressed:(id)sender{
    
    //Tells the delegate to dismiss the presented view controller
    [self.delegate dismissModalViewController];
}

- (IBAction)doneButtonPressed:(id)sender{
 
    //Check if the name of the timeline is not empty or if share at least one group is selected
    
    if (self.timelineTitleTextField.text.length == 0) {
        [Utility showAlertViewWithTitle:@"New Timeline Error" message:@"The timeline name cannot be blank." cancelButtonTitle:@"Dismiss"];
    }
    else if (self.sharedSegmentedControl.selectedSegmentIndex == 1 && !self.sharedGroups){
        [Utility showAlertViewWithTitle:@"New Timeline Error" message:@"A shared timeline must have at least one group associated." cancelButtonTitle:@"Dismiss"];
    }
    else{
        //Tells the delegate to dismiss the presented view controller
        [self.delegate dismissModalViewController];
    }
}

//This method is used to show/hide the groups when the segmentedControl changes value
- (IBAction)segmentedControlValueChanged:(id)sender{
    
    //If the timeline is not shared
    if (self.sharedSegmentedControl.selectedSegmentIndex == 0) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.groupsLabel.alpha = 0.0;
            self.groupsTableView.alpha = 0.0;
            
        }
          
        completion:nil];
    }
    //If the timeline is shared
    else if (self.sharedSegmentedControl.selectedSegmentIndex == 1){
        
        [UIView animateWithDuration:1.0 animations:^{
           self.groupsLabel.alpha = 1.0;
           self.groupsTableView.alpha = 1.0;
        }
         
        completion:nil];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.groupsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"groupIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *groupName = [self.groupsArray objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"groups.png"];
    cell.textLabel.text = groupName;
    
    return cell;
    
}

#pragma mark -
#pragma mark UITableViewDelegate

@end
