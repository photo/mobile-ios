//
//  AuthenticationService.h
//  Photo
//
//  Created by Patrick Santana on 05/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthenticationService : NSObject

-(NSURL*) getOAuthInitialUrl;
-(NSURL*) getOAuthAccessUrl;
-(NSURL*) getOAuthTestUrl;

@end
