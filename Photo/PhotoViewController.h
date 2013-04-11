//
//  PhotoViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 29/07/11.
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

#import "TagViewController.h"
#import "Synced+Methods.h"
#import "Timeline+Methods.h"

#import "ContentTypeUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibraryUtilities.h"

#import "GAI.h"

@interface PhotoViewController : GAITrackedViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *detailsPictureTable;

// in case of user getting an image from the snapshot
@property (nonatomic, strong) NSURL *image;
// List of all images form the sync
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UISwitch *permissionPicture;
@property (nonatomic, strong) UISwitch *shareFacebook;
@property (nonatomic, strong) UISwitch *shareTwitter;

@property (nonatomic, retain) TagViewController *tagController;

// construct that receive the snapshot
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera;
// construct that receives a list with all images URL from Sync
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil images:(NSArray *) imagesFromSync;

// assets library
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end
