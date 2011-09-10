//
//  WebService.m
//  OpenPhoto
//
//  Created by Patrick Santana on 03/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "WebService.h"

// Private interface definition
@interface WebService() 
- (void)sendRequest:(NSString*) request;
- (BOOL) validateNetwork;
@end

@implementation WebService
@synthesize delegate;
@synthesize internetActive, hostActive;


- (id)init {
    self = [super init];
    if (self) {
        
        // check for internet connection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [[Reachability reachabilityForInternetConnection] retain];
        [internetReachable startNotifier];
        
        // check if a pathway to a random host exists
        hostReachable = [[Reachability reachabilityWithHostName: @"www.openphoto.me"] retain];
        [hostReachable startNotifier];
        
        self.internetActive = NO;
        self.hostActive = NO;
    }
    return self;
}
- (void) getTags{
    [self sendRequest:@"/tags.json"];
}

- (void) getHomePictures{
    NSMutableString *homePicturesRequest = [NSMutableString stringWithFormat: @"%@",@"/photos.json?sortBy=dateUploaded,DESC&pageSize=4&returnSizes="];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        // retina display
        [homePicturesRequest appendString:@"640x770xCR"];
    }else{
        // not retina display
        [homePicturesRequest appendString:@"320x385xCR"];
    }
    
    [self sendRequest:homePicturesRequest];
}

- (void) loadGallery:(int) pageSize{
    NSMutableString *loadGalleryRequest = [NSMutableString stringWithFormat: @"%@%@%@", 
                                           @"/photos/pageSize-", 
                                           [NSString stringWithFormat:@"%d", pageSize],
                                           @".json?returnSizes=200x200,640x960"];
    [self sendRequest:loadGalleryRequest];
}

-(void) loadGallery:(int) pageSize withTag:(NSString*) tag{
    NSMutableString *loadGalleryRequest = [NSMutableString stringWithFormat: @"%@%@%@%@%@", 
                                           @"/photos/pageSize-", 
                                           [NSString stringWithFormat:@"%d", pageSize],
                                           @".json?returnSizes=200x200,640x960",
                                           @"&tags=",tag];
    [self sendRequest:loadGalleryRequest];
}

-(NSURL*) getOAuthInitialUrl{
    // get the url
    NSString* server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString* url = [[[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/authorize?oauth_callback=openphoto://"] autorelease];
    
    NSLog(@"URL for OAuth initialization = %@",url);
    return [NSURL URLWithString:url];
}

-(NSURL*) getOAuthAccessUrl{
    // get the url
    NSString* server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString* url = [[[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/token/access"] autorelease];
    
    NSLog(@"URL for OAuth Access = %@",url);
    return [NSURL URLWithString:url];  
}

-(NSURL*) getOAuthTestUrl{
    // get the url
    NSString* server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString* url = [[[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/test"] autorelease];
    
    NSLog(@"URL for OAuth Test = %@",url);
    return [NSURL URLWithString:url];  
}

-(void) sendTestRequest{
    [self sendRequest:@"/v1/oauth/test"];
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO; 
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }
    
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)  
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            break;
        }
    }
}


///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
- (void)sendRequest:(NSString*) request{
    if ([self validateNetwork] == NO){
        [self.delegate notifyUserNoInternet];
    }else{
        
        // create the url to connect to OpenPhoto
        NSMutableString *urlString =     [NSMutableString stringWithFormat: @"%@%@", 
                                          [[NSUserDefaults standardUserDefaults] stringForKey:kOpenPhotoServer], request];
        
        NSLog(@"Request to be sent = [%@]",urlString);
        
        // transform in URL for the request
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        // token to send. We get the details from the user defaults
        OAToken *token = [[OAToken alloc] initWithKey:[standardUserDefaults valueForKey:kAuthenticationOAuthToken] 
                                               secret:[standardUserDefaults valueForKey:kAuthenticationOAuthSecret]];
        
        // consumer to send. We get the details from the user defaults
        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[standardUserDefaults valueForKey:kAuthenticationConsumerKey] 
                                                        secret:[standardUserDefaults valueForKey:kAuthenticationConsumerSecret] ];
        
        
        OAMutableURLRequest *oaUrlRequest = [[OAMutableURLRequest alloc] initWithURL:url
                                                                            consumer:consumer
                                                                               token:token
                                                                               realm:nil
                                                                   signatureProvider:nil];
        [oaUrlRequest setHTTPMethod:@"GET"];
        
        // prepare the Authentication Header
        [oaUrlRequest prepare];
        
        // send the request
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:oaUrlRequest
                             delegate:self
                    didFinishSelector:@selector(requestTicket:didFinishWithData:)
                      didFailSelector:@selector(requestTicket:didFailWithError:)];
    }
}

- (void)requestTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data{
    if (ticket.didSucceed) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Succeed = %@",jsonString);        
        
        // Create a dictionary from JSON string
        // When there are newline characters in the JSON string, 
        // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
        jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSDictionary *results =  [jsonString JSONValue];
        
        // send the result to the delegate
        [self.delegate receivedResponse:results];
    }else{
        NSLog(@"The test request didn't succeed");
    }
}
- (void)requestTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
    NSLog(@"Error to send request = %@", [error userInfo]);
}


- (BOOL) validateNetwork{
    // check for the network and if our server is reachable
    if (self.internetActive == NO || self.hostActive == NO){
        return NO;
    }
    
    return YES;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [internetReachable release];
    [hostReachable release];
    [super dealloc];
}

@end
