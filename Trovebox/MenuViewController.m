//
//  MenuViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 5/10/12.
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
//


#import "MenuViewController.h"
#import "IIViewDeckController.h"

@interface MenuViewController()
- (MenuTableViewCell *) getDefaultUITableViewCell:(UITableView *)tableView image:(NSString *) imagePath imageSelected:(NSString *) imageSelectedPath;
@end

@implementation MenuViewController

@synthesize popoverController = _popoverController2;
@synthesize location = _location;
@synthesize appSettingsViewController;

@synthesize galleryController=_galleryController;
@synthesize albumController=_albumController;
@synthesize tagController=_tagController;
@synthesize syncController=_syncController;
@synthesize profileController=_profileController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self){
        // needs update menu
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationNeededsUpdate
                                                   object:nil ];
        
        self.tableView.backgroundColor = UIColorFromRGB(0x6B5851);
        // no separator
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if type = group, returns only 7: We need to remove Tags and My Profile
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxTypeUser];
    if (type && [type isEqualToString:@"group"]){
        return 7;
    }else{
        return 9;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *menuTableViewSectionCellIdentifier = @"menuTableViewSectionCell";
    static NSString *menuTableViewSearchCellIdentifier = @"menuTableViewSearchCell";
    
    BOOL groupUser = NO;
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxTypeUser];
    if (type && [type isEqualToString:@"group"]){
        groupUser = YES;
    }
    
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
        
        // set temporary the user's name
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxNameUser];
        if (name)
            cell.labelTroveboxUser.text = name;
        else{
            cell.labelTroveboxUser.text = @"Trovebox User";
        }
        
        return cell;
    }else if ( row ==  1){
        // latest activity
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-latest.png" imageSelected:@"menu-latest-selected.png"];
        cell.label.text = NSLocalizedString(@"Latest Activity", @"Menu - title for Home");
        return cell;
    }else if ( row ==  2){
        // photos - gallery
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-gallery.png" imageSelected:@"menu-gallery-selected.png"];
        cell.label.text = NSLocalizedString(@"Gallery", @"Menu - title for Gallery");
        return cell;
    }else if ( row ==  3){
        // albums
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-album.png" imageSelected:@"menu-album-selected.png"];
        cell.label.text = NSLocalizedString(@"Albums", @"Menu - title for Albums");
        return cell;
    }else if ( row ==  4 && !groupUser){
        // tags
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-tags.png" imageSelected:@"menu-tags-selected.png"];
        cell.label.text = NSLocalizedString(@"Tags", @"Menu - title for Tags");
        return cell;
    }else if ( (row ==  5 && !groupUser) || (row == 4 && groupUser) ){
        // upload & sync
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-upload.png" imageSelected:@"menu-upload-selected.png"];
        cell.label.text = NSLocalizedString(@"Upload & Sync", @"Menu - title for Upload & Sync");
        return cell;
    }else if ( (row ==  6 && !groupUser) || (row == 5 && groupUser) ){
        // preferences
        // load preference cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuTableViewSectionCellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuTableViewSectionCell" owner:nil options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.contentView.backgroundColor = UIColorFromRGB(0x40332D);
        
        return cell;
    }else if ( row ==  7 && !groupUser){
        // my account
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-profile.png" imageSelected:@"menu-profile-selected.png"];
        cell.label.text = NSLocalizedString(@"My Account", @"Menu - title for Account");
        return cell;
    }else {
        // settings
        MenuTableViewCell *cell = [self getDefaultUITableViewCell:tableView image:@"menu-settings.png" imageSelected:@"menu-settings-selected.png"];
        cell.label.text = NSLocalizedString(@"Settings", @"Menu - title for Settings");
        return cell;
    }
    
}

- (MenuTableViewCell *) getDefaultUITableViewCell:(UITableView *)tableView image:(NSString *) imagePath imageSelected:(NSString *) imageSelectedPath
{
    static NSString *menuTableViewCellIdentifier = @"menuTableViewCell";
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuTableViewCellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuTableViewCell" owner:nil options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.imageSelected = imageSelectedPath;
    cell.imageDefault = imagePath;
    
    [cell.image setImage:[UIImage imageNamed:imagePath]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL groupUser = NO;
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxTypeUser];
    if (type && [type isEqualToString:@"group"]){
        groupUser = YES;
    }
    
    
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        
        if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
            if (indexPath.row == 1){
                // Latest activity
                controller.centerController = SharedAppDelegate.centerController;
            }else if (indexPath.row ==2){
                // Gallery
                if (self.galleryController == nil){
                    self.galleryController = [[UINavigationController alloc]initWithRootViewController:[[GalleryViewController alloc] init]];
                }
                controller.centerController = self.galleryController;
            }else if ( indexPath.row == 3){
                // Albums
                if (self.albumController == nil){
                    self.albumController = [[UINavigationController alloc]initWithRootViewController:[[AlbumViewController alloc] init]];
                }
                controller.centerController = self.albumController;
            }else if (  indexPath.row == 4 && !groupUser){
                // Tags
                if (self.tagController == nil){
                    self.tagController = [[UINavigationController alloc]initWithRootViewController:[[TagViewController alloc] init]];
                }
                controller.centerController = self.tagController;
            }else if (  (indexPath.row == 5 && !groupUser) || (indexPath.row == 4 && groupUser) ){
                // Upload & Sync
                if (self.syncController == nil){
                    SyncViewController *photoPicker = [[SyncViewController alloc] initWithNibName:@"SyncViewController" bundle:nil];
                    ELCImagePickerController *syncController = [[ELCImagePickerController alloc] initWithRootViewController:photoPicker] ;
                    [photoPicker setParent:syncController];
                    [syncController setDelegate:photoPicker];
                    self.syncController = syncController;
                }
                controller.centerController = self.syncController;
                controller.centerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            }else if (  indexPath.row == 7 && !groupUser){
                // Account - Profile
                if (self.profileController == nil){
                    if ([DisplayUtilities isIPad]){
                        self.profileController = [[UINavigationController alloc]initWithRootViewController:[[ProfileViewController alloc] initWithNibName:@"ProfileViewControlleriPad" bundle:nil]];
                    }else{
                        self.profileController = [[UINavigationController alloc]initWithRootViewController:[[ProfileViewController alloc] init]];
                    }
                }
                controller.centerController = self.profileController;
            }else{
                // Settings
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.appSettingsViewController];
                controller.centerController = nav;
            }
        }
        
        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // if type = group, returns only 7: We need to remove Tags and My Profile
    BOOL groupUser = NO;
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxTypeUser];
    if (type && [type isEqualToString:@"group"]){
        groupUser = YES;
    }

    if ( [indexPath row] == 0){
        return 64;
    }else if ( ([indexPath row] == 6) || (([indexPath row] == 5) && groupUser)){
        return 37;
    }else{
        return 44;
    }
}

- (void) openLoginViewController
{
    // open the login
    LoginViewController *controller = [[LoginViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"LoginViewController"] bundle:nil ];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) openCamera:(id) sender
{
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Open Camera");
#endif
    
    // refresh profile details
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProfileRefresh object:nil];
    
    self.viewDeckController.centerController = SharedAppDelegate.centerController;
    [self selectLatestActivity];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    [coreLocationController.locMgr startUpdatingLocation];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

/*
    // the image itself to save in the library,
    // this data must be a raw data on DLCImagePickerController. Remove the PNG representation
    UIImage *pickedImage = [info objectForKey:@"image"];
    
    // User come from Snapshot. We will temporary save in the Library.
    NSData* pngData =  UIImageJPEGRepresentation(pickedImage,1.0);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)pngData, NULL);
    
    NSDictionary *exifTemp = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    __block NSMutableDictionary *exif = [exifTemp mutableCopy];
    
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
    
    [library writeImageToSavedPhotosAlbum:[pickedImage CGImage] metadata:exif completionBlock:^(NSURL *newUrl, NSError *error) {
        if (error) {
            NSLog(@"The photo took by the user could not be saved = %@", [error description]);
        } else {
            PhotoViewController* controller = [[PhotoViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"PhotoViewController"] bundle:nil url:newUrl];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [navController.navigationBar troveboxStyle:NO];
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:navController animated:YES completion:nil];
            }];
        }
    }];
    
    
    // stop location
    [coreLocationController.locMgr stopUpdatingLocation];
 
 */
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [coreLocationController.locMgr stopUpdatingLocation];
    }];
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

- (void) selectLatestActivity
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) displayProfileScreen
{
    [self.viewDeckController openLeftViewAnimated:YES completion:^(IIViewDeckController *controller) {
        // Account - Profile
        if (self.profileController == nil){
            self.profileController = [[UINavigationController alloc]initWithRootViewController:[[ProfileViewController alloc] init]];
            self.profileController.title= NSLocalizedString(@"My Account", @"Menu - title for Account");
        }
        
        controller.centerController = self.profileController;
        // select profile
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        //sleep a little and close the left view
        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
        [self.viewDeckController closeLeftViewAnimated:YES];
    }];
}

- (void) displayHomeScreen
{
    [self.viewDeckController openLeftViewAnimated:YES completion:^(IIViewDeckController *controller) {
        controller.centerController = SharedAppDelegate.centerController;
        [self selectLatestActivity];
        [MBProgressHUD hideAllHUDsForView:self.viewDeckController.view animated:YES];
        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
        [self.viewDeckController closeLeftViewAnimated:YES];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end