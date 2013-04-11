//
//  UpdateUtilities.m
//  Trovebox
//
//  Created by Patrick Santana on 31/10/11.
//  Copyright 2013 Trovebox
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

#import "UpdateUtilities.h"

@implementation UpdateUtilities

static UpdateUtilities* instance = nil;

+(UpdateUtilities*) instance{
    if ( instance == nil ) {
		instance = [[UpdateUtilities alloc] init];
	}
	return instance;
}

- (NSString*) getVersion{
    return @"4.0";
}

- (BOOL) needsUpdate{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Version from user: %@",[[NSUserDefaults standardUserDefaults] stringForKey:kVersionApplicationInstalled]);
#endif
    
    // check if the user version saved in the user default
    if ([[NSUserDefaults standardUserDefaults] stringForKey:kVersionApplicationInstalled] == nil
        || ![[[NSUserDefaults standardUserDefaults] stringForKey:kVersionApplicationInstalled] isEqualToString:[self getVersion]]){
        return YES;
    }
    
    // otherwise, it does not need to change
    return NO;
}

- (void) update{
    // save the version in the user default
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:nil forKey:kHomeScreenPicturesTimestamp];
    [standardUserDefaults setValue:nil forKey:kHomeScreenPictures];
    [standardUserDefaults setValue:[self getVersion] forKey:kVersionApplicationInstalled];
    [standardUserDefaults setBool:YES forKey:kSyncShowUploadedPhotos];
    [standardUserDefaults synchronize];
    
    // remove old cache
    [[SDImageCache sharedImageCache] cleanDisk];
    
    // update details from the profile
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProfileRefresh object:nil userInfo:nil];
    
}

//renames the server from OpenPhoto to Trovebox
- (void) fixOpenPhotoToTroveboxServer
{

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // check if the app has been already initialized and has a server.
    // If not, no action is necessary
    if ([standardUserDefaults stringForKey:kTroveboxServer] != nil)
    {
        // check if the server has openphoto.me
        NSString *server = [standardUserDefaults  valueForKey:kTroveboxServer];
        
        if ([server hasSuffix:@"openphoto.me"]){
            NSLog(@"We need to change the url");
            server = [server stringByReplacingOccurrencesOfString:@"openphoto.me"
                                                       withString:@"trovebox.com"];
            
            // save in the user defaults
            [standardUserDefaults setValue:server forKey:kTroveboxServer];
            [standardUserDefaults synchronize];
        }
    }
}

- (void) fixServerLowerCase
{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // check if the app has been already initialized and has a server.
    // If not, no action is necessary
    if ([standardUserDefaults stringForKey:kTroveboxServer] != nil)
    {
        // get the server
        NSString *server = [standardUserDefaults  valueForKey:kTroveboxServer];
        // lower case
        server = [server lowercaseString];
        
        // save in the user defaults
        [standardUserDefaults setValue:server forKey:kTroveboxServer];
        [standardUserDefaults synchronize];
    }
}

@end
