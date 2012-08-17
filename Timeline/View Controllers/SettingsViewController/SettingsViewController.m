//
//  SettingsViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 11/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *serverTextField;
@property (weak, nonatomic) IBOutlet UITextField *domainTextField;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *serverStatusImageView;

@end

@implementation SettingsViewController

@synthesize serverTextField = _serverTextField;
@synthesize domainTextField = _domainTextField;
@synthesize userTextField = _userTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize serverStatusImageView = _serverStatusImageView;

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
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Look in the view hierarchy for a textfield that is the first responder and force it to resign
    [self.tableView endEditing:YES];
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    //According to which cell tapped shows the keyboard
    if (indexPath.section == 0) {
        [self.serverTextField becomeFirstResponder];
    }
    
    else if (indexPath.section == 1) {
        [self.domainTextField becomeFirstResponder];
    }
    
    else if (indexPath.section == 2) {
        [self.userTextField becomeFirstResponder];
    }

    else if (indexPath.section == 3) {
        [self.passwordTextField becomeFirstResponder];
    }
}

@end
