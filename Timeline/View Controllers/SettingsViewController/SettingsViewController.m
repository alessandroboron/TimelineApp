//"This work is licensed under the Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// To view a copy of the license, visit http://http://creativecommons.org/licenses/by-nc-sa/3.0/ "
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

- (void)setUserDefaultsAndNotify;

@end

@implementation SettingsViewController

@synthesize serverTextField = _serverTextField;
@synthesize domainTextField = _domainTextField;
@synthesize userTextField = _userTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize serverStatusImageView = _serverStatusImageView;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    //Set the background image for the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectivityStatus:) name:@"XMPPConnectivityDidUpdateNotification" object:nil];
        
    //If the settings are defined fill the fields
    if ([Utility isSettingStored]) {
        
        self.serverTextField.text = [Utility settingField:kXMPPServerIdentifier];
        self.domainTextField.text = [Utility settingField:kXMPPDomainIdentifier];
        self.userTextField.text = [Utility settingField:kXMPPUserIdentifier];
        self.passwordTextField.text = [Utility settingField:kXMPPPassIdentifier];
    }
    
    if ([Utility isXMPPServerConnected] && [Utility isUserAuthenticatedOnXMPPServer]) {
        self.serverStatusImageView.image = [UIImage imageNamed:@"greenButton.png"];
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
#pragma mark XMPPConnectivityDidUpdateNotification

//This method is used to update the connectivity status image in response to the status of the server
- (void)updateConnectivityStatus:(NSNotification *)notification{
    
    NSNumber *status = [notification.userInfo objectForKey:@"connectivityStatus"];
    
    if ([status boolValue]) {
        self.serverStatusImageView.image = [UIImage imageNamed:@"greenButton.png"];
    }
    else{
        self.serverStatusImageView.image = [UIImage imageNamed:@"redButton.png"];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Look in the view hierarchy for a textfield that is the first responder and force it to resign
    [self.tableView endEditing:YES];
    
    //If all the fields are filled out write the settings
    if (self.serverTextField.text.length != 0 && self.domainTextField.text.length != 0 && self.userTextField.text.length != 0 && self.passwordTextField.text.length != 0) {
        
        [self setUserDefaultsAndNotify];
    }
    
    //If it is connected but user defaults changes and it should disconnect
    if ((self.serverTextField.text.length == 0 || self.domainTextField.text.length == 0 || self.userTextField.text.length == 0 || self.passwordTextField.text.length == 0) && [Utility isXMPPServerConnected]) {
        
        [self setUserDefaultsAndNotify];
    }
    
    return YES;
}

#pragma mark -
#pragma Private Methods

- (void)setUserDefaultsAndNotify{
    
    //Write the settings
    [[NSUserDefaults standardUserDefaults] setObject:self.serverTextField.text forKey:kXMPPServerIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:self.domainTextField.text forKey:kXMPPDomainIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:self.userTextField.text forKey:kXMPPUserIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:kXMPPPassIdentifier];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Notify that settings are changed in order to connect using the new settings
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPSettingsDidChangeNotification" object:nil];
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
