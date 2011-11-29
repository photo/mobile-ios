//
//  OpenPhotoAppDelegate.h
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitializerHelper.h"
#import "AuthenticationHelper.h"
#import "AuthenticationViewController.h"
#import "UpdateUtilities.h"

@class OpenPhotoViewController;

@interface OpenPhotoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet OpenPhotoViewController *viewController;


// this method will be used to open the gallery after the user upload a picture
-(void) openGallery;
@end
