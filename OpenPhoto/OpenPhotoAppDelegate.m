//
//  OpenPhotoAppDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2012 OpenPhoto
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
#import "OpenPhotoAppDelegate.h"
#import "OpenPhotoViewController.h"

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-11111111-3";


@interface OpenPhotoAppDelegate()
-(void) shareTwitterOrFacebook:(NSString *) message;
-(void) prepareConnectionInformation;
-(void) checkNetworkStatus:(NSNotification *) notice;
@end

@implementation OpenPhotoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize internetActive = _internetActive;
@synthesize hostActive = _hostActive;
@synthesize facebook = _facebook;
@synthesize tracker = tracker_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Allow HTTP response size to be unlimited.
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    // Configure the in-memory image cache to keep approximately
    // 20 images in memory, assuming that each picture's dimensions
    // are 640x960. Note that your images can have whatever dimensions
    // you want, I am just setting this to a reasonable value
    // since the default is unlimited.
    [[TTURLCache sharedCache] setMaxPixelCount:20*640*960];
    
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].debug = YES;
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    
// in development phase we use the UID of user
#ifdef DEVELOPMENT_ENABLED
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
#ifdef TEST_FLIGHT_ENABLED
    // to start the TestFlight SDK
    [TestFlight takeOff:@"407f45aed7c5bc2fc88cb567078edb1f_MjMyNTUyMDExLTA5LTEyIDEyOjEyOjU3Ljc1Nzg5MA"];
#endif
    
    [self prepareConnectionInformation];
    
    UpdateUtilities *updater = [UpdateUtilities instance];
    if ([updater needsUpdate] == YES){
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"App needs to be updated");
        NSLog(@"Version to install %@", [updater getVersion]);
#endif
        
        [updater update];
    }
    
    
    InitializerHelper *helper = [[InitializerHelper alloc]init];
    if ([helper isInitialized] == NO){
        [helper initialize];
    }
    [helper release];
    
    
    // open the default view controller
    self.window.rootViewController = self.viewController;
    
    // now if it is not authenticated, show the screen in the TOP of the view controller
    // check if user is authenticated or not
    AuthenticationHelper *auth = [[AuthenticationHelper alloc]init];
    if ([auth isValid]== NO){
        LoginViewController *controller = [[LoginViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"LoginViewController"] bundle:nil ];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        navController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
        navController.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
        
        [self.window.rootViewController presentModalViewController:navController animated:YES];
        [controller release];
    }
    [auth release];
    [self.window makeKeyAndVisible];
    
    // FACEBOOK
    self.facebook = [[Facebook alloc] initWithAppId:@"283425805036236" andDelegate:self];
    
    
    //register to share data.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventHandler:)
                                                 name:kNotificationShareInformationToFacebookOrTwitter
                                               object:nil ];
    
    // start the job
    [[JobUploaderController getController] start];
    
    // Let the device know we want to receive push notifications
//	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // remove badges
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    return YES;
}

+ (void) initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 10;
    [iRate sharedInstance].usesUntilPrompt = 6;
    [iRate sharedInstance].appStoreID = 511845345;
    [iRate sharedInstance].applicationBundleID = @"me.OpenPhoto.ios";
    [iRate sharedInstance].applicationName=@"OpenPhoto";
}


- (void) openTab:(int) position{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Opening the tab with position id = %i",position);
#endif
    
    if (position == 0 || position == 1 || position == 3 || position == 4){
        UIViewController *controller = self.window.rootViewController;
        if ([controller isKindOfClass:[OpenPhotoViewController class]]){
            [((OpenPhotoViewController*) controller) setSelectedIndex:position];
        }
    }else{
        NSException *exception = [NSException exceptionWithName: @"IncorrectPosition"
                                                         reason: [NSString stringWithFormat:@"Position %i is not support to open the tab. Please, select 0,1,3 or 4",position]
                                                       userInfo: nil];
        @throw exception;
    }
}


//event handler when event occurs
-(void)eventHandler: (NSNotification *) notification
{
    if ([notification.name isEqualToString:kNotificationShareInformationToFacebookOrTwitter]){
        [self performSelector:@selector(shareTwitterOrFacebook:) withObject:notification afterDelay:1.0f];
    }
}

- (void) shareTwitterOrFacebook:(NSNotification*) notification{
    NSDictionary *dictionary = [notification object];
    
    // create the item
    SHKItem *item = [SHKItem URL:[NSURL URLWithString:[dictionary objectForKey:@"url"]] title:[dictionary objectForKey:@"title"]];
    
    if ( [[dictionary objectForKey:@"type"] isEqualToString:@"Twitter"]){
        // send a tweet
        [SHKTwitter shareItem:item];
    }else{
        // facebook
        [SHKFacebook shareItem:item];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Application should handleOpenUrl = %@",url);
#endif
    
    // the "openphoto-test" is used for TestFlight tester
    if ([[url scheme] isEqualToString:@"openphoto"] ||
        [[url scheme] isEqualToString:@"openphoto-test"]){
        AuthenticationHelper *auth = [[AuthenticationHelper alloc]init];
        
        if ([auth isValid] == NO){
            [auth startOAuthProcedure:url];
        }
        
        [auth release];
    }else if ([[url scheme] hasPrefix:@"fb"]){
        [SHKFacebook handleOpenURL:url];
        return [self.facebook handleOpenURL:url];
    }
    
    return YES;
}

#pragma mark - Facebook API Calls
/**
 * Make a Graph API Call to get information about the current logged in user.
 */
- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT username,email FROM user WHERE uid=me()", @"query",
                                   nil];
    
    [self.facebook  requestWithMethodName:@"fql.query"
                                andParams:params
                            andHttpMethod:@"POST"
                              andDelegate:self];
}


/*
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    [self storeAuthData:[self.facebook accessToken] expiresAt:[self.facebook expirationDate]];
    [self apiFQLIMe];
}

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Couldn't login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    NSLog(@"fbDidLogout");
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    NSLog(@"fbSessionInvalidated");
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [alertView release];
    [self fbDidLogout];
}


#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response = %@",response);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    
    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.
    if ([result objectForKey:@"email"]) {
        // If basic information callback, set the UI objects to
        // display this.
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Email: %@", [result objectForKey:@"email"]);
        NSLog(@"Username: %@", [result objectForKey:@"username"]);
#endif
        [defaults setObject:[result objectForKey:@"email"] forKey:kFacebookUserConnectedEmail];
        [defaults setObject:[result objectForKey:@"username"] forKey:kFacebookUserConnectedUsername];
        [defaults synchronize];
        
        // notify the screen that user is logged
        [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookUserConnected object:nil ];
    }
}


/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Error code: %d", [error code]);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"App applicationWillResignActived, save database");
#endif
    
    // set the Timeline objects with state Uploading to RETRY
    [TimelinePhotos resetEntitiesOnStateUploadingInManagedObjectContext:[AppDelegate managedObjectContext]];
    
    NSError *saveError = nil;
    if (![[AppDelegate managedObjectContext] save:&saveError]){
        NSLog(@"Error to save context = %@",[saveError localizedDescription]);
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    // set the Timeline objects with state Uploading to RETRY
    [TimelinePhotos resetEntitiesOnStateUploadingInManagedObjectContext:[AppDelegate managedObjectContext]];
    
    NSError *saveError = nil;
    if (![[AppDelegate managedObjectContext] save:&saveError]){
        NSLog(@"Error to save context = %@",[saveError localizedDescription]);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    NSError *saveError = nil;
    if (![[AppDelegate managedObjectContext] save:&saveError]){
        NSLog(@"Error to save context = %@",[saveError localizedDescription]);
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // needs to update the Sync
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateTableWithAllPhotosAgain object:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"App will terminate, save database");
#endif
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    NSError *saveError = nil;
    if (![[AppDelegate managedObjectContext] save:&saveError]){
        NSLog(@"Error to save context = %@",[saveError localizedDescription]);
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}


//////// CORE DATA
#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [self getStoreUrl];
    
    // automatic update
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"Unresolved error with PersistStoreCoordinator %@, %@.", error, [error userInfo]);
        NSLog(@"Create the persistent file again.");
        
        // let's recreate it
        [managedObjectContext reset];
        [managedObjectContext lock];
        
        // delete file
        if ([[NSFileManager defaultManager] fileExistsAtPath:storeUrl.path]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
        [persistentStoreCoordinator release];
        persistentStoreCoordinator = nil;
        
        NSPersistentStoreCoordinator *r = [self persistentStoreCoordinator];
        [managedObjectContext unlock];
        
        return r;
        
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *) getStoreUrl{
    return [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                    stringByAppendingPathComponent: @"OpenPhotoCoreData.sqlite"]];
}

- (void) cleanDatabase{
    // let's recreate it
    if (managedObjectContext != nil){
        [managedObjectContext reset];
        [managedObjectContext lock];
    }
    
    // delete file
    NSURL *storeUrl = [self getStoreUrl];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storeUrl.path]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
    
    if (managedObjectContext != nil){
        [managedObjectContext unlock];
        [managedObjectContext release];
        managedObjectContext = nil;
    }
}

- (NSString *) user
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
}


//////// Internet details
#pragma mark -
#pragma mark Internet details
- (void) prepareConnectionInformation
{
    // check for internet connection
    // no internet assume
    self.internetActive = NO;
    self.hostActive = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReachable startNotifier];
    
    // do the first network check
    [self checkNetworkStatus:nil];
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            break;
        }
    }
    
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            self.hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.hostActive = YES;
            break;
        }
    }
}


- (void)dealloc
{
    [_window release];
    [_viewController release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [internetReachable release];
    [hostReachable release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tracker_ release];
    [super dealloc];
}


/////////////
/// FOR NOTIFICATION
////////////
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}


@end
