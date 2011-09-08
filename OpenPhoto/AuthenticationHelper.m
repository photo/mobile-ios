//
//  AuthenticationHelper.m
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "AuthenticationHelper.h"

@implementation AuthenticationHelper


- (BOOL) isValid{
    /*
     * check if the client id is valid. 
     * Possible values: nil, INVALID or other
     *
     * If it is nil or text INVALID, return that is INVALID = NO
     */
    if (![[NSUserDefaults standardUserDefaults] stringForKey:kAuthenticationValid] || 
        [[[NSUserDefaults standardUserDefaults] stringForKey:kAuthenticationValid] isEqualToString:@"INVALID"]){
        return NO;
    }
    
    // otherwise return that it is valid
    return YES;
}

- (void) invalidateAuthentication{
    // set the variable client id to INVALID
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [standardUserDefaults setValue:@"INVALID" forKey:kAuthenticationValid];
    [standardUserDefaults setNilValueForKey:kAuthenticationOAuthToken];
    [standardUserDefaults setNilValueForKey:kAuthenticationOAuthSecret];
    [standardUserDefaults setNilValueForKey:kAuthenticationConsumerKey];
    [standardUserDefaults setNilValueForKey:kAuthenticationConsumerSecret];
     
     // synchronize the keys
     [standardUserDefaults synchronize];
     }
     @end
