//
//  PhotoViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSStrings.h"

@interface PhotoViewController : UIViewController {
    IBOutlet UITextField *imageTitle;
    IBOutlet UITextView *imageDescription;
    UIImageView *imagePreview;
    UIActivityIndicatorView *statusBar;
    UIImage* image;
}
@property (nonatomic, retain) IBOutlet UIImageView *imagePreview;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *statusBar;
@property (nonatomic, retain) UIImage *image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photo:(UIImage *) image withNavigation:(UINavigationController*) navigationController;
- (IBAction)upload:(id)sender;


@end
