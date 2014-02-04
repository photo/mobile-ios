//
//  AuthenticationService.h
//  Trovebox
//
//  Created by Patrick Santana on 5/10/12.
//  Copyright 2013 Trovebox
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

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OADataFetcher.h"
#import "Account.h"
#import "PrivateAuthenticationService.h"
#import "Timeline+Methods.h"
#import "Synced+Methods.h"
#import <SDWebImage/SDImageCache.h>
#import "UpdateUtilities.h"

@interface AuthenticationService : NSObject


// for OAuth 1.a
-(NSURL*) getOAuthInitialUrl;
-(NSURL*) getOAuthAccessUrl;
-(NSURL*) getOAuthTestUrl;


// methods related to user authentication
+ (BOOL) isLogged;
- (void) logout;
- (void) startOAuthProcedure:(NSURL*) url;

// for login
// returns a list of Account
+ (NSArray *) signIn:(NSString*) email password:(NSString*) pwd;
+ (NSString *) recoverPassword:(NSString *) email;

+ (void) sendToServerReceipt:(NSData *) receipt forUser:(NSString *) email;

@end
