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
@synthesize appSettingsViewController;

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
        return 5;
    }else{
        // settings
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0){
        // your photos menu
        return NSLocalizedString(@"Your Photos", @"Used to title your photos in Menu");
    }else{
        // settings
        return NSLocalizedString(@"PREFERENCES", @"Used to title Preferences in Menu");
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
                cell.textLabel.text = NSLocalizedString(@"Latest Activity", @"Menu - title for Home");
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
            case 4:
                cell.textLabel.text = NSLocalizedString(@"Upload & Sync", @"Menu - title for Upload & Sync");
                break;
            default:
                cell.textLabel.text = @"not defined";
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"My Account", @"Menu - title for Account");
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Settings", @"Menu - title for Settings");
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
                // Latest activity
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
            }else if ( indexPath.section == 0 && indexPath.row == 4){
                // Upload & Sync
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[SyncViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 1 && indexPath.row == 0){
                // Account - Profile
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[ProfileViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.section == 1 && indexPath.row == 1){
                // Settings
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.appSettingsViewController];
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

- (OpenPhotoIASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[OpenPhotoIASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
        [appSettingsViewController setShowCreditsFooter:NO];
        appSettingsViewController.showDoneButton = NO;
	}
	return appSettingsViewController;
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
    if ([key isEqualToString:@"CleanCache"]){
        [Timeline deleteAllTimelineInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
        [Synced deleteAllSyncedPhotosInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
        NSError *saveError = nil;
        if (![[SharedAppDelegate managedObjectContext] save:&saveError]){
            NSLog(@"Error to save context = %@",[saveError localizedDescription]);
        }
        
        //remove cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
    }
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end