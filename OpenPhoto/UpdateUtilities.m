//
//  UpdateUtilities.m
//  OpenPhoto
//
//  Created by Patrick Santana on 31/10/11.
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

#import "UpdateUtilities.h"

@implementation UpdateUtilities
@synthesize service=_service;

static UpdateUtilities* instance = nil;

+(UpdateUtilities*) instance{
    if ( instance == nil ) {
		instance = [[UpdateUtilities alloc] init];	
	}
	return instance;	    
}

- (id)init {
    self = [super init];
    if (self) {
        // create service and the delegate
        WebService *web = [[WebService alloc]init];
        self.service = web;
        [self.service setDelegate:self];
        [web release];
    }
    return self;
}

- (NSString*) getVersion{
    return @"3.0";
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
    
    //clean up database
    [AppDelegate cleanDatabase]; 
    
    NSError *saveError = nil;
    if (![[AppDelegate managedObjectContext] save:&saveError]){
        NSLog(@"Error deleting objects from core data = %@",[saveError localizedDescription]);
    }
}

- (void) dealloc {
    [_service release];
    [super dealloc];
}


@end
