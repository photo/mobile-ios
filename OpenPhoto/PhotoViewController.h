//
//  PhotoViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSStrings.h"

@interface PhotoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
}

- (IBAction)snapshot:(id)sender;
- (IBAction)cameraRoll:(id)sender;

@end
