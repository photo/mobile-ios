//
//  OpenPhotoAppDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 25/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoAppDelegate.h"
#import "HomeViewController.h"
#import "GalleryViewController.h"
#import "TabBarController.h"
#import "SettingsViewController.h"
#import "TagsViewController.h"

@implementation OpenPhotoAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
    // Override point for customization after application launch.
    // Allow HTTP response size to be unlimited.
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    // Configure the in-memory image cache to keep approximately
    // 10 images in memory, assuming that each picture's dimensions
    // are 320x480. Note that your images can have whatever dimensions
    // you want, I am just setting this to a reasonable value
    // since the default is unlimited.
    [[TTURLCache sharedCache] setMaxPixelCount:10*320*480];

    TTNavigator* navigator = [TTNavigator navigator];
    navigator.supportsShakeToReload = YES;
    navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    navigator.window = [[[UIWindow alloc] initWithFrame:TTScreenBounds()] autorelease];
  
    TTURLMap* map = navigator.URLMap;
    
    // catchall - any URL that isn't explicitly defined here goes to a web controller
    [map from:@"*" toViewController:[TTWebController class]];
    
    // The tab bar controller is shared, meaning there will only ever be one created.  Loading
    // This URL will make the existing tab bar controller appear if it was not visible.
    [map from:@"openphoto://tabBar" toSharedViewController:[TabBarController class]];

    
    // home controller
    [map from:@"openphoto://home" toViewController:[HomeViewController class]];
    //tag controller
        [map from:@"openphoto://tags" toViewController:[TagsViewController class]];
    
    //settings
        [map from:@"openphoto://settings" toViewController:[SettingsViewController class]];
    
    // gallery from the website
    [map from:@"openphoto://gallery" toViewController:[GalleryViewController class] ];
    
    
    // initial point is home
    if (![navigator restoreViewControllers]) {
        NSLog(@"Opening tab view controller");
        // This is the first launch, so we just start with the tab bar
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"openphoto://tabBar"]];
    }
}
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
    return YES;
}

- (void)dealloc
{
    [super dealloc];
}

@end
