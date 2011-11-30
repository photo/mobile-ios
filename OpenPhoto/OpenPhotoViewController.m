//
//  OpenPhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoViewController.h"

// Private interface definition
@interface OpenPhotoViewController() 
- (void) eventHandler: (NSNotification *) notification;
@end

@implementation OpenPhotoViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.viewControllers = [NSArray arrayWithObjects:
                            [self viewControllerWithTabTitle:@"Home" image:[UIImage imageNamed:@"tab-home.png"]],
                            [self viewControllerWithTabTitle:@"Gallery" image:[UIImage imageNamed:@"tab-gallery.png"]],
                            [self viewControllerWithTabTitle:@"Photo" image:nil],
                            [self viewControllerWithTabTitle:@"Tags" image:[UIImage imageNamed:@"tab-tags.png"]],
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        
#ifdef TEST_FLIGHT_ENABLED
        [TestFlight passCheckpoint:@"Event for Notification Login Needed"];
#endif
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
