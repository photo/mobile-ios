//
//  PhotoViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
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

#import "TagViewController.h"
#import "AFFeatherController.h"
#import "QSUtilities.h"
#import "SyncedPhotos+OpenPhoto.h"
#import "TimelinePhotos+OpenPhoto.h"

#import "ContentTypeUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibraryUtilities.h"

@interface PhotoViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AFFeatherDelegate>{
    ALAssetsLibrary *assetsLibrary;
}

@property (nonatomic, retain) IBOutlet UITableView *detailsPictureTable;

// in case of one image. The user can 
// edit it
@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *imageFiltered;

// in case of user getting an image from the snapshot
@property (nonatomic, retain) NSURL *image;
// List of all images form the sync
@property (nonatomic, retain) NSArray *images;

@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UISwitch *permissionPicture;
@property (nonatomic, retain) UISwitch *shareFacebook;
@property (nonatomic, retain) UISwitch *shareTwitter;

@property (nonatomic, retain) TagViewController *tagController;

// total of images to process. We use this variable to decrease everytime 
// when an image is saved in the database
// at the moment it turns 0, all images were processed and user can be redirected to the main screen
@property (nonatomic) int imagesToProcess;

// construct that receive the snapshot
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera image:(UIImage*) originalImage;
// construct that receives a list with all images URL from Sync
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil images:(NSArray *) imagesFromSync;

// action to start uploading
- (IBAction)upload:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *uploadButton;

@end
