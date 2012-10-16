//
//  AppDelegate.m
//  Photo
//
//  Created by Patrick Santana on 25/09/12.
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

#import "AppDelegate.h"

@interface AppDelegate()
-(void) shareTwitterOrFacebook:(NSString *) message;
-(void) prepareConnectionInformation;
-(void) checkNetworkStatus:(NSNotification *) notice;
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize internetActive = _internetActive;
@synthesize hostActive = _hostActive;
@synthesize facebook = _facebook;

@synthesize centerController = _viewController;
@synthesize menuController = _menuController;
@synthesize imageController = _imageController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // in development phase we use the UID of user
#ifdef DEVELOPMENT_ENABLED
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
#ifdef TEST_FLIGHT_ENABLED
    // to start the TestFlight SDK
    [TestFlight takeOff:kPrivateTestFlightId];
#endif
    
    [self prepareConnectionInformation];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.menuController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    RightViewController* rightController = [[RightViewController alloc] initWithNibName:@"RightViewController" bundle:nil];
    
    ViewController *centerController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.centerController
                                                                                    leftViewController:self.menuController
                                                                                   rightViewController:rightController];
    deckController.rightLedge = 100;
    
    
    // FACEBOOK
    self.facebook = [[Facebook alloc] initWithAppId:kPrivateFacebookAppId andDelegate:self];
    
    //ShareKit
    DefaultSHKConfigurator *configurator = [[PhotoSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    // initializer
    InitializerService *service = [[InitializerService alloc]init];
    if ([service isInitialized] == NO){
        [service initialize];
    }
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

+ (void) initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 10;
    [iRate sharedInstance].usesUntilPrompt = 6;
    [iRate sharedInstance].appStoreID = kPrivateappStoreID;
    [iRate sharedInstance].applicationBundleID = kPrivateapplicationBundleID;
    [iRate sharedInstance].applicationName=kPrivateapplicationName;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Application should handleOpenUrl = %@",url);
#endif
    
    // the "photo-test" is used for TestFlight tester and community contributors
    if ([[url scheme] isEqualToString:@"photo-test"]){
        AuthenticationService *auth = [[AuthenticationService alloc]init];
        
        if ([auth isLogged] == NO){
            [auth startOAuthProcedure:url];
        }
    }else if ([[url scheme] hasPrefix:@"fb"]){
        // [SHKFacebook handleOpenURL:url];
        // return [self.facebook handleOpenURL:url];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
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
    SHKItem *item = [SHKItem URL:[NSURL URLWithString:[dictionary objectForKey:@"url"]] title:[dictionary objectForKey:@"title"] contentType:SHKURLContentTypeWebpage];
    
    if ( [[dictionary objectForKey:@"type"] isEqualToString:@"Twitter"]){
        // send a tweet
        [SHKTwitter shareItem:item];
    }else{
        // facebook
        [SHKFacebook shareItem:item];
    }
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
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *localManagedObjectContext = self.managedObjectContext;
    if (localManagedObjectContext != nil) {
        if ([localManagedObjectContext hasChanges] && ![localManagedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Photo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Photo.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
    
    internetReachable = [Reachability reachabilityForInternetConnection] ;
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"] ;
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

@end
