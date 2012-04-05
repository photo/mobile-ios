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
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    // add logt out
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButton)];          
    self.navigationItem.rightBarButtonItem = logoutButton;
    [logoutButton release];
}

// extend the framework to let Switch be red color.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];

    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        if (!cell) {
            cell = (IASKPSToggleSwitchSpecifierViewCell*) [[[NSBundle mainBundle] loadNibNamed:@"IASKPSToggleSwitchSpecifierViewCell" 
                                                                                         owner:self 
                                                                                       options:nil] objectAtIndex:0];
        }
        
        if([((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle  respondsToSelector:@selector(setOnTintColor:)]){
            //iOS 5.0
            [((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle  setOnTintColor:[UIColor redColor]];
        }
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
        
        NSLog(@"Invalidate user information");
        AuthenticationHelper* helper = [[AuthenticationHelper alloc]init];
        [helper invalidateAuthentication];
        [helper release];
    }
}

@end
