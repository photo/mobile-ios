//
//  PrivateAccountLoginService
//  Photo
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "AccountOpenPhoto.h"

@interface PrivateAccountLoginService : NSObject

+ (AccountOpenPhoto*) createNewAccountWithUser:(NSString*) user email:(NSString*) email;
+ (AccountOpenPhoto*) createNewAccountWithUser:(NSString*) user email:(NSString*) email password:(NSString*) pwd;
+ (BOOL) checkUserFacebookEmail:(NSString*) email;
+ (AccountOpenPhoto*) signIn:(NSString*) email password:(NSString*) pwd;
+ (NSString *) recoverPassword:(NSString *) email;

@end
