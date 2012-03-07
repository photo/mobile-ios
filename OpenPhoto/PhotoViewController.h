//
//  PhotoViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageManipulation.h"
#import "TagViewController.h"
#import "MBProgressHUD.h"
#import "AFFeatherController.h"
#import "CoreLocationController.h"
#import "OpenPhotoAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "AssetsLibraryUtilities.h"
#import "extThree20JSON/NSString+SBJSON.h"
#import "QSUtilities.h"

@interface PhotoViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AFFeatherDelegate, MBProgressHUDDelegate>{
    
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
    
    // for uploading
    MBProgressHUD *HUD;
    
    // to check if there is connection
    WebService *service;
    
    
    // filename to delete
    NSString *fileNameToDelete;
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
@property (nonatomic, retain) WebService *service;

@property (nonatomic, retain) NSString *fileNameToDelete;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photoUrl:(NSURL *) url photo:(UIImage *) image source:(UIImagePickerControllerSourceType) pickerSourceType;
- (IBAction)upload:(id)sender;

@end
