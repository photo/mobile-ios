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
@synthesize service;

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
        self.service = [[WebService alloc]init];
        [service setDelegate:self];
    }
    return self;
}

- (NSString*) getVersion{
    return @"1.4";
}

- (BOOL) needsUpdate{
    NSLog(@"Version from user: %@",[[NSUserDefaults standardUserDefaults] stringForKey:kVersionApplicationInstalled]);
    
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
    [standardUserDefaults synchronize];   
}

-(void) updateSystemVersion{
    // get system version
    [self.service getSystemVersion];    
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    // save it
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:[response objectForKey:@"result"] forKey:kServerDetails];
    [standardUserDefaults synchronize];  
}


- (void) dealloc {
    [service release];
    [super dealloc];
}


@end
