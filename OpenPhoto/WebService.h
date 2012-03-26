//
//  WebService.h
//  OpenPhoto
//
//  Created by Patrick Santana on 03/08/11.
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

#include <Three20/Three20.h>
#import "OAMutableURLRequest.h"
#import "OAToken.h"
#import "OADataFetcher.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

// for validation internet
@class Reachability;

// protocol to return the response from the server.
@protocol WebServiceDelegate <NSObject>
@required
- (void) receivedResponse:(NSDictionary*) response;
- (void) notifyUserNoInternet;
@end

@interface WebService : NSObject{
    id <WebServiceDelegate> delegate;
    
    // for internet checks
    Reachability* internetReachable;
    Reachability* hostReachable;
    
    BOOL internetActive, hostActive;
}

// protocol that will send the response
@property (retain) id delegate;

// properties
@property (nonatomic) BOOL  internetActive;
@property (nonatomic) BOOL  hostActive;

// get all tags. It brings how many images have this tag.
- (void) getTags; 

// get home pictures. It will bring 4 pictures from the last shared. 
- (void) getHomePictures; 

// get 25 pictures
- (void) loadGallery:(int) pageSize onPage:(int) page;

// get pictures by tag
-(void) loadGallery:(int) pageSize withTag:(NSString*) tag onPage:(int) page;

// get details from the system
-(void) getSystemVersion;


-(NSURL*) getOAuthInitialUrl;
-(NSURL*) getOAuthAccessUrl;
-(NSURL*) getOAuthTestUrl;

-(void) sendTestRequest;

// for network status
- (void) checkNetworkStatus:(NSNotification *)notice;

// method to check if the answer was correct or not
+ (BOOL) isMessageValid:(NSDictionary *)response;
+ (NSString*) getResponseMessage:(NSDictionary *)response;

@end
