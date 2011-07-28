//
//  OpenPhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoViewController.h"

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
                            [self viewControllerWithTabTitle:@"Photo" image:[UIImage imageNamed:@"tab-picture.png"]],
                            [self viewControllerWithTabTitle:@"Tags" image:[UIImage imageNamed:@"tab-tags.png"]],
                            [self viewControllerWithTabTitle:@"Settings" image:[UIImage imageNamed:@"tab-settings.png"]], nil];
    

}


- (void)viewWillAppear:(BOOL)animated{
   // [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"] highlightImage:nil];
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

@end
