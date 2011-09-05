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
    NSMutableString *homePicturesRequest = [NSMutableString stringWithFormat: @"%@",@"/photos.json?sortBy=dateUploaded,ASC&pageSize=3&returnSizes="];
    
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
