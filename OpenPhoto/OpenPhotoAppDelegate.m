//
//  OpenPhotoAppDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoAppDelegate.h"

#import "OpenPhotoViewController.h"

@implementation OpenPhotoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Allow HTTP response size to be unlimited.
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    // Configure the in-memory image cache to keep approximately
    // 10 images in memory, assuming that each picture's dimensions
    // are 320x480. Note that your images can have whatever dimensions
    // you want, I am just setting this to a reasonable value
    // since the default is unlimited.
    [[TTURLCache sharedCache] setMaxPixelCount:10*640*960];
    
    
    InitializerHelper *helper = [[InitializerHelper alloc]init];
    if ([helper isInitialized] == NO){
        [helper initialize];
    }
    [helper release];
    
    // check if user is authenticated or not
    AuthenticationHelper *auth = [[AuthenticationHelper alloc]init];
    if ([auth isValid]== NO){
        // open the authentication screen
        AuthenticationViewController *controller = [[AuthenticationViewController alloc]init];
        self.window.rootViewController = controller;
        [controller release];
    }else{
        // open the default view controller
        self.window.rootViewController = self.viewController;
    }
    [auth release];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    NSLog(@"Value url = %@",url);
    NSString *oauthToken;
    NSString *oauthVerifier;
    
    // get the token and the verifier
    NSArray *comp1 = [[url absoluteString] componentsSeparatedByString:@"?"];
    NSString *query = [comp1 lastObject];
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        NSString *variableKey = [keyVal objectAtIndex:0];
        NSString *value = [keyVal lastObject];
        
        if ([variableKey isEqualToString:@"oauth_token"]){
            oauthToken = value;
        }
        
        if ([variableKey isEqualToString:@"oauth_verifier"]){
            oauthVerifier = value;
        }
    }
    
    
    // get oauth_token
    NSLog(@"oauth_token = %@",oauthToken);
    // get oauth_verifier
    NSLog(@"oauth_verifier = %@",oauthVerifier);    
    
    // use library to get the authentication
    NSURL *url2 = [NSURL URLWithString:@"http://jmathai.openphoto.me/v1/oauth/token/access"];
    
    
    OAToken *token = [[OAToken alloc] initWithKey:@"oauth_token" secret:oauthToken];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url2
                                                                   consumer:nil
                                                                      token:token
                                                                      realm:nil
                                                          signatureProvider:nil];
    //    [token release];
    [request setHTTPMethod:@"POST"];
    
    
    OARequestParameter *oa_token = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken];
    OARequestParameter *verifier = [[OARequestParameter alloc] initWithName:@"oauth_verifier"
                                                                      value:oauthVerifier];
    NSArray *params = [NSArray arrayWithObjects:oa_token, verifier, nil];
    [request setParameters:params];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    
    return YES;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        NSLog(@"Result final = %@",responseBody);
        
        
        NSString *oauthToken;
        NSString *oauthTokenSecret;
        NSString *consumerKey;
        NSString *consumerSecret;
        
        // get the token and the verifier
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
        
        
        // use library to get the authentication
        NSURL *url2 = [NSURL URLWithString:@"http://jmathai.openphoto.me/v1/oauth/test"];
        
        
        OAToken *token = [[OAToken alloc] initWithKey:oauthToken secret:oauthTokenSecret];
        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret];
        
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url2
                                                                       consumer:consumer
                                                                          token:token
                                                                          realm:nil
                                                              signatureProvider:nil];
        [request setHTTPMethod:@"GET"];
        [request prepare];
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:request
                             delegate:self
                    didFinishSelector:@selector(requestTokenTicket2:didFinishWithData:)
                      didFailSelector:@selector(requestTokenTicket2:didFailWithError:)];
    }else{
        NSLog(@"Error");
    }
}

- (void)requestTokenTicket2:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        NSLog(@"Result test = %@",responseBody);
    }else{
        NSLog(@"Description %@",ticket.description);
        NSLog(@"Request %@",ticket.request);
        NSLog(@"Debug %@",ticket.debugDescription);
        NSLog(@"Error in the ticket = %@", [[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding]);  
    }
}

- (void)requestTokenTicket2:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"Error =   %@", [error userInfo]);
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
