//
//  OpenPhotoTTPhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 16/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "OpenPhotoTTPhotoViewController.h"
#import "SHK.h"

@implementation OpenPhotoTTPhotoViewController

- (void)didRefreshModel {
    [super didRefreshModel];
    // add share button
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButton)];          
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];    
}


- (void) shareButton{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"User wants to share this photo");
#endif
    
    // get details from the photo
    id<TTPhotoSource> photoSourceDetails = self.photoSource;    
    Photo *specificPhoto = [photoSourceDetails photoAtIndex:self.centerPhotoIndex];
    
    // create the item to share
    SHKItem *item = [SHKItem URL:[NSURL URLWithString:[specificPhoto pageUrl]] title:specificPhoto.caption];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self];
    
    // Display the action sheet
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Details - Share More"];
#endif  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Details Loaded"];
#endif      
}
@end
