//
//  UpdateUtilities.m
//  Trovebox
//
//  Created by Patrick Santana on 25/02/13.
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
//


#import "UpdateUtilities.h"

@implementation UpdateUtilities

/*
 * OAuth 1.0a
 * ===================================
 * There are 4 values for you to store: two tokens and two secrets
 * one for the "app" and another for the "user"
 * the two secrets are used to generate the signature but are not passed with the request
 * the two tokens are passed with the request
 */
NSString * const kAuthenticationOAuthToken=@"authentication_oauth_token";
NSString * const kAuthenticationOAuthSecret=@"authentication_oauth_secret";
NSString * const kAuthenticationConsumerKey=@"authentication_consumer_key";
NSString * const kAuthenticationConsumerSecret=@"authentication_consumer_secret";


static UpdateUtilities* instance = nil;

+(UpdateUtilities*) instance{
    if ( instance == nil ) {
		instance = [[UpdateUtilities alloc] init];
	}
	return instance;
}

- (NSString*) getVersion{
    return @"4.1.3";
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
    if ([standardUserDefaults stringForKey:kAutoSyncEnabled] == nil){
        [standardUserDefaults setBool:NO forKey:kAutoSyncEnabled];
        [standardUserDefaults setBool:NO forKey:kAutoSyncMessageDisplayed];
    }
    [standardUserDefaults synchronize];
    
    // delete timeline
    [Timeline deleteAllTimelineInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
    
    // remove old cache
    [[SDImageCache sharedImageCache] cleanDisk];
    
    [self fixOpenPhotoToTroveboxServer];
    [self fixServerLowerCase];
    [self fixKeyChain];
    
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
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"We need to change the url");
#endif
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

- (void) fixKeyChain
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults stringForKey:kAuthenticationOAuthToken] != nil)
    {
        // copy the value to Keychain and delete
        KeychainItemWrapper *keychainItemOAuth = [[KeychainItemWrapper alloc]initWithTroveboxOAuth];
        KeychainItemWrapper *keychainItemConsumer = [[KeychainItemWrapper alloc]initWithTroveboxConsumer];
        
        [keychainItemOAuth setObject:[standardUserDefaults valueForKey:kAuthenticationOAuthToken] forKey:(__bridge id)(kSecAttrAccount)];
        [keychainItemOAuth setObject:[standardUserDefaults valueForKey:kAuthenticationOAuthSecret] forKey:(__bridge id)(kSecValueData)];
        [keychainItemConsumer setObject:[standardUserDefaults valueForKey:kAuthenticationConsumerKey]  forKey:(__bridge id)(kSecAttrAccount)];
        [keychainItemConsumer setObject:[standardUserDefaults valueForKey:kAuthenticationConsumerSecret]  forKey:(__bridge id)(kSecValueData)];
        
        // now, delete from NSUserDefaults
        [standardUserDefaults removeObjectForKey:kAuthenticationOAuthToken];
        [standardUserDefaults removeObjectForKey:kAuthenticationOAuthSecret];
        [standardUserDefaults removeObjectForKey:kAuthenticationConsumerKey];
        [standardUserDefaults removeObjectForKey:kAuthenticationConsumerSecret];
        
        // synchronize the keys
        [standardUserDefaults synchronize];
    }
}

@end
