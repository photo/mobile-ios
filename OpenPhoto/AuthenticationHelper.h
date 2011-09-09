//
//  AuthenticationHelper.h
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface AuthenticationHelper : NSObject

- (BOOL) isValid;
- (void) invalidateAuthentication;

@end
