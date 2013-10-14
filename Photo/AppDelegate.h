//
//  AppDelegate.h
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

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "MenuViewController.h"
#import "SyncViewController.h"
#import "iRate.h"
#import "AuthenticationService.h"
#import "AuthenticationViewController.h"
#import "Reachability.h"

#import "PhotoSHKConfigurator.h"
#import "InitializerService.h"
#import "HomeTableViewController.h"
#import "JobUploaderController.h"
#import "ELCImagePickerController.h"
#import "LoginViewController.h"
#import "AuthenticationService.h"

#import <Crashlytics/Crashlytics.h>

//for payment
#import <StoreKit/StoreKit.h>
#import "TroveboxPaymentTransactionObserver.h"
#import "TroveboxSubscription.h"

#import "SHK.h"
#import "SHKItem.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"
#import "SHKConfiguration.h"
#import "FBConnect.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
@private
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    // for internet checks
    Reachability* internetReachable;
    Reachability* hostReachable;
       
@public
    BOOL internetActive, hostActive;
}


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


// for internet check
@property (nonatomic) BOOL  internetActive;
@property (nonatomic) BOOL  hostActive;

//google analytics
@property(nonatomic, strong) id<GAITracker> tracker;

// navigation
@property (nonatomic, strong) UIViewController *centerController;
@property (nonatomic, strong) UIViewController *menuController;

// get the user connect
- (NSString *) userHost;
- (NSString *) userEmail;
- (BOOL) isHosted;
- (BOOL) isProUser;
- (BOOL) isFreeUser;
- (NSInteger) limitFreeUser;
- (NSInteger) limitAllowed;

// if we need to forward the user to the login view controller
- (void) presentLoginViewController;


@end
