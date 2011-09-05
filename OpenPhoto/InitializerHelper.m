//
//  InitializerHelper.m
//  OpenPhoto
//
//  Created by Patrick Santana on 04/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "InitializerHelper.h"

@implementation InitializerHelper


// Const for the server. In the future it will be inside the Settings
NSString * const kAppInitialized = @"app_initialized";

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
        [standardUserDefaults setBool:YES forKey:@"photos_save_camera_roll_or_snapshot"];
        // Save filtered to Library
        [standardUserDefaults setBool:YES forKey:@"photos_save_filtered"];
        // High resolution
        [standardUserDefaults setBool:YES forKey:@"photos_high_resolution"];
        // Privacy
        [standardUserDefaults setBool:YES forKey:@"photos_are_private"];
        
        
        // set that the initialization is okay.
        [standardUserDefaults setBool:YES forKey:kAppInitialized];
        
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
    
    // synchronize the keys
    [standardUserDefaults synchronize];
}
@end
