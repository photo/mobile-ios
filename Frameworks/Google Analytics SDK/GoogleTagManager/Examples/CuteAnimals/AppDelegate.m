//
//  AppDelegate.m
//  CuteAnimals
//
//  Copyright 2013 Google, Inc. All rights reserved.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "AppDelegate.h"
#import "CustomMacroHandler.h"
#import "CustomTagHandler.h"
#import "NavController.h"
#import "RootViewController.h"
#import "TAGContainer.h"
#import "TAGContainerOpener.h"
#import "TAGLogger.h"
#import "TAGManager.h"

@interface AppDelegate ()

- (NSDictionary *)loadImages;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController = _navController;
@synthesize viewController = _viewController;
@synthesize images = _images;
@synthesize tagManager = _tagManager;
@synthesize container = _container;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.tagManager = [TAGManager instance];

  // Modify the log level of the logger to print out not only
  // warning and error messages, but also verbose, debug, info messages.
  [self.tagManager.logger setLogLevel:kTAGLoggerLogLevelVerbose];

  // Following provides ability to support preview from Tag Manager.
  // You need to make these calls before opening a container to make
  // preview works.
  NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
  if (url != nil) {
    [self.tagManager previewWithUrl:url];
  }

  // Open a container.
  id<TAGContainerFuture> future =
      [TAGContainerOpener openContainerWithId:@"GTM-XXXX"
                                   tagManager:self.tagManager
                                     openType:kTAGOpenTypePreferNonDefault
                                      timeout:nil];

  self.images = [self loadImages];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  self.container = [future get];
  // Register two custom function call macros to the container.
  [self.container registerFunctionCallMacroHandler:[[CustomMacroHandler alloc] init]
                                          forMacro:@"increment"];
  [self.container registerFunctionCallMacroHandler:[[CustomMacroHandler alloc] init]
                                          forMacro:@"mod"];
  // Register a custom function call tag to the container.
  [self.container registerFunctionCallTagHandler:[[CustomTagHandler alloc] init]
                                          forTag:@"custom_tag"];

  self.viewController = [[RootViewController alloc] initWithNibName:@"RootViewController"
                                                             bundle:nil];

  self.navController = [[NavController alloc] initWithRootViewController:self.viewController];
  self.navController.delegate = self.navController;

  self.viewController.navController = self.navController;
  self.window.rootViewController = self.navController;
  [self.window makeKeyAndVisible];

  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  if ([self.tagManager previewWithUrl:url]) {
    return YES;
  }

  // Code to handle other urls.

  return NO;
}

- (NSDictionary *)loadImages {
  NSArray *contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                         inDirectory:nil];
  if (!contents) {
    NSLog(@"Failed to load directory contents");
    return nil;
  }
  NSMutableDictionary *images = [NSMutableDictionary dictionaryWithCapacity:0];
  for (NSString *file in contents) {
    NSArray *components = [[file lastPathComponent] componentsSeparatedByString:@"-"];
    if (components.count == 0) {
      NSLog(@"Filename doesn't contain dash: %@", file);
      continue;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    if (!image) {
      NSLog(@"Failed to load file: %@", file);
      continue;
    }
    NSString *prefix = [components objectAtIndex:0];
    NSMutableArray *categoryImages = [images objectForKey:prefix];
    if (!categoryImages) {
      categoryImages = [NSMutableArray arrayWithCapacity:0];
      [images setObject:categoryImages
                 forKey:prefix];
    }
    [categoryImages addObject:image];
  }
  for (NSString *cat in [images allKeys]) {
    NSArray *array = [images objectForKey:cat];
    NSLog(@"Category %@: %u image(s).", cat, array.count);
  }
  return images;
}

@end
