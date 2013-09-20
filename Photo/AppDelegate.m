//
//  AppDelegate.m
//  Trovebox
//
//  Created by Patrick Santana on 25/09/12.
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

#import "AppDelegate.h"

@interface AppDelegate()
-(void) shareTwitterOrFacebook:(NSString *) message;
-(void) prepareConnectionInformation;
-(void) checkNetworkStatus:(NSNotification *) notice;
@end

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize internetActive = _internetActive;
@synthesize hostActive = _hostActive;

@synthesize centerController = _viewController;
@synthesize menuController = _menuController;

@synthesize tracker = tracker_;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Crashlytics startWithAPIKey:@"263e33cba7a0a8804ec757ba8607fc77514dca33"];
    
#ifdef GOOGLE_ANALYTICS_ENABLED
    // Google Analytics SDK
    // Initialize Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 20;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kPrivateGoogleAnalytics];
    
    [GoogleConversionPing pingWithConversionId:@"1000325738" label:@"QHgDCN6SygQQ6oT_3AM" value:@"0" isRepeatable:NO];
#endif
    
    [self prepareConnectionInformation];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.menuController = [[MenuViewController alloc] init];
    
    HomeTableViewController *centerController = [[HomeTableViewController alloc] init];
    self.centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.centerController
                                                                                    leftViewController:self.menuController];
    
    if ([DisplayUtilities isIPad]){
        deckController.leftLedge = 490.0;
    }
       
    //ShareKit
    DefaultSHKConfigurator *configurator = [[PhotoSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    // initializer
    InitializerService *initializer = [[InitializerService alloc]init];
    if ([initializer isInitialized] == NO){
        [initializer initialize];
    }
    
    // updater
    UpdateUtilities *updater = [UpdateUtilities instance];
    if ([updater needsUpdate]) {
        [updater update];
    }
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    
    
    // check if use is connect
    if (![AuthenticationService isLogged]){
        // reset core data
        [Timeline deleteAllTimelineInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
        [Synced deleteAllSyncedPhotosInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
        [[SharedAppDelegate managedObjectContext] reset];
        
        NSError *saveError = nil;
        if (![[SharedAppDelegate managedObjectContext] save:&saveError]){
            NSLog(@"Error deleting objects from core data = %@",[saveError localizedDescription]);
        }
        
        [self presentLoginViewController];
    }
    
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
    
    // Payment setup
    if ([SKPaymentQueue canMakePayments]) {
        TroveboxSubscription *subscription = [TroveboxSubscription troveboxSubscription];
        [subscription requestProUpgradeProductData];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[TroveboxPaymentTransactionObserver troveboxPaymentTransactionObserver]];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

- (void) presentLoginViewController
{
    LoginViewController *controller;
    
    if ([DisplayUtilities isIPad]){
        controller = [[LoginViewController alloc]initWithNibName:@"LoginViewControlleriPad" bundle:nil ];
        
    }else{
        controller = [[LoginViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"LoginViewController"] bundle:nil ];
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    navController.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

+ (void) initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 7;
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
    
    if ([[url scheme] isEqualToString:@"openphoto"]){
        AuthenticationService *auth = [[AuthenticationService alloc]init];
        
        if ([AuthenticationService isLogged] == NO){
            [auth startOAuthProcedure:url];
        }
        
        
        // check details
        // openphoto://open=/p/:id // photo
        // openphoto://open=/v/:id // video
        // openphoto://open=/m/:id // media
        
    }else if ([[url scheme] hasPrefix:@"fb"]){
        return [SHKFacebook handleOpenURL:url];
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
    // automatic update
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSLog(@"Unresolved error with PersistStoreCoordinator %@, %@.", error, [error userInfo]);
        NSLog(@"Create the persistent file again.");
        
        // let's recreate it
        [managedObjectContext reset];
        [managedObjectContext lock];
        
        // delete file
        if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
        _persistentStoreCoordinator = nil;
        
        NSPersistentStoreCoordinator *r = [self persistentStoreCoordinator];
        [managedObjectContext unlock];
        
        return r;
        
        
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

- (NSString *) userHost
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kTroveboxServer];
}

- (NSString *) userEmail
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kTroveboxEmailUser];
}

- (BOOL) isHosted
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [[standardUserDefaults valueForKey:kServerDetailsIsHosted] boolValue];
}

- (BOOL) isProUser
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [[standardUserDefaults valueForKey:kProfileAccountType] boolValue];
}

- (BOOL) isFreeUser
{
    return ![self isProUser];
}

- (NSInteger) limitFreeUser
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [[standardUserDefaults valueForKey:kProfileLimitRemaining] integerValue];
}

- (NSInteger) limitAllowed
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [[standardUserDefaults valueForKey:kProfileLimitAllowed] integerValue];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
