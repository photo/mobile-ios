//
//  UpdateUtilities.m
//  OpenPhoto
//
//  Created by Patrick Santana on 31/10/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

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
    return @"BETA-1.3";
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
    // remove token details
    AuthenticationHelper *authentication = [[AuthenticationHelper alloc]init];
    [authentication invalidateAuthentication];
    [authentication release];
    
    // save the version in the user default
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:[self getVersion] forKey:kVersionApplicationInstalled];
    [standardUserDefaults synchronize];  
}


@end
