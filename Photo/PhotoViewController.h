//
//  PhotoViewController.h
//  Photo
//
//  Created by Patrick Santana on 29/07/11.
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
//

#import "TagViewController.h"
#import "AFPhotoEditorController.h"
#import "Synced+Photo.h"
#import "Timeline+Photo.h"

#import "ContentTypeUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibraryUtilities.h"

@interface PhotoViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AFPhotoEditorControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *detailsPictureTable;

// in case of one image. The user can
// edit it
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *imageFiltered;

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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera image:(UIImage*) originalImage;
// construct that receives a list with all images URL from Sync
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil images:(NSArray *) imagesFromSync;

// action to start uploading
- (IBAction)upload:(id)sender;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;

// assets library
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end
