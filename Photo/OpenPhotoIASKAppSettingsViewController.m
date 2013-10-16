//
//  OpenPhotoIASKAppSettingsViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 29/10/11.
//  Copyright 2013 Trovebox
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
    
    // menu
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButtonImage = [UIImage imageNamed:@"button-navigation-menu.png"] ;
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
    [leftButton addTarget:self.viewDeckController  action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = customLeftButton;
    
    // button Log out
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign out", @"Sign out on Settings") style:UIBarButtonItemStylePlain target:self action:@selector(logoutButton)];
    self.navigationItem.rightBarButtonItem = customBarItem;
    
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.backgroundColor =  UIColorFromRGB(0XFAF3EF);
    self.tableView.backgroundView=imgView;
    self.tableView.separatorColor = UIColorFromRGB(0xCDC9C1);
    
    [self.navigationController.navigationBar troveboxStyle:NO];
    [self.navigationItem troveboxStyle:NSLocalizedString(@"Settings", @"Menu - title for Settings") defaultButtons:NO viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
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
	headerLabel.textColor = UIColorFromRGB(0x8C7B73);
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(18.0, 0.0, 300.0, 44.0);
    
    
	headerLabel.text = text;
	[customView addSubview:headerLabel];
    
	return customView;
}

// extend the framework to let Switch be another color.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    IASKSpecifier *specifier  = [self.settingsReader specifierForIndexPath:indexPath];
    
    // change the color for the Switch
    if ([[specifier type] isEqualToString:kIASKPSToggleSwitchSpecifier]) {
        if([((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle  respondsToSelector:@selector(setOnTintColor:)]){
            //iOS 5.0
            [((IASKPSToggleSwitchSpecifierViewCell*)cell).toggle  setOnTintColor: UIColorFromRGB(0xEFC005)];
        }
    }else if ([[specifier type] isEqualToString:kIASKPSTitleValueSpecifier]){
        // change the color for the text 
        cell.detailTextLabel.textColor =  UIColorFromRGB(0x8C7B73);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }else if ([[specifier type] isEqualToString:kIASKOpenURLSpecifier]) {
        // change the color for the text 
        cell.detailTextLabel.textColor =  UIColorFromRGB(0x8C7B73); 
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    } else if ([[specifier type] isEqualToString:kIASKButtonSpecifier]) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[specifier type]];
			cell.backgroundColor = [UIColor whiteColor];
        }
        cell.textLabel.text = [specifier title];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        return cell;
    }
    
    return cell;
}

- (void) logoutButton{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign out. Are you sure?",@"Message to confirm if user really wants to log out") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"") otherButtonTitles:NSLocalizedString(@"Sign out",@""),nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Invalidate user information");
#endif
        
        AuthenticationService* helper = [[AuthenticationService alloc]init];
        [helper logout];
    }
}

#pragma mark - Rotation

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
