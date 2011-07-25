//
//  OpenPhotoAppDelegate.h
//  OpenPhoto
//
//  Created by Patrick Santana on 25/07/11.
//  Copyright 2011 Moogu bvba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenPhotoViewController;

@interface OpenPhotoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet OpenPhotoViewController *viewController;

@end
