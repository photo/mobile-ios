//
//  AuthenticationService.h
//  Photo
//
//  Created by Patrick Santana on 05/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OpenPhotoService.h"
#import "OpenPhotoServiceFactory.h"
#import "OADataFetcher.h"

@interface AuthenticationService : NSObject


// for OAuth 1.a
-(NSURL*) getOAuthInitialUrl;
-(NSURL*) getOAuthAccessUrl;
-(NSURL*) getOAuthTestUrl;


// methods related to user authentication
- (BOOL) isValid;
- (void) invalidateAuthentication;
- (void) startOAuthProcedure:(NSURL*) url;

@end
