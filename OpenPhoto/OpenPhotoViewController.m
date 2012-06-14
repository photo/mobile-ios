//
//  OpenPhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2012 OpenPhoto
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "OpenPhotoViewController.h"

// Private interface definition
@interface OpenPhotoViewController() 
- (void) eventHandler: (NSNotification *) notification;
@end

@implementation OpenPhotoViewController

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.viewControllers = [NSArray arrayWithObjects:
                            [self viewControllerWithTabTitle:@"Home" image:[UIImage imageNamed:@"tab-home.png"]],
                            [self viewControllerWithTabTitle:@"Gallery" image:[UIImage imageNamed:@"tab-gallery.png"]],
                            [self viewControllerWithTabTitle:@"Photo" image:nil],
                            [self viewControllerWithTabTitle:@"Multi Upload" image:[UIImage imageNamed:@"tab-sync.png"]],
                            [self viewControllerWithTabTitle:@"Settings" image:[UIImage imageNamed:@"tab-settings.png"]], nil];
    
    //register to listen for to show the login screen.    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(eventHandler:)
                                                 name:kNotificationLoginNeeded       
                                               object:nil ];
}

- (void)viewWillAppear:(BOOL)animated{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"IconCentralButton.png"] highlightImage:nil];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED    
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationLoginNeeded]){
        // open the authentication screen
        AuthenticationViewController *controller = [[AuthenticationViewController alloc]init];
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
