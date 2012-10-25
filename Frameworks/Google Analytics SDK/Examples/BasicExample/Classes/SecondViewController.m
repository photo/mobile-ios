//
//  SecondViewController.m
//  BasicExample
//
//  Created by Farooq Mela on 4/10/12.
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import "SecondViewController.h"
#import "GANTracker.h"

@implementation SecondViewController

@synthesize button = button_;

- (void)viewDidAppear:(BOOL)animated {
  NSLog(@"Second View appeared!");
  [[GANTracker sharedTracker] trackPageview:@"SecondView" withError:nil];
  [super viewDidAppear:animated];
}

- (IBAction)buttonClicked:(id)sender {
  NSLog(@"Second View button clicked!");
  [[GANTracker sharedTracker] trackEvent:@"Button"
                                  action:@"Click"
                                   label:@"Second Button"
                                   value:-1
                               withError:nil];
}

@end
