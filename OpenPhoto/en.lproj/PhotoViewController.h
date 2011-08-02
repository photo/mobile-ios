//
//  PhotoViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSStrings.h"
#import "OpenPhotoBase64Utilities.h"
#import "FilterViewController.h"

#define kNumbersRow     5

@interface PhotoViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    IBOutlet UITextField *imageTitle;
    IBOutlet UITextView *imageDescription;
    UIActivityIndicatorView *statusBar;
    UIImage* imageToSend;
    UITableView *detailsPictureTable;
    UITextField *titleTextField;
    UITextField *descriptionTextField;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *statusBar;
@property (nonatomic, retain) UIImage *imageToSend;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UITextField *descriptionTextField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photo:(UIImage *) image;
- (IBAction)upload:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *detailsPictureTable;

@end
