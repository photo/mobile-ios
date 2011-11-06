//
//  UpdateUtilities.m
//  OpenPhoto
//
//  Created by Patrick Santana on 31/10/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

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
