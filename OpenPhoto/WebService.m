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
- (void)sendRequest:(NSString*) request httpMethodGet:(BOOL) get;
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
        hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
        [hostReachable startNotifier];
        
        self.internetActive = NO;
        self.hostActive = NO;
    }
    return self;
}
- (void) getTags{
    [self sendRequest:@"/tags/list.json" httpMethodGet:YES];
}

- (void) getHomePictures{
    NSMutableString *homePicturesRequest = [NSMutableString stringWithFormat: @"%@",@"/photos/list.json?sortBy=dateUploaded,DESC&pageSize=4&returnSizes="];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        // retina display
        [homePicturesRequest appendString:@"640x770xCR"];
    }else{
        // not retina display
        [homePicturesRequest appendString:@"320x385xCR"];
    }
    
    [self sendRequest:homePicturesRequest httpMethodGet:YES];
}

- (void) loadGallery:(int) pageSize onPage:(int) page {
    NSMutableString *loadGalleryRequest = [NSMutableString stringWithFormat: @"%@%@%@%@%@", 
                                           @"/photos/list.json?pageSize=", 
                                           [NSString stringWithFormat:@"%d", pageSize],
                                           @"&page=",[NSString stringWithFormat:@"%d", page], 
                                           @"&returnSizes=200x200,640x960"];
    [self sendRequest:loadGalleryRequest httpMethodGet:YES];
}

-(void) loadGallery:(int) pageSize withTag:(NSString*) tag onPage:(int) page {
    NSMutableString *loadGalleryRequest = [NSMutableString stringWithFormat: @"%@%@%@%@%@%@%@", 
                                           @"/photos/list.json?pageSize=", 
                                           [NSString stringWithFormat:@"%d", pageSize],
                                           @"&page=",[NSString stringWithFormat:@"%d", page],
                                           @"&returnSizes=200x200,640x960",
                                           @"&tags=",tag];
    [self sendRequest:loadGalleryRequest httpMethodGet:YES];
}

-(void) getSystemVersion{
    [self sendRequest:@"/system/version.json" httpMethodGet:NO];
}

-(NSURL*) getOAuthInitialUrl{
    // get the url
    NSString* server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString* url = [[[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/authorize?oauth_callback=openphoto://&mobile=1&name=OpenPhoto%20IPhone%20App"] autorelease];
    
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
    [self sendRequest:@"/hello.json?auth=1" httpMethodGet:YES];
}


- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            self.internetActive = NO; 
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            break;
        }
    }
    
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)  
    {
        case NotReachable:
        {
            self.hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.hostActive = YES;
            break;
        }
    }
}

+ (BOOL) isMessageValid:(NSDictionary *)response{
    // get the content of code
    NSString* code = [response objectForKey:@"code"];
    NSInteger icode = [code integerValue];
    
    // is it different than 200
    if (icode != 200 && icode != 202)
        return NO;
    
    // another kind of message
    return YES;
}

+ (NSString*) getResponseMessage:(NSDictionary *)response{
    // get content of message in the response
    return [response objectForKey:@"message"];
}


///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
- (void)sendRequest:(NSString*) request httpMethodGet:(BOOL) get{
    if ([self validateNetwork] == NO){
        [self.delegate notifyUserNoInternet];
    }else{
        
        // don't send the request if the server is not defined
        if ([[NSUserDefaults standardUserDefaults] stringForKey:kOpenPhotoServer] == nil){
            NSLog(@"Url is not defined, request can not be sent");
            // set the variable client id to INVALID
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setValue:@"INVALID" forKey:kAuthenticationValid];
            [standardUserDefaults synchronize];
            return;
        }
        
        // create the url to connect to OpenPhoto
        NSMutableString *urlString =     [NSMutableString stringWithFormat: @"%@%@", 
                                          [[NSUserDefaults standardUserDefaults] stringForKey:kOpenPhotoServer], request];
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Request to be sent = [%@]",urlString);
#endif
        
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
        
        if (get == YES)
            [oaUrlRequest setHTTPMethod:@"GET"];
        else
            [oaUrlRequest setHTTPMethod:@"POST"];
        
        
        // prepare the Authentication Header
        [oaUrlRequest prepare];
        
        // send the request
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:oaUrlRequest
                             delegate:self
                    didFinishSelector:@selector(requestTicket:didFinishWithData:)
                      didFailSelector:@selector(requestTicket:didFailWithError:)];
        
        [token release];
        [consumer release];
        [oaUrlRequest release];
        [fetcher release];
    }
}

- (void)requestTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data{
    if (ticket.didSucceed) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#ifdef DEVELOPMENT_ENABLED        
        NSLog(@"Succeed = %@",jsonString);       
#endif        
        
        // Create a dictionary from JSON string
        // When there are newline characters in the JSON string, 
        // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
        jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSDictionary *results =  [jsonString JSONValue];
        
        // send the result to the delegate
        [self.delegate receivedResponse:results];
        [jsonString release];
    }else{
        NSLog(@"The request didn't succeed=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
}
- (void)requestTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
    NSLog(@"Error to send request = %@", error);
}


- (BOOL) validateNetwork{
    // check for the network and if our server is reachable
    if (self.internetActive == NO ){
        // re-check network
        [self checkNetworkStatus:nil];
        if (self.internetActive == NO){
            NSLog(@"Values for internetActive = %@ and hostActive = %@",(self.internetActive ? @"YES" : @"NO") , (self.hostActive ? @"YES" : @"NO"));
            return NO;
        }
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
