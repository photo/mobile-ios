//
//  BaseViewController.h
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "HomeTableViewController.h"
#import "GalleryViewController.h"
#import "QSStrings.h"
#import "PhotoViewController.h"
#import "IASKAppSettingsViewController.h"
#import "IASKSettingsStoreFile.h"
#import "AuthenticationHelper.h"
#import "OpenPhotoIASKAppSettingsViewController.h"
#import "CoreLocationController.h"

// for sync
#import "ELCImagePickerController.h"
#import "MBProgressHUD.h"
#import "SyncViewController.h"

// for clean the cache
#import "GalleryPhotos+OpenPhoto.h"
#import "TimelinePhotos+OpenPhoto.h"

@interface BaseViewController : UITabBarController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, IASKSettingsDelegate, CoreLocationControllerDelegate, ELCImagePickerControllerDelegate, UITabBarDelegate>{
    OpenPhotoIASKAppSettingsViewController *appSettingsViewController;
    
    // for location
    CoreLocationController *coreLocationController;
    CLLocation *location;  
    
    // better to keep here for faster access - schedules the asset read
    ALAssetsLibrary* assetsLibrary;
}

@property (nonatomic, retain) OpenPhotoIASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, retain) CLLocation *location;

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
