//
//  AuthenticationHelper.m
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "AuthenticationHelper.h"

@implementation AuthenticationHelper

@synthesize webService;

- (id)init {
    self = [super init];
    if (self) {
        self.webService = [[WebService alloc]init];
    }
    return self;
}


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
    [standardUserDefaults setValue:@"" forKey:kAuthenticationOAuthToken];
    [standardUserDefaults setValue:@"" forKey:kAuthenticationOAuthSecret];
    [standardUserDefaults setValue:@"" forKey:kAuthenticationConsumerKey];
    [standardUserDefaults setValue:@"" forKey:kAuthenticationConsumerSecret];
    
    // synchronize the keys
    [standardUserDefaults synchronize];
    
    // send notification to the system that it can shows the screen:
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginNeeded object:nil];
}

- (void) startOAuthProcedure:(NSURL*) url{
    
    /*
     * This is the step where the User allowed the iOS App to use the OpenPhoto service in his behalf.
     * The URL will be like that: openphoto://?&oauth_token=d3973e7b5ce6974c3e5eca6c78fc26&oauth_verifier=748e62b11f
     * the openphoto is the callback that makes iOS to open our app
     */
    
    // get the token and the verifier from the URL
    NSString *oauthToken;
    NSString *oauthVerifier;
    
    // we just care after ?
    NSArray *comp1 = [[url absoluteString] componentsSeparatedByString:@"?"];
    NSString *query = [comp1 lastObject];
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        NSString *variableKey = [keyVal objectAtIndex:0];
        NSString *value = [keyVal lastObject];
        
        if ([variableKey isEqualToString:@"oauth_token"]){
            // get token
            oauthToken = value;
        }
        
        if ([variableKey isEqualToString:@"oauth_verifier"]){
            // get verifier
            oauthVerifier = value;
        }
    }
    
    /*
     * With the token and verifier, we can request the ACCESS 
     */
    NSURL* accessUrl = [webService getOAuthAccessUrl];
    OAToken *token = [[OAToken alloc] initWithKey:@"oauth_token" secret:oauthToken];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:accessUrl
                                                                   consumer:nil
                                                                      token:token
                                                                      realm:nil
                                                          signatureProvider:nil];
    // the request must be POST
    [request setHTTPMethod:@"POST"];
    
    // set parameters    
    OARequestParameter *parameterToken = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
    OARequestParameter *parameterVerifier = [[OARequestParameter alloc] initWithName:@"oauth_verifier"
                                                                               value:oauthVerifier];
    NSArray *params = [NSArray arrayWithObjects: parameterToken, parameterVerifier, nil];
    [request setParameters:params];
    
    // create data fetcher and send the request    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenAccess:didFinishWithData:)
                  didFailSelector:@selector(requestToken:didFailWithError:)];
}


- (void)requestTokenAccess:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        /*
         * Now we have token and consumer information. With these data we can request a test request
         */
        NSString *oauthToken;
        NSString *oauthTokenSecret;
        NSString *consumerKey;
        NSString *consumerSecret;
        
        // parse the data
        NSArray *queryElements = [responseBody componentsSeparatedByString:@"&"];
        for (NSString *element in queryElements) {
            NSArray *keyVal = [element componentsSeparatedByString:@"="];
            NSString *variableKey = [keyVal objectAtIndex:0];
            NSString *value = [keyVal lastObject];
            
            if ([variableKey isEqualToString:@"oauth_token"]){
                oauthToken = value;
            }
            if ([variableKey isEqualToString:@"oauth_token_secret"]){
                oauthTokenSecret = value;
            }
            if ([variableKey isEqualToString:@"oauth_consumer_key"]){
                consumerKey = value;
            }
            if ([variableKey isEqualToString:@"oauth_consumer_secret"]){
                consumerSecret = value;
            }
        }
        
        
        // save data to the user information
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        [standardUserDefaults setValue:@"OK" forKey:kAuthenticationValid];
        [standardUserDefaults setValue:oauthToken forKey:kAuthenticationOAuthToken];
        [standardUserDefaults setValue:oauthTokenSecret forKey:kAuthenticationOAuthSecret];
        [standardUserDefaults setValue:consumerKey forKey:kAuthenticationConsumerKey];
        [standardUserDefaults setValue:consumerSecret forKey:kAuthenticationConsumerSecret];
        
        // synchronize the keys
        [standardUserDefaults synchronize];  
        
        // send notification to the system that it can shows the screen:
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginAuthorize object:nil ];
        
        NSLog(@"OAuth procedure finished");
    }
}

- (void)requestToken:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"Error = %@", [error userInfo]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication failed" message:@"Please, try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void) dealloc {
    [webService release];
    [super dealloc];
}
@end
