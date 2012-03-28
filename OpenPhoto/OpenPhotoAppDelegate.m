//
//  OpenPhotoAppDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoAppDelegate.h"
#import "OpenPhotoViewController.h"



@interface OpenPhotoAppDelegate()
-(void) shareTwitterOrFacebook:(NSString *) message;
@end

@implementation OpenPhotoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Allow HTTP response size to be unlimited.
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    // Configure the in-memory image cache to keep approximately
    // 10 images in memory, assuming that each picture's dimensions
    // are 320x480. Note that your images can have whatever dimensions
    // you want, I am just setting this to a reasonable value
    // since the default is unlimited.
    [[TTURLCache sharedCache] setMaxPixelCount:10*640*960];
    
#ifdef TEST_FLIGHT_ENABLED
    // to start the TestFlight SDK
    [TestFlight takeOff:@"407f45aed7c5bc2fc88cb567078edb1f_MjMyNTUyMDExLTA5LTEyIDEyOjEyOjU3Ljc1Nzg5MA"];
    [TestFlight passCheckpoint:@"Started App"];
#endif
    
    // in development phase we use the UID of user
#ifdef DEVELOPMENT_ENABLED
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    UpdateUtilities *updater = [UpdateUtilities instance];
    if ([updater needsUpdate] == YES){
        NSLog(@"App needs to be updated");
        NSLog(@"Version to install %@", [updater getVersion]);
        [updater update];
        [updater updateSystemVersion];
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
        // open the authentication screen
        AuthenticationViewController *controller = [[AuthenticationViewController alloc]init];
        [self.window.rootViewController presentModalViewController:controller animated:YES];
        [controller release];
    }
    [auth release];
    
    [self.window makeKeyAndVisible];
    
    
    //register to share data.    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(eventHandler:)
                                                 name:kNotificationShareInformationToFacebookOrTwitter         
                                               object:nil ];
    
    
    return YES;
}


- (void) openTab:(int) position{
    NSLog(@"Opening the tab with position id = %i",position);
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
    NSLog(@"Application should handleOpenUrl = %@",url);
    
    if ([[url scheme] isEqualToString:@"openphoto"]){
        AuthenticationHelper *auth = [[AuthenticationHelper alloc]init];
        
#ifdef TEST_FLIGHT_ENABLED
        [TestFlight passCheckpoint:@"Started OAuth Procedure"];
#endif
        
        if ([auth isValid] == NO){
            [auth startOAuthProcedure:url];
        }
        
        [auth release];
    }else if ([[url scheme] hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]]){
        return [SHKFacebook handleOpenURL:url];
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
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"OpenPhotoCoreData.sqlite"]];
    
    // automatic update
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"Unresolved error with PersistStoreCoordinator %@, %@. Create the persistent file again.", error, [error userInfo]);
        
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


- (void)dealloc
{
    [_window release];
    [_viewController release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
