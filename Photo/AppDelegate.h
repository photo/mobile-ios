//
//  AppDelegate.h
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

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "ViewController.h"
#import "MenuViewController.h"
#import "RightViewController.h"
#import "iRate.h"
#import "AuthenticationService.h"
#import "AuthenticationViewController.h"
#import "Reachability.h"
#import "SHKItem.h"
#import "SHKTwitter.h"
#import "SHKFacebook.h"
#import "SHKConfiguration.h"
#import "SHK.h"
#import "PhotoSHKConfigurator.h"
#import "InitializerService.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,FBRequestDelegate,
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


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


// for internet check
@property (nonatomic) BOOL  internetActive;
@property (nonatomic) BOOL  hostActive;

// for facebook single sign in
@property (nonatomic, strong) Facebook *facebook;

// navigation
@property (strong, nonatomic) UIViewController *centerController;
@property (strong, nonatomic) UIViewController *menuController;
@property (strong, nonatomic) UIViewController *imageController;


@end
