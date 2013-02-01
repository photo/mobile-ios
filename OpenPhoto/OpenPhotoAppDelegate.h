//
//  OpenPhotoAppDelegate.h
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

#import <UIKit/UIKit.h>
#import "InitializerHelper.h"
#import "AuthenticationHelper.h"
#import "AuthenticationViewController.h"
#import "UpdateUtilities.h"
#import "SHKItem.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"
#import "SHKConfiguration.h"
#import "SHK.h"
#import "Reachability.h"
#import "JobUploaderController.h"
#import "LoginViewController.h"
#import "FBConnect.h"
#import "iRate.h"

#import "GAI.h"

// easy way to get app delegate
#define AppDelegate (OpenPhotoAppDelegate*) [[UIApplication sharedApplication] delegate]


@class OpenPhotoViewController;

@interface OpenPhotoAppDelegate : NSObject <UIApplicationDelegate,FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate>{
    
@private
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    // for internet checks
    Reachability* internetReachable;
    Reachability* hostReachable;
    
    // facebook sdk
    Facebook *facebook;
    
@public
    BOOL internetActive, hostActive;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenPhotoViewController *viewController;

// for core data
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// for internet check
@property (nonatomic) BOOL  internetActive;
@property (nonatomic) BOOL  hostActive;

// for facebook single sign in
@property (nonatomic, retain) Facebook *facebook;

//google analytics
@property(nonatomic, retain) id<GAITracker> tracker;

// this method will be used to open a specific tab
// 0 = Home
// 1 = Gallery
// 3 = Tag
// 4 = Settings
- (void) openTab:(int) position;

// remove the current database and create everything again
// watch out with the table SyncPhotos. We don't wanna lose details of this with upgrade.
- (void) cleanDatabase;

// get the user connect
- (NSString *) user;
@end
