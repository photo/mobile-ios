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

@property (nonatomic, retain, readwrite) NSString *server;
@property (nonatomic, retain, readwrite) NSString *oAuthKey;
@property (nonatomic, retain, readwrite) NSString *oAuthSecret;
@property (nonatomic, retain, readwrite) NSString *consumerKey;
@property (nonatomic, retain, readwrite) NSString *consumerSecret;

@end

@implementation OpenPhotoService
static OpenPhotoService* _instance = nil; 
@synthesize server=_server, oAuthKey=_oAuthKey, oAuthSecret=_oAuthSecret, consumerKey = _consumerKey, consumerSecret=_consumerSecret;

+ (OpenPhotoService*) singletonForServer:(NSString *) server 
                                oAuthKey:(NSString *) oAuthKey 
                             oAuthSecret:(NSString *) oAuthSecret 
                             consumerKey:(NSString *) consumerKey 
                          consumerSecret:(NSString *) consumerSecret{
    @synchronized([OpenPhotoService class])
    {
        if (!_instance){
            [[self alloc]initForServer:server   oAuthKey:oAuthKey oAuthSecret:oAuthSecret consumerKey:consumerKey consumerSecret:consumerSecret];
        }
        
        return _instance;
    }
    
    return nil;
}

+(id)alloc
{
	@synchronized([OpenPhotoService class])
	{
		NSAssert(_instance == nil, @"Attempted to allocate a second instance of a singleton.");
		_instance = [super alloc];
		return _instance;
	}
    
	return nil;
}

-(id)initForServer:(NSString *) server 
          oAuthKey:(NSString *) oAuthKey 
       oAuthSecret:(NSString *) oAuthSecret 
       consumerKey:(NSString *) consumerKey 
    consumerSecret:(NSString *) consumerSecret{
    
	self = [super init];
    
	if (self != nil) {
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
    NSMutableString *request = [NSMutableString stringWithFormat: @"%@%i%@",@"/photos/list.json?sortBy=dateUploaded,DESC&pageSize=", maxResult, @"&returnSizes="];
    
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
    
    
    // token to send. We get the details from the user defaults
    OAToken *token = [[OAToken alloc] initWithKey:self.oAuthKey
                                           secret:self.oAuthSecret];
    
    // consumer to send. We get the details from the user defaults
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:self.consumerKey
                                                    secret:self.consumerSecret];
    
    OAMutableURLRequest *oaUrlRequest = [[OAMutableURLRequest alloc] initWithURL:url
                                                                        consumer:consumer
                                                                           token:token
                                                                           realm:nil
                                                               signatureProvider:nil];
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
    NSLog(@"Response = %@",[asiHttpRequest responseString]);
    NSDictionary *response =  [[asiHttpRequest responseString] JSONValue]; 
    
    
    if (![OpenPhotoService isMessageValid:response]){
        // invalid message
        NSException *exception = [NSException exceptionWithName: @"Incorrect request"
                                                         reason: [NSString stringWithFormat:@"Error: %@ - %@",[response objectForKey:@"code"],[response objectForKey:@"message"]]
                                                       userInfo: nil];
        @throw exception;
    }             
    
    [token release];
    [consumer release];
    [oaUrlRequest release];
    
    
    NSArray *result = [response objectForKey:@"result"] ;
    
    // check if user has photos
    if ([result class] == [NSNull class]){
        // if it is null, return an empty array
        return [NSArray array];
    }else {
        return result;
    }
}

- (void) validateCredentials{
    
    // validate if the singleton has all details for the account
    
    
    // if not
    /*
     // throw exception
     NSException *exception = [NSException exceptionWithName: @"unathorized access"
     reason: @"Credentials is not configured correct"
     userInfo: nil];
     @throw exception;
     */
    
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
