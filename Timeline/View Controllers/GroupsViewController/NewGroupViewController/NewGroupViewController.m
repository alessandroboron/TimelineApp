//
//  NewGroupViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 10/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "NewGroupViewController.h"

@interface NewGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)didTapInView:(UITapGestureRecognizer *)recognizer;
@end

@implementation NewGroupViewController

@synthesize delegate = _delegate;
@synthesize groupNameTextField = _groupNameTextField;

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
#pragma mark UI Methods

- (IBAction)cancelButtonPressed:(id)sender{
    
    //Tells the delegate to dismiss the presented view controller
    [self.delegate dismissModalViewController];
}

- (IBAction)doneButtonPressed:(id)sender{
    
    //Check if the group name is not blank otherwise show an error message
    if (self.groupNameTextField.text.length == 0) {
        [Utility showAlertViewWithTitle:@"New Group Error" message:@"The group name cannot be blank." cancelButtonTitle:@"Dismiss"];
    }
    else{
        //Tells the delegate that a new group has been created and send it
        [self.delegate addGroup:self.groupNameTextField.text];
    }
}

- (IBAction)didTapInView:(UITapGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.groupNameTextField resignFirstResponder];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboard when return is pressed
    [self.groupNameTextField resignFirstResponder];
    return YES;
}

@end
