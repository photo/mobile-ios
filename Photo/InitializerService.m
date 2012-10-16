//
//  InitializerService.m
//  Photo
//
//  Created by Patrick Santana on 04/09/11.
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

#import "InitializerService.h"

@implementation InitializerService

- (BOOL) isInitialized
{
    // compare not just nil. It may be reset. So, we need to check for NO
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAppInitialized] || 
        [[NSUserDefaults standardUserDefaults] boolForKey:kAppInitialized] == NO){
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Property not defined");
#endif
        
        return NO;
    }
    
    return YES;
}

- (void) initialize
{  
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Initialization starting ....");
#endif
    
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
        
        // Privacy
        [standardUserDefaults setBool:NO forKey:kPhotosArePrivate];
        
        
        // set that the initialization is okay.
        [standardUserDefaults setBool:YES forKey:kAppInitialized];
        
        // for authentication
        [standardUserDefaults setValue:@"INVALID" forKey:kAuthenticationValid];
        
        // clean images saved localy
        [standardUserDefaults setValue:nil forKey:kHomeScreenPicturesTimestamp];
        [standardUserDefaults setValue:nil forKey:kHomeScreenPictures];
        
        // shoz photos uploades
        [standardUserDefaults setBool:YES forKey:kSyncShowUploadedPhotos];
        
        // synchronize the keys
        [standardUserDefaults synchronize];
    }
    
    // set the variable to initialized
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Initialization finished ....");
#endif
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
