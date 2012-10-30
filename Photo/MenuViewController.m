//
//  MenuViewController.m
//  Photo
//
//  Created by Patrick Santana on 5/10/12.
//  Copyright 2012 Photo
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
//


#import "MenuViewController.h"
#import "IIViewDeckController.h"

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self){
        // needs update menu
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationNeededsUpdate
                                                   object:nil ];
        
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
        
        // color separator
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.scrollsToTop = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        // your photos menu
        return 4;
    }else{
        // settings
        return 5;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0){
        // your photos menu
        return NSLocalizedString(@"Your Photos", @"Used to title your photos in Menu");
    }else{
        // settings
        return NSLocalizedString(@"Settings", @"Used to title Settings in Menu");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ( indexPath.section == 0){
        // your photos menu
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Home", @"Menu - title for Home");
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Gallery", @"Menu - title for Gallery");
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Albums", @"Menu - title for Albums");
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Tags", @"Menu - title for Tags");
                break;
            default:
                cell.textLabel.text = @"not defined";
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Account", @"Menu - title for Account");
                break;
            case 1:
                cell.textLabel.text = ([AuthenticationService isLogged] ? NSLocalizedString(@"Log out", @"Menu - title for Log out") : NSLocalizedString(@"Login", @"Menu - title for Login"));
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Upgrade", @"Menu - title for Upgrade");
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Properties", @"Menu - title for Properties");
                break;
            case 4:
                cell.textLabel.text = NSLocalizedString(@"Contact Us", @"Menu - title for Contact us");
                break;
            default:
                cell.textLabel.text = @"not defined";
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        
        
        
        if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
            UITableViewController* cc = (UITableViewController*)((UINavigationController*)controller.centerController).topViewController;
            cc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            
            if ( indexPath.section == 0 && indexPath.row == 0){
                // Home
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[HomeTableViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 0 && indexPath.row ==1){
                // Gallery
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[GalleryViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 0 && indexPath.row == 2){
                // Albums
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[AlbumViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 0 && indexPath.row == 3){
                // Tags
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[TagViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 1 && indexPath.row == 0){
                // Account
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[AccountViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 1 && indexPath.row == 1){
                // Log out
                if ([AuthenticationService isLogged]){
                    // do the log out
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", @"Message when logging out") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"General") otherButtonTitles:NSLocalizedString(@"Log out",@"General"),nil] ;
                    [alert show];
                }else{
                    // open the login
                    [self openLoginViewController];
                }
            }else if ( indexPath.section == 1 && indexPath.row == 2){
                // Upgrade
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[UpgradeViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 1 && indexPath.row == 3){
                // Properties
            }else if ( indexPath.section == 1 && indexPath.row == 4){
                // Contact Us
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[ContactUsViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }
            
            if ([cc respondsToSelector:@selector(tableView)]) {
                [cc.tableView deselectRowAtIndexPath:[cc.tableView indexPathForSelectedRow] animated:NO];
            }
        }
        
        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
    }];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Log out");
#endif
        
        AuthenticationService *service = [[AuthenticationService alloc]init];
        [service logout];
        [self.tableView reloadData];
        
        // open the login
        [self openLoginViewController];
    }
}

- (void) openLoginViewController
{
    // open the login
    LoginViewController *controller = [[LoginViewController alloc]init ];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    navController.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
    [self presentModalViewController:navController animated:YES];
}

- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationNeededsUpdate]){
        [self.tableView reloadData];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end