//
//  AppDelegate.m
//  CuteAnimals
//
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "NavController.h"
#import "RootViewController.h"

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-TRACKING-ID";
static NSString *const kAllowTracking = @"allowTracking";

@interface AppDelegate ()

- (NSDictionary *)loadImages;

@end

@implementation AppDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application {
  [GAI sharedInstance].optOut =
      ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
}
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.images = [self loadImages];
  NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  // User must be able to opt out of tracking
  [GAI sharedInstance].optOut =
      ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
  // Initialize Google Analytics with a 120-second dispatch interval. There is a
  // tradeoff between battery usage and timely dispatch.
  [GAI sharedInstance].dispatchInterval = 120;
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  self.tracker = [[GAI sharedInstance] trackerWithName:@"CuteAnimals"
                                            trackingId:kTrackingId];

  self.window =
      [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.viewController =
      [[RootViewController alloc] initWithNibName:@"RootViewController"
                                            bundle:nil];

  self.navController =
      [[NavController alloc] initWithRootViewController:self.viewController];
  self.navController.delegate = self.navController;

  self.window.rootViewController = self.navController;
  [self.window makeKeyAndVisible];

  return YES;
}


- (NSDictionary *)loadImages {
  NSArray *contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                         inDirectory:nil];
  if (!contents) {
    NSLog(@"Failed to load directory contents");
    return nil;
  }
  NSMutableDictionary *images = [NSMutableDictionary dictionary];
  for (NSString *file in contents) {
    NSArray *components = [[file lastPathComponent]
                           componentsSeparatedByString:@"-"];
    if (components.count == 0) {
      NSLog(@"Filename doesn't contain dash: %@", file);
      continue;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    if (!image) {
      NSLog(@"Failed to load file: %@", file);
      continue;
    }
    NSString *prefix = components[0];
    NSMutableArray *categoryImages = images[prefix];
    if (!categoryImages) {
      categoryImages = [NSMutableArray array];
      images[prefix] = categoryImages;
    }
    [categoryImages addObject:image];
  }
  for (NSString *cat in [images allKeys]) {
    NSArray *array = images[cat];
    NSLog(@"Category %@: %u image(s).", cat, array.count);
  }
  return images;
}

@end
