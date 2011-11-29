//
//  InitializerHelper.m
//  OpenPhoto
//
//  Created by Patrick Santana on 04/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "InitializerHelper.h"

@implementation InitializerHelper

- (BOOL) isInitialized
{
    // compare not just nil. It may be reset. So, we need to check for NO
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAppInitialized] || 
        [[NSUserDefaults standardUserDefaults] boolForKey:kAppInitialized] == NO){
        NSLog(@"Property not defined");
        return NO;
    }
    
    return YES;
}

- (void) initialize
{                
    NSLog(@"Initialization starting ....");
    
    // get the user defaults
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    /*
     * set the initial configuration for the user properties
     */
    if (standardUserDefaults) {
        // Save original to Library
        [standardUserDefaults setBool:YES forKey:kPhotosSaveCameraRollOrSnapshot];
        // Save filtered to Library
        [standardUserDefaults setBool:YES forKey:kPhotosSaveFiltered];
        // High resolution
        [standardUserDefaults setBool:YES forKey:kPhotosHighResolution];
        // Privacy
        [standardUserDefaults setBool:NO forKey:kPhotosArePrivate];
        
        
        // set that the initialization is okay.
        [standardUserDefaults setBool:YES forKey:kAppInitialized];
        
        // for authentication
        [standardUserDefaults setValue:@"INVALID" forKey:kAuthenticationValid];
        
        // clean images saved localy
        [standardUserDefaults setValue:nil forKey:kHomeScreenPicturesTimestamp];
        [standardUserDefaults setValue:nil forKey:kHomeScreenPictures];
        
        // synchronize the keys
        [standardUserDefaults synchronize];
    }
    
    // set the variable to initialized
    NSLog(@"Initialization finished ....");
}

- (void) resetInitialization
{
    // set the variable initialized to NO
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:NO forKey:kAppInitialized];
   
    // clean images saved localy
    [standardUserDefaults setValue:nil forKey:kHomeScreenPicturesTimestamp];
    [standardUserDefaults setValue:nil forKey:kHomeScreenPictures];
    
    // synchronize the keys
    [standardUserDefaults synchronize];
}
@end
