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
                            [self viewControllerWithTabTitle:@"Home" image:[UIImage imageNamed:@"tab-icon1.png"]],
                            [self viewControllerWithTabTitle:@"Gallery" image:[UIImage imageNamed:@"tab-icon2.png"]],
                            [self viewControllerWithTabTitle:@"Camera" image:[UIImage imageNamed:@"tab-icon3.png"]],
                            [self viewControllerWithTabTitle:@"Sync" image:[UIImage imageNamed:@"tab-icon4.png"]],
                            [self viewControllerWithTabTitle:@"Settings" image:[UIImage imageNamed:@"tab-icon5.png"]], nil];
    
    if([[UITabBar class] respondsToSelector:@selector(appearance)]){
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar.png"]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar-active.png"]];
        
        [[UITabBarItem appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          UIColorFromRGB(0x645840), UITextAttributeTextColor, 
          [UIColor whiteColor], UITextAttributeTextShadowColor, 
          [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, 
          [UIFont fontWithName:@"HelveticaNeue-Bold" size:0.0] , UITextAttributeFont, 
          nil] 
                                                 forState:UIControlStateNormal];
    }
    
    //register to listen for to show the login screen.    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(eventHandler:)
                                                 name:kNotificationLoginNeeded       
                                               object:nil ];
}

- (void)viewWillAppear:(BOOL)animated{
    if(![[UITabBar class] respondsToSelector:@selector(appearance)]){
        [self addCenterButtonWithImage:[UIImage imageNamed:@"tab-icon-central.png"] highlightImage:nil];
    }else {
        [self addCenterButtonWithImage:[UIImage imageNamed:@"tab-central-empty-button.png"]  highlightImage:[UIImage imageNamed:@"tab-central-selection-button.png"]];
    }
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
        LoginViewController *controller = [[LoginViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"LoginViewController"] bundle:nil ];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        navController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
        navController.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;       
        
        [self presentModalViewController:navController animated:YES];
        [controller release];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
