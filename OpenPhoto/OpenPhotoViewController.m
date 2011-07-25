//
//  OpenPhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 25/07/11.
//  Copyright 2011 Moogu bvba. All rights reserved.
//

#import "OpenPhotoViewController.h"

@implementation OpenPhotoViewController

@synthesize imageMenu;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [imageMenu release];
    imageMenu = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)openTags:(id)sender {
    NSLog(@"Open tags");
    UIImage *image = [UIImage imageNamed: @"Active1.png"];
    imageMenu.image = image;
}

- (IBAction)openUpload:(id)sender {
    NSLog(@"Open upload");
    UIImage *image = [UIImage imageNamed: @"Active3.png"];
    imageMenu.image = image;}

- (IBAction)openGallery:(id)sender {
    NSLog(@"Open gallery");
    UIImage *image = [UIImage imageNamed: @"Active4.png"];
    imageMenu.image = image;
}

- (IBAction)openSettings:(id)sender {
    NSLog(@"Open settings");
    UIImage *image = [UIImage imageNamed: @"Active5.png"];
    imageMenu.image = image;
}

- (void)dealloc {
    [imageMenu release];
    [super dealloc];
}
@end
