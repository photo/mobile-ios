//
//  OpenPhotoIASKAppSettingsViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/10/11.
//  Copyright 2012 OpenPhoto
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "OpenPhotoIASKAppSettingsViewController.h"

@implementation OpenPhotoIASKAppSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    // add logt out
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButton)];          
    self.navigationItem.rightBarButtonItem = logoutButton;
    [logoutButton release];
    
    self.tableView.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]] autorelease];
    self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Settings"];
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Get the text
    NSString *text = [super tableView:tableView titleForHeaderInSection:section];
    
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textColor = UIColorFromRGB(0xE6501E);
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(18.0, 0.0, 300.0, 44.0);
    
    
	headerLabel.text = text;
	[customView addSubview:headerLabel];
    [headerLabel release];
    
	return [customView autorelease];
}

// extend the framework to let Switch be red color.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    
    // change the color for the Switch
    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        if([((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle  respondsToSelector:@selector(setOnTintColor:)]){
            //iOS 5.0
            [((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle  setOnTintColor:[UIColor redColor]];
        }
    }else if ([[specifier type] isEqualToString:kIASKPSTitleValueSpecifier]){
        // change the color for the text 
        cell.detailTextLabel.textColor =  UIColorFromRGB(0xE6501E);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }else if ([[specifier type] isEqualToString:kIASKOpenURLSpecifier]) {
        // change the color for the text 
        cell.detailTextLabel.textColor =  UIColorFromRGB(0xE6501E); 
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    } 
    
    return cell;
}

- (void) logoutButton{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log out",nil] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        // move the screen to tab 0
        [AppDelegate openTab:0];
        
#ifdef TEST_FLIGHT_ENABLED
        [TestFlight passCheckpoint:@"User log out"];
#endif
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Invalidate user information");
#endif
        
        AuthenticationHelper* helper = [[AuthenticationHelper alloc]init];
        [helper invalidateAuthentication];
        [helper release];
    }
}

@end
