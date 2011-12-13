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


@interface BaseViewController()
- (void) openTypePhotoLibrary;    
- (void) openTypeCamera;
@end

@implementation BaseViewController

@synthesize appSettingsViewController;

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
    }
}

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{  
    // Here we keep the link of what is in the BAR and its Controllers
    if (title == @"Home"){
        HomeViewController *controller = [[[HomeViewController alloc]init ]autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
        return controller;
    }else if (title == @"Gallery"){
        GalleryViewController *controller = [[[GalleryViewController alloc]init] autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        navController.navigationBar.barStyle=UIBarStyleBlackOpaque;
        navController.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
        return navController;
    }else if (title == @"Tags"){
        TagViewController *controller = [[[TagViewController alloc] init]autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
        
        
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        navController.navigationBar.barStyle=UIBarStyleBlackOpaque;
        navController.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
        
        return navController;
    }else if (title == @"Settings"){
        UINavigationController *controller = [[[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController] autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
        
        [self.appSettingsViewController setShowCreditsFooter:NO];   
        self.appSettingsViewController.showDoneButton = NO;   
        
        controller.navigationBar.barStyle=UIBarStyleBlackOpaque;
        
        return controller;
    }
    
    UIViewController* viewController = [[[UIViewController alloc] init] autorelease];
    viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
    return viewController;
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{       
    UIImage *pickedImage = [info
                            objectForKey:UIImagePickerControllerOriginalImage];
    
    PhotoViewController* controller = [[PhotoViewController alloc]initWithNibName:@"PhotoViewController" bundle:nil photo:pickedImage source:picker.sourceType];
    [picker pushViewController:controller animated:YES];
}

// user can open the photo library or the camera. Ask him.
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self openTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [self openTypeCamera];
    } 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}


- (void)dealloc {
    [appSettingsViewController release];
	appSettingsViewController = nil;
    [super dealloc];
}

@end
