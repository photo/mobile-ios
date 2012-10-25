//
//  BasicExampleAppDelegate.m
//  Google Analytics iOS SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import "BasicExampleAppDelegate.h"

// **************************************************************************
// Replace this string with your Analytics account ID!
// **************************************************************************
static NSString *const kAnalyticsAccountId = @"UA-00000000-1";
// Dispatch period in seconds.
static const NSInteger kDispatchPeriodSeconds = 10;

@implementation BasicExampleAppDelegate

@synthesize window = window_;
@synthesize tabBarController = tabBarController_;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
                                         dispatchPeriod:kDispatchPeriodSeconds
                                               delegate:self];

  NSError *error = nil;
  if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                       name:@"iOS1"
                                                      value:@"iv1"
                                                  withError:&error]) {
    NSLog(@"setCustomVariableAtIndex failed: %@", error);
  }

  [self.window addSubview:self.tabBarController.view];
  [self.window makeKeyAndVisible];

  return YES;
}

#pragma mark -
#pragma mark GANTrackerDelegate methods

- (void)hitDispatched:(NSString *)hitString {
  NSLog(@"Hit Dispatched: %@", hitString);
}

- (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)hitsDispatched
              eventsFailedDispatch:(NSUInteger)hitsFailedDispatch {
  NSLog(@"Dispatch completed (%u OK, %u failed)",
        hitsDispatched, hitsFailedDispatch);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [tabBarController_ release];
  [window_ release];
  [super dealloc];
}

@end
