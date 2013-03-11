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

@interface MenuViewController()
- (MenuTableViewCell *) getDefaultUITableViewCell:(UITableView *)tableView ;
@end

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
        
        self.tableView.backgroundColor = UIColorFromRGB(0x958077);
        // color separator
        self.tableView.separatorColor = UIColorFromRGB(0xB6A39A);
        
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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 10.0f)];
    self.tableView.scrollEnabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *menuTableViewSectionCellIdentifier = @"menuTableViewSectionCell";
    static NSString *menuTableViewSearchCellIdentifier = @"menuTableViewSearchCell";
    
    NSUInteger row = [indexPath row];
    if ( row == 0){
        // the first one is the search
        // load the search cell
        MenuTableViewSearchCell  *cell = [tableView dequeueReusableCellWithIdentifier:menuTableViewSearchCellIdentifier];
        
        if (cell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuTableViewSearchCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[MenuTableViewSearchCell class]])
                {
                    cell = (MenuTableViewSearchCell *)currentObject;
                    break;
                }
            }
        }
        
        cell.contentView.backgroundColor = UIColorFromRGB(0x40332D);
        cell.labelSearch.delegate = cell;
        return cell;
    }else if ( row ==  1){
        // latest activity
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"Latest Activity", @"Menu - title for Home");
        [cell.image setImage:[UIImage imageNamed:@"menu-latest.png"]];
        return cell;
    }else if ( row ==  2){
        // photos - gallery
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"Gallery", @"Menu - title for Gallery");
        [cell.image setImage:[UIImage imageNamed:@"menu-gallery.png"]];
        return cell;
    }else if ( row ==  3){
        // albums
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"Albums", @"Menu - title for Albums");
        [cell.image setImage:[UIImage imageNamed:@"menu-album.png"]];
        return cell;
    }else if ( row ==  4){
        // tags
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"Tags", @"Menu - title for Tags");
        [cell.image setImage:[UIImage imageNamed:@"menu-tags.png"]];
        return cell;
    }else if ( row ==  5){
        // upload & sync
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"Upload & Sync", @"Menu - title for Upload & Sync");
        [cell.image setImage:[UIImage imageNamed:@"menu-upload.png"]];
        return cell;
    }else if ( row ==  6){
        // preferences
        // load preference cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuTableViewSectionCellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuTableViewSectionCell" owner:nil options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.contentView.backgroundColor = UIColorFromRGB(0x40332D);
        
        return cell;
    }else if ( row ==  7){
        // my account
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"My Account", @"Menu - title for Account");
        [cell.image setImage:[UIImage imageNamed:@"menu-profile.png"]];
        return cell;
    }else {
        // settings
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView];
        cell.label.text = NSLocalizedString(@"Settings", @"Menu - title for Settings");
        [cell.image setImage:[UIImage imageNamed:@"menu-settings.png"]];
        return cell;
    }
    
}

- (MenuTableViewCell *) getDefaultUITableViewCell:(UITableView *)tableView
{
    static NSString *menuTableViewCellIdentifier = @"menuTableViewCell";
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuTableViewCellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuTableViewCell" owner:nil options:nil];
        cell = [topLevelObjects objectAtIndex:0];
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
            
            if (indexPath.row == 1){
                // Latest activity
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[HomeTableViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if (indexPath.row ==2){
                // Gallery
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[GalleryViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.row == 3){
                // Albums
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[AlbumViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if (  indexPath.row == 4){
                // Tags
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[TagViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if (  indexPath.row == 5){
                // Upload & Sync
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[SyncViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if (  indexPath.row == 7){
                // Account - Profile
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[ProfileViewController alloc] init]];
                nav.title=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                controller.centerController = nav;
            }else if ( indexPath.row == 8){
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( [indexPath row] == 6){
        return 20;
    }else{
        return 44;
    }
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