//
//  FirstViewController.m
//  BasicExample
//
//  Created by Farooq Mela on 4/10/12.
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "FirstViewController.h"
#import "GANTracker.h"

@implementation FirstViewController

@synthesize button = button_;

- (void)viewDidAppear:(BOOL)animated {
  NSLog(@"First View appeared!");
  [[GANTracker sharedTracker] trackPageview:@"FirstView" withError:nil];
  [super viewDidAppear:animated];
}

- (IBAction)buttonClicked:(id)sender {
  NSLog(@"First View button clicked!");
  [[GANTracker sharedTracker] trackEvent:@"Button"
                                  action:@"Click"
                                   label:@"First Button"
                                   value:-1
                               withError:nil];
}

@end
