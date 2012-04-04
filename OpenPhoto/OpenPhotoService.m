//
//  OpenPhotoService.m
//  iPhone and iPad Example
//
//  Created by Patrick Santana on 20/03/12.
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

#import "OpenPhotoService.h"
@interface OpenPhotoService()

- (NSArray *) sendSynchronousRequest:(NSString *) request;
- (void) validateCredentials;
- (OAMutableURLRequest*) getUrlRequest:(NSURL *) url;

@property (nonatomic, retain, readwrite) NSString *server;
@property (nonatomic, retain, readwrite) NSString *oAuthKey;
@property (nonatomic, retain, readwrite) NSString *oAuthSecret;
@property (nonatomic, retain, readwrite) NSString *consumerKey;
@property (nonatomic, retain, readwrite) NSString *consumerSecret;

@end

@implementation OpenPhotoService

@synthesize server=_server, oAuthKey=_oAuthKey, oAuthSecret=_oAuthSecret, consumerKey = _consumerKey, consumerSecret=_consumerSecret;

-(id)initForServer:(NSString *) server 
          oAuthKey:(NSString *) oAuthKey 
       oAuthSecret:(NSString *) oAuthSecret 
       consumerKey:(NSString *) consumerKey 
    consumerSecret:(NSString *) consumerSecret{
    
	self = [super init];
    
	if (self) {
        // set the objects
        self.server = server;
        self.oAuthKey = oAuthKey;
        self.oAuthSecret = oAuthSecret;
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
	}
    
	return self;
}

- (NSArray*) fetchNewestPhotosMaxResult:(int) maxResult{
    NSMutableString *request = [NSMutableString stringWithFormat: @"%@%i%@",@"/v1/photos/list.json?sortBy=dateUploaded,DESC&pageSize=", maxResult, @"&returnSizes="];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        // retina display
        [request appendString:@"610x530xCR"];
    }else{
        // not retina display
        [request appendString:@"305x265xCR"];
    }
    
    return [self sendSynchronousRequest:request]; 
}



- (NSArray *) sendSynchronousRequest:(NSString *) request{
    [self validateCredentials];
    
    // create the url to connect to OpenPhoto
    NSString *urlString =     [NSString stringWithFormat: @"%@%@", self.server, request];
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Request to be sent = [%@]",urlString);
#endif
    
    // transform in URL for the request
    NSURL *url = [NSURL URLWithString:urlString];
    
    OAMutableURLRequest *oaUrlRequest = [self getUrlRequest:url];
    [oaUrlRequest setHTTPMethod:@"GET"];
    
    // prepare the Authentication Header
    [oaUrlRequest prepare];
    
    
    ASIHTTPRequest *asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    // set the authorization header to be used in the OAuth            
    NSDictionary *dictionary =  [oaUrlRequest allHTTPHeaderFields];
    [asiHttpRequest addRequestHeader:@"Authorization" value:[dictionary objectForKey:@"Authorization"]];
    
    // send the request synchronous
    [asiHttpRequest startSynchronous];
    
    // check the valid result
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Response = %@",[asiHttpRequest responseString]);
#endif
    NSDictionary *response =  [[asiHttpRequest responseString] JSONValue];    
    
    if (![OpenPhotoService isMessageValid:response]){
        // invalid message
        NSException *exception = [NSException exceptionWithName: @"Incorrect request"
                                                         reason: [NSString stringWithFormat:@"Error: %@ - %@",[response objectForKey:@"code"],[response objectForKey:@"message"]]
                                                       userInfo: nil];
        @throw exception;
    }             
    
    NSArray *result = [response objectForKey:@"result"] ;
    
    // check if user has photos
    if ([result class] == [NSNull class]){
        // if it is null, return an empty array
        return [NSArray array];
    }else {
        return result;
    }
}

- (NSDictionary*) uploadPicture:(NSData*) data metadata:(NSDictionary*) values fileName:(NSString *)fileName
{
    [self validateCredentials];
    
    
    
    // set all details to send
    NSString *uploadCall = [NSString stringWithFormat:@"title=%@&permission=%@&tags=%@",[values objectForKey:@"title"],[values objectForKey:@"permission"], [values objectForKey:@"tags"]];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat: @"%@/v1/photo/upload.json", self.server];
    NSURL *url = [NSURL URLWithString:urlString];
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Url upload = [%@]. Execute OAuth and Multipart",urlString);
    NSLog(@"Title = %@",[values objectForKey:@"title"]);
    NSLog(@"Permission = %@",[values objectForKey:@"permission"]);
    NSLog(@"Tags = %@",[values objectForKey:@"tags"]);
#endif
    
    OAMutableURLRequest *oaUrlRequest = [self getUrlRequest:url];                                                              
    [oaUrlRequest setHTTPMethod:@"POST"]; 
    [oaUrlRequest setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
    [oaUrlRequest setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    @try {
        // prepare the request. This will be used to get the Authorization header and add in the multipart component        
        [oaUrlRequest prepare];
    }
    @catch (NSException *exception) {
        NSException *newException = [NSException exceptionWithName: @"Incorrect Parameters"
                                                            reason: @"Couldn't upload your photo. Please, change photo's title."
                                                          userInfo: nil];
        @throw newException;
    }
    
    /*
     *
     *   Using ASIHTTPRequest for Multipart. The authentication come from the OAMutableURLRequest
     *
     */
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:url];
    
    // set the authorization header to be used in the OAuth            
    NSDictionary *dictionary =  [oaUrlRequest allHTTPHeaderFields];
    [asiRequest addRequestHeader:@"Authorization" value:[dictionary objectForKey:@"Authorization"]];
    
    // set the parameter already added in the signature
    [asiRequest addPostValue:[values objectForKey:@"title"] forKey:@"title"];
    [asiRequest addPostValue:[values objectForKey:@"permission"] forKey:@"permission"];
    [asiRequest addPostValue:[values objectForKey:@"tags"] forKey:@"tags"];
    
    // add the file in the multipart. This file is stored locally for perfomance reason. We don't have to load it
    // in memory. If it is a picture with filter, we just send without giving the name 
    // and content type
    [asiRequest addData:data  withFileName:fileName andContentType:[ContentTypeUtilities contentTypeForImageData:data] forKey:@"photo"];
    [asiRequest startSynchronous];
    
    // check the valid result
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Response = %@",[asiRequest responseString]);
#endif 
    
    NSDictionary *response =  [[asiRequest responseString] JSONValue]; 
    
    if (![OpenPhotoService isMessageValid:response]){
        // invalid message
        NSException *exception = [NSException exceptionWithName: @"Incorrect request"
                                                         reason: [NSString stringWithFormat:@"Error: %@ - %@",[response objectForKey:@"code"],[response objectForKey:@"message"]]
                                                       userInfo: nil];
        @throw exception;
    }  
    
    return response;
}

// get all tags. It brings how many images have this tag.
- (NSArray*)  getTags
{
    return [self sendSynchronousRequest:@"/v1/tags/list.json"]; 
}

// get details from the system
- (NSArray*)  getSystemVersion
{
    return [self sendSynchronousRequest:@"/v1/system/version.json"];    
}



- (void) validateCredentials{    
    // validate if the service has all details for the account
    if (self.oAuthKey == nil ||
        self.oAuthSecret == nil ||
        self.consumerKey == nil ||
        self.consumerSecret == nil){
        NSException *exception = [NSException exceptionWithName: @"unathorized access"
                                                         reason: @"Credentials is not configured correct"
                                                       userInfo: nil];
        @throw exception; 
    }
}

- (OAMutableURLRequest*) getUrlRequest:(NSURL *) url
{
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"auth key = %@",self.oAuthKey);
    NSLog(@"auth secret = %@",self.oAuthSecret);
    NSLog(@"consumer key = %@",self.consumerKey);
    NSLog(@"consumer key = %@",self.consumerSecret);
#endif
    
    // token to send. We get the details from the user defaults
    OAToken *token = [[[OAToken alloc] initWithKey:self.oAuthKey
                                            secret:self.oAuthSecret] autorelease];
    
    // consumer to send. We get the details from the user defaults
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:self.consumerKey
                                                     secret:self.consumerSecret] autorelease];
    
    return [[[OAMutableURLRequest alloc] initWithURL:url
                                            consumer:consumer
                                               token:token
                                               realm:nil
                                   signatureProvider:nil] autorelease];
}

+ (BOOL) isMessageValid:(NSDictionary *)response{
    // get the content of code
    NSString* code = [response objectForKey:@"code"];
    NSInteger icode = [code integerValue];
    
    // is it different than 200, 201, 202
    if (icode != 200 && icode != 201 && icode != 202)
        return NO;
    
    // another kind of message
    return YES;
}

@end
