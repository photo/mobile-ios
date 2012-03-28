//
//  BaseViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//
#import "BaseViewController.h"


// private
@interface BaseViewController()
- (void) openTypePhotoLibrary;    
- (void) openTypeCamera;
- (NSMutableDictionary*)currentLocation;
- (UINavigationController*) getUINavigationController:(UIViewController *) controller forHomeScreen:(BOOL) home;
@end

@implementation BaseViewController

@synthesize appSettingsViewController,location;

- (OpenPhotoIASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[OpenPhotoIASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
    if ([key isEqualToString:@"TestFlighFeed"]){
        [TestFlight openFeedbackView];
    }else if ([key isEqualToString:@"CleanCache"]){
        [PhotoModel deleteAllPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];
        [NewestPhotos deleteAllNewestPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];
        [UploadPhotos deleteAllUploadsInManagedObjectContext:[AppDelegate managedObjectContext]];
    }
}


- (void)viewDidLoad {
    coreLocationController = [[CoreLocationController alloc] init];
    coreLocationController.delegate = self;
}

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{  
    // Here we keep the link of what is in the BAR and its Controllers
    if (title == @"Home"){
        //      HomeViewController *controller = [[[HomeViewController alloc]init ]autorelease];
        NewestPhotosTableViewController *controller = [[[NewestPhotosTableViewController alloc]init]autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
        return [self getUINavigationController:controller forHomeScreen:YES];
    }else if (title == @"Gallery"){
        GalleryViewController *controller = [[[GalleryViewController alloc]init] autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:1] autorelease];
        return [self getUINavigationController:controller forHomeScreen:NO];
    }else if (title == @"Tags"){
        TagViewController *controller = [[[TagViewController alloc] init]autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:3] autorelease];       
        return [self getUINavigationController:controller forHomeScreen:NO];
    }else if (title == @"Settings"){
        [self.appSettingsViewController setShowCreditsFooter:NO];   
        self.appSettingsViewController.showDoneButton = NO; 
        
        UINavigationController *controller = [self getUINavigationController:self.appSettingsViewController forHomeScreen:NO];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:4] autorelease];
        return controller;
    }
    
    UIViewController* viewController = [[[UIViewController alloc] init] autorelease];
    viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:2] autorelease];
    return viewController;
}

- (UINavigationController*) getUINavigationController:(UIViewController *) controller forHomeScreen:(BOOL) home{
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    navController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    navController.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    // image for the navigator
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]){
        //iOS >=5.0
        UIImage *backgroundImage;
        if ( home == YES){
            backgroundImage = [UIImage imageNamed:@"home-openphoto-bar.png"];
        }else {
            backgroundImage = [UIImage imageNamed:@"appbar_empty.png"];
        }  
        [navController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    [navController.navigationBar setBackgroundColor:[UIColor blackColor]];
    
    return navController;
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    
    if (heightDifference < 0){
        button.center = self.tabBar.center;
    }else{
        CGPoint center = self.tabBar.center;
        center.y =self.tabBar.frame.size.height-(buttonImage.size.height/2.0);
        button.center = center;
    }
    
    // action for this button
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchUpInside];    
    [self.tabBar addSubview:button];
}

-(void)buttonEvent{
    // start localtion
    [coreLocationController.locMgr startUpdatingLocation];
    
    // check if user has camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Upload your picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera roll", @"Snapshot", nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [menu showInView:self.view];
        [menu release];
    }else{
        // open direct the library
        [self openTypePhotoLibrary];
    }
}


// user can open the photo library or the camera. Ask him.
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self openTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [self openTypeCamera];
    } else{
        // it was cancel, shutdown the location
        [coreLocationController.locMgr stopUpdatingLocation];
    }
}


-(void) openTypePhotoLibrary{
    UIImagePickerController *pickerController = [[UIImagePickerController
                                                  alloc]
                                                 init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release]; 
}

-(void) openTypeCamera{
    UIImagePickerController *pickerController = [[UIImagePickerController
                                                  alloc]
                                                 init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *pickedImage = [info
                            objectForKey:UIImagePickerControllerOriginalImage];
    
    // used for get EXIF information, in case of saved images
    NSURL *referenceUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    if (referenceUrl){
        PhotoViewController* controller = [[PhotoViewController alloc]initWithNibName:@"PhotoViewController" bundle:nil photoUrl:referenceUrl photo:pickedImage source:picker.sourceType];
        [picker pushViewController:controller animated:YES];
    }else{
        // in this case, the user used the Snapshot. We will temporary save in the Library. 
        // If the Settings is to not do that, we will delete this.
        NSMutableDictionary *exif = nil;
		ALAssetsLibrary	*aLAssetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
		
        // check if metadata is available
		if ([info objectForKey:UIImagePickerControllerMediaMetadata] != nil) {
			exif = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
            
            
            NSDictionary *gpsDict  = [self currentLocation];
            if ([gpsDict count] > 0) {
                NSLog(@"There is location");
                [exif setObject:gpsDict forKey:(NSString*) kCGImagePropertyGPSDictionary];
            }else{
                NSLog(@"No location found");
            }
            
      	}
        
		[aLAssetsLibrary writeImageToSavedPhotosAlbum:[pickedImage CGImage] metadata:exif completionBlock:^(NSURL *newUrl, NSError *error) {
			if (error) {
				NSLog(@"The photo you took could not be saved!");
			} else {
                PhotoViewController* controller = [[PhotoViewController alloc]initWithNibName:@"PhotoViewController" bundle:nil photoUrl:newUrl photo:pickedImage source:picker.sourceType];
                [picker pushViewController:controller animated:YES]; 
			}
		}];
    }
    
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
	
    return [locDict autorelease];
    
}

- (void)locationUpdate:(CLLocation *)position{
    self.location = position;
    NSLog(@"Position %@", position);
}

- (void)locationError:(NSError *)error {
    NSLog(@"Location %@", [error description]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}


- (void)dealloc {
    [appSettingsViewController release];
	appSettingsViewController = nil;
    [coreLocationController release];
    [location release];
    
    [super dealloc];
}

@end
