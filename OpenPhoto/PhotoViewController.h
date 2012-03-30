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
#import "AssetsLibraryUtilities.h"
#import "QSUtilities.h"
#import "UploadPhotos+OpenPhoto.h"
#import "ContentTypeUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AFFeatherDelegate>{
    
    IBOutlet UITextField *imageTitle;
    
    NSURL* urlImageOriginal;
    UIImage* imageOriginal;
    UIImage* imageFiltered;
    
    UITableView *detailsPictureTable;
    UITextField *titleTextField;
    
    UISwitch *permissionPicture;
    UISwitch *shareFacebook;
    UISwitch *shareTwitter;
    
    TagViewController *tagController;
    UIImagePickerControllerSourceType sourceType;
}


@property (nonatomic, retain) IBOutlet UITableView *detailsPictureTable;

@property (nonatomic, retain) NSURL *urlImageOriginal;
@property (nonatomic, retain) UIImage *imageOriginal;
@property (nonatomic, retain) UIImage *imageFiltered;

@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UISwitch *permissionPicture;
@property (nonatomic, retain) UISwitch *shareFacebook;
@property (nonatomic, retain) UISwitch *shareTwitter;

@property (nonatomic, retain) TagViewController *tagController;
@property (nonatomic) UIImagePickerControllerSourceType sourceType;    

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photoUrl:(NSURL *) url photo:(UIImage *) image source:(UIImagePickerControllerSourceType) pickerSourceType;
- (IBAction)upload:(id)sender;

@end
