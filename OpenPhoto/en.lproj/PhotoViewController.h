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

@interface PhotoViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AFFeatherDelegate, CoreLocationControllerDelegate, MBProgressHUDDelegate>{
    
    IBOutlet UITextField *imageTitle;
    IBOutlet UITextView *imageDescription;
    UIActivityIndicatorView *statusBar;
    UIImage* imageOriginal;
    UIImage* imageFiltered;
    UITableView *detailsPictureTable;
    UITextField *titleTextField;
    UITextField *descriptionTextField;
    UISwitch *permissionPicture;
    UISwitch *highResolutionPicture;
    TagViewController *tagController;
    UIImagePickerControllerSourceType sourceType;
    UISwitch *gpsPosition;
    CoreLocationController *coreLocationController;
    CLLocation *location;
    
    // for uploading
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    
    // to check if there is connection
    WebService *service;
    NSMutableData *responseData;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *statusBar;
@property (nonatomic, retain) UIImage *imageOriginal;
@property (nonatomic, retain) UIImage *imageFiltered;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UITextField *descriptionTextField;
@property (nonatomic, retain) UISwitch *permissionPicture;
@property (nonatomic, retain) UISwitch *highResolutionPicture;
@property (nonatomic, retain) TagViewController *tagController;
@property (nonatomic) UIImagePickerControllerSourceType sourceType;    
@property (nonatomic, retain) UISwitch *gpsPosition;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) WebService *service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photo:(UIImage *) image source:(UIImagePickerControllerSourceType) pickerSourceType;
- (IBAction)upload:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *detailsPictureTable;

@end
