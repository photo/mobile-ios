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

// easy way to get app delegate
#define AppDelegate (OpenPhotoAppDelegate*) [[UIApplication sharedApplication] delegate]


@class OpenPhotoViewController;

@interface OpenPhotoAppDelegate : NSObject <UIApplicationDelegate>{

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

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenPhotoViewController *viewController;

// for core data
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// for internet check
@property (nonatomic) BOOL  internetActive;
@property (nonatomic) BOOL  hostActive;

// this method will be used to open a specific tab
// 0 = Home
// 1 = Gallery
// 3 = Tag
// 4 = Settings
- (void) openTab:(int) position;

@end
