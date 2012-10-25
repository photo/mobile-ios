//
//  BasicExampleAppDelegate.h
//  Google Analytics iOS SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANTracker.h"

@interface BasicExampleAppDelegate : NSObject <UIApplicationDelegate,
                                               UITabBarControllerDelegate,
                                               GANTrackerDelegate> {
    UIWindow *window_;
    UITabBarController *tabBarController_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
