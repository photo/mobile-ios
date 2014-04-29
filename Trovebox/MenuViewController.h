//
//  MenuViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 5/10/12.
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
#import "AuthenticationService.h"
#import "TagViewController.h"
#import "AlbumViewController.h"
#import "HomeTableViewController.h"
#import "SyncViewController.h"
#import "AccountViewController.h"
#import "ProfileViewController.h"
#import "GalleryViewController.h"
#import "CoreLocationController.h"

// for settings
#import "IASKAppSettingsViewController.h"
#import "IASKSettingsStoreFile.h"

// specific cell
#import "MenuTableViewSearchCell.h"
#import "MenuTableViewSectionCell.h"
#import "MenuTableViewCell.h"


@interface MenuViewController : UITableViewController<IASKSettingsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CoreLocationControllerDelegate, UIImagePickerControllerDelegate>
{
    // ask the user about location int the home screen
    CoreLocationController *coreLocationController;
    
    ALAssetsLibrary *library;
}

@property (nonatomic, strong) OpenPhotoIASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, strong) UINavigationController *galleryController;
@property (nonatomic, strong) UINavigationController *albumController;
@property (nonatomic, strong) UINavigationController *tagController;
@property (nonatomic, strong) UINavigationController *syncController;
@property (nonatomic, strong) UINavigationController *profileController;


@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) UIPopoverController* popoverController;

- (void) openCamera:(id) sender;
- (void) selectLatestActivity;
- (void) displayProfileScreen;
- (void) displayHomeScreen;
@end
