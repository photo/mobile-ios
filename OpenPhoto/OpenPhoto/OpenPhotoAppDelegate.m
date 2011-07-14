#import "OpenPhotoAppDelegate.h"

@implementation OpenPhotoAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Allow HTTP response size to be unlimited.
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    // Configure the in-memory image cache to keep approximately
    // 10 images in memory, assuming that each picture's dimensions
    // are 320x480. Note that your images can have whatever dimensions
    // you want, I am just setting this to a reasonable value
    // since the default is unlimited.
    [[TTURLCache sharedCache] setMaxPixelCount:10*320*480];

    // Create a TTNavigator instance that can intercept URL calls and dispatch them to appropriate controllers
    TTNavigator* navigator = [TTNavigator navigator];
    navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    navigator.window = self.window;
    
    
    // start mapping URLs to controllers
    TTURLMap* map = navigator.URLMap;
    
    // catchall - any URL that isn't explicitly defined here goes to a web controller
    [map from:@"*" toViewController:[TTWebController class]];
    
    // home controller
    [map from:@"openphoto://home" toViewController:[LauncherController class]];
       
    // gallery from the website
    [map from:@"openphoto://gallery" toViewController:[GalleryViewController class]];
    
    // upload photo
    [map from:@"openphoto://upload" toModalViewController:[PhotoUploaderController class]];
    
    
    
    // initial point is home
    if (![navigator restoreViewControllers]) {
        NSLog(@"Opening view");
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"openphoto://home"]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
