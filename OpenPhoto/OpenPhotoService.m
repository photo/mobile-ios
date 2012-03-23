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

- (NSArray*) fetchNewestPhotosMaxResults:(int) maxResults{
    return nil;
}


@end
