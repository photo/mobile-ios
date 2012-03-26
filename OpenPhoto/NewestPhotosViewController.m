//
//  NewestPhotosViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 25/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "NewestPhotosViewController.h"

@interface NewestPhotosViewController ()

@end

@implementation NewestPhotosViewController
@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // transparent background
        self.table.backgroundColor = [UIColor clearColor];
        self.table.opaque = NO;
        self.table.backgroundView = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [table release];
    [super dealloc];
}
@end
