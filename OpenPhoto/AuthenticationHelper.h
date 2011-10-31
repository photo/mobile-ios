//
//  AuthenticationHelper.h
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface AuthenticationHelper : NSObject{
    WebService* webService;
}
@property (nonatomic, retain) WebService *webService;

- (BOOL) isValid;
- (void) invalidateAuthentication;
- (void) startOAuthProcedure:(NSURL*) url;

@end
