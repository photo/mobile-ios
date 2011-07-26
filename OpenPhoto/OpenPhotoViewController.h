//
//  OpenPhotoViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 25/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenPhotoViewController : UIViewController{
    IBOutlet UIImageView *imageMenu;
}

@property(nonatomic,retain) UIImageView *imageMenu;

- (IBAction)openTags:(id)sender;
- (IBAction)openUpload:(id)sender;
- (IBAction)openGallery:(id)sender;
- (IBAction)openSettings:(id)sender;



@end
