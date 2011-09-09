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
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)sendRequest:(NSString*) request;
@end

@implementation WebService
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
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

-(void) sendTestRequest:(BOOL) alert{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    
    // token to send. We get the details from the user defaults
    OAToken *token = [[OAToken alloc] initWithKey:[standardUserDefaults valueForKey:kAuthenticationOAuthToken] 
                                           secret:[standardUserDefaults valueForKey:kAuthenticationOAuthSecret]];
    
    // consumer to send. We get the details from the user defaults
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[standardUserDefaults valueForKey:kAuthenticationConsumerKey] 
                                                    secret:[standardUserDefaults valueForKey:kAuthenticationConsumerSecret] ];
    
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[self getOAuthTestUrl]
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"GET"];
    
    // prepare the Authentication Header
    [request prepare];
    
    // send the request
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTest:didFinishWithData:withAlert:)
                  didFailSelector:@selector(requestToken:didFailWithError:withAlert:)];
}

- (void)requestTest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data withAlert:(BOOL) alert{
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"succeed = %@",responseBody);
        if (alert == YES){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Test authentication succed" message:responseBody delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }else{
        NSLog(@"The test request didn't succeed");
        if (alert == YES){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Test authentication error" message:@"Please, try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }
}
- (void)requestToken:(OAServiceTicket *)ticket didFailWithError:(NSError *)error withAlert:(BOOL) alert{
    NSLog(@"Error = %@", [error userInfo]);
    if (alert == YES){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Test authentication error " message:[[error userInfo] description ] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}


///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];    
    // convert the responseDate to the json string
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // it can be released
    [responseData release];
    
    // Create a dictionary from JSON string
    // When there are newline characters in the JSON string, 
    // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
    jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSDictionary *results =  [jsonString JSONValue];
    
    // send the result to the delegate
    [self.delegate receivedResponse:results];
}

- (void)sendRequest:(NSString*) request{
    // create the url to connect to OpenPhoto
    NSMutableString *urlString =     [NSMutableString stringWithFormat: @"%@%@", 
                                      [[NSUserDefaults standardUserDefaults] stringForKey:kOpenPhotoServer], request];
    
    NSLog(@"Request to be sent = [%@]",urlString);
    
    // transform in URL for the request
    NSURL *url = [NSURL URLWithString:urlString];
    responseData = [[NSMutableData data] retain];
    
    // send the message
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL: url];
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

@end
