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

@synthesize popoverController = _popoverController2;
@synthesize location = _location;
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
        
        coreLocationController = [[CoreLocationController alloc] init];
        coreLocationController.delegate = self;
        
        library = [[ALAssetsLibrary alloc] init];
        
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

- (void) openCamera:(id) sender
{
    NSLog(@"Open Camera");
    
    // check if user has camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Your device hasn't a camera" duration:5000];
        [alert showAlert];
    }else{
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        // start localtion
        [coreLocationController.locMgr startUpdatingLocation];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            picker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
            [self.popoverController presentPopoverFromBarButtonItem:nil permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [self presentModalViewController:picker animated:YES];
        }
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // the image itself to save in the library
    UIImage *pickedImage = [info
                            objectForKey:UIImagePickerControllerOriginalImage];
    
    // User come from Snapshot. We will temporary save in the Library.
    // If in the Settings is configure to not save in the library, we will delete
    NSMutableDictionary *exif = nil;
    
    // check if metadata is available
    if ([info objectForKey:UIImagePickerControllerMediaMetadata] != nil) {
        exif = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        
        
        NSDictionary *gpsDict  = [self currentLocation];
        if ([gpsDict count] > 0) {
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"There is location");
#endif
            [exif setObject:gpsDict forKey:(NSString*) kCGImagePropertyGPSDictionary];
        }else{
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"No location found");
#endif
        }
        
    }
    
    [library writeImageToSavedPhotosAlbum:[pickedImage CGImage] metadata:exif completionBlock:^(NSURL *newUrl, NSError *error) {
        if (error) {
            NSLog(@"The photo took by the user could not be saved = %@", [error description]);
        } else {
            PhotoViewController* controller = [[PhotoViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"PhotoViewController"] bundle:nil url:newUrl image:pickedImage];
            [picker pushViewController:controller animated:YES];
        }
    }];
    
    
    // stop location
    [coreLocationController.locMgr stopUpdatingLocation];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
    [coreLocationController.locMgr stopUpdatingLocation];
}


//Creates an EXIF field for the current geo location.
- (NSMutableDictionary*)currentLocation {
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
	
	if (self.location != nil) {
		CLLocationDegrees exifLatitude = self.location.coordinate.latitude;
		CLLocationDegrees exifLongitude = self.location.coordinate.longitude;
        
		[locDict setObject:self.location.timestamp forKey:(NSString*) kCGImagePropertyGPSTimeStamp];
		
		if (exifLatitude < 0.0) {
			exifLatitude = exifLatitude*(-1);
			[locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
		} else {
			[locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
		}
		[locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        
		if (exifLongitude < 0.0) {
			exifLongitude=exifLongitude*(-1);
			[locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
		} else {
			[locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
		}
		[locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*) kCGImagePropertyGPSLongitude];
	}
	
    return locDict;
    
}

- (void)locationUpdate:(CLLocation *)position{
    self.location = position;
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Position %@", position);
#endif
}

- (void)locationError:(NSError *)error {
    NSLog(@"Location error %@", [error description]);
    
    if ([error code] == kCLErrorDenied){
        // validate if we had checked once if user allowed location
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults) {
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:kValidateNotAllowedLocation] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:kValidateNotAllowedLocation] == NO){
                // validated
                [standardUserDefaults setBool:YES forKey:kValidateNotAllowedLocation];
                
                // synchronize the keys
                [standardUserDefaults synchronize];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end